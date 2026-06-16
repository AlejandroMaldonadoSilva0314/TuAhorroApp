import 'package:flutter/material.dart';

import '../../../core/utils/formatos.dart';
import '../../presupuesto/data/presupuesto_repository.dart';
import '../../presupuesto/services/presupuesto_semanal_service.dart';
import '../../presupuesto/widgets/presupuesto_semanal_card.dart';
import '../data/gasto_repository.dart';
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
  bool _cargando = true;
  String? _error;

  final _presupuestoRepo = PresupuestoRepository();
  final _presupuestoService = const PresupuestoSemanalService();
  double _presupuestoSemanal = 0;

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
        _presupuestoRepo.obtener(),
      ]);
      if (mounted) {
        setState(() {
          _gastos = resultados[0] as List<Gasto>;
          _presupuestoSemanal = resultados[1] as double;
          _cargando = false;
        });
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

  ResumenSemanal get _resumenSemanal =>
      _presupuestoService.calcularResumen(_presupuestoSemanal, _gastos);

  Future<void> _editarPresupuesto() async {
    final controller = TextEditingController(
      text: _presupuestoSemanal > 0
          ? _presupuestoSemanal.toStringAsFixed(0)
          : '',
    );
    final resultado = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Presupuesto semanal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            prefixText: '\$ ',
            hintText: 'Ej: 200000',
            labelText: 'Monto semanal',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final valor =
                  double.tryParse(controller.text.replaceAll(',', ''));
              Navigator.pop(ctx, valor);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (resultado != null && resultado > 0) {
      await _presupuestoRepo.guardar(resultado);
      setState(() => _presupuestoSemanal = resultado);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
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
        itemCount: _gastos.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return DashboardResumen(
              ingresos: _totalIngresos,
              gastos: _totalGastos,
              saldo: _saldo,
            );
          }
          if (index == 1) {
            return PresupuestoSemanalCard(
              resumen: _resumenSemanal,
              onEditarPresupuesto: _editarPresupuesto,
            );
          }
          final gasto = _gastos[index - 2];
          return GastoCard(
            gasto: gasto,
            onEliminar: () => _eliminarGasto(gasto.id),
          );
        },
      ),
    );
  }
}
