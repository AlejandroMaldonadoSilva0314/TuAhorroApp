import 'package:flutter/material.dart';

import '../../../core/theme/theme_scope.dart';
import '../../../core/utils/formatos.dart';
import '../../ajustes/screens/ajustes_screen.dart';
import '../../notificaciones/data/notificacion_repository_local.dart';
import '../../notificaciones/logic/notificacion_service.dart';
import '../../notificaciones/screens/notificaciones_screen.dart';
import '../../notificaciones/widgets/notificacion_badge.dart';
import '../data/gasto_repository.dart';
import '../logic/plata_para_hoy.dart';
import '../logic/presupuesto_semanal.dart';
import '../models/gasto.dart';
import '../widgets/dashboard_resumen.dart';
import '../widgets/gasto_card.dart';
import 'registro_screen.dart';

class ListaGastosScreen extends StatefulWidget {
  const ListaGastosScreen({super.key, required this.repository});

  final GastoRepository repository;

  @override
  State<ListaGastosScreen> createState() => _ListaGastosScreenState();
}

class _ListaGastosScreenState extends State<ListaGastosScreen> {
  List<Gasto> _gastos = [];
  double _presupuesto = 0;
  bool _cargando = true;
  String? _error;
  final _notifRepo = NotificacionRepositoryLocal();
  int _sinLeer = 0;

  @override
  void initState() {
    super.initState();
    _cargarGastos();
  }

  Future<void> _cargarGastos() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final resultados = await Future.wait([
        widget.repository.obtenerGastos(),
        widget.repository.obtenerPresupuestoSemanal(),
      ]);
      if (mounted) {
        setState(() {
          _gastos = resultados[0] as List<Gasto>;
          _presupuesto = resultados[1] as double;
          _cargando = false;
        });
        _evaluarNotificaciones();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al cargar los gastos.';
          _cargando = false;
        });
      }
    }
  }

  Future<void> _evaluarNotificaciones() async {
    await NotificacionService(
      gastoRepository: widget.repository,
      notificacionRepository: _notifRepo,
    ).evaluarYGenerarNotificaciones();
    final lista = await _notifRepo.obtenerNotificaciones();
    if (mounted) setState(() => _sinLeer = lista.where((n) => !n.leida).length);
  }

  Future<void> _abrirNotificaciones() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NotificacionesScreen(repository: _notifRepo),
      ),
    );
    final lista = await _notifRepo.obtenerNotificaciones();
    if (mounted) setState(() => _sinLeer = lista.where((n) => !n.leida).length);
  }

  Future<void> _eliminarGasto(String id) async {
    await widget.repository.eliminarGasto(id);
    await _cargarGastos();
  }

  double get _totalIngresos => _gastos
      .where((g) => g.tipo == TipoTransaccion.ingreso)
      .fold(0, (sum, g) => sum + g.monto);

  double get _totalGastos => _gastos
      .where((g) => g.tipo == TipoTransaccion.gasto)
      .fold(0, (sum, g) => sum + g.monto);

  double get _saldo => _totalIngresos - _totalGastos;

  double get _gastadoSemana =>
      PresupuestoSemanal().gastadoEstaSemana(_gastos);

  double get _disponibleSemana =>
      _presupuesto > 0 ? PresupuestoSemanal().disponible(presupuesto: _presupuesto, gastos: _gastos) : 0;

  double get _plataParaHoy => PlataParaHoy().calcular(
        saldo: _saldo,
        disponibleSemanal: _presupuesto > 0 ? _disponibleSemana : null,
      );

  Future<void> _actualizarPresupuesto(double monto) async {
    await widget.repository.guardarPresupuestoSemanal(monto);
    setState(() => _presupuesto = monto);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appTheme = ThemeScope.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: appTheme.gradient),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TuAhorro',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            if (!_cargando && _error == null)
              Text(
                'Total: ${Formatos.moneda(_totalGastos)}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarGastos,
            tooltip: 'Actualizar',
          ),
          NotificacionBadge(sinLeer: _sinLeer, onTap: _abrirNotificaciones),
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AjustesScreen()),
            ),
            tooltip: 'Personalizar',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => RegistroScreen(
                onGuardar: widget.repository.agregarGasto,
              ),
            ),
          );
          await _cargarGastos();
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo gasto'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildBody() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            FilledButton(onPressed: _cargarGastos, child: const Text('Reintentar')),
          ],
        ),
      );
    }

    if (_gastos.isEmpty) {
      return const Center(
        child: Text('No hay gastos registrados aún.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarGastos,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: _gastos.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return DashboardResumen(
              ingresos: _totalIngresos,
              gastos: _totalGastos,
              saldo: _saldo,
              plataParaHoy: _plataParaHoy,
              presupuestoSemanal: _presupuesto,
              gastadoSemana: _gastadoSemana,
              disponibleSemana: _disponibleSemana,
              onEditarPresupuesto: _actualizarPresupuesto,
            );
          }
          final gasto = _gastos[index - 1];
          return GastoCard(
            gasto: gasto,
            onEliminar: () => _eliminarGasto(gasto.id),
          );
        },
      ),
    );
  }
}
