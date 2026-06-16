import 'package:flutter/material.dart';

import '../../../core/utils/formatos.dart';
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
      final gastos = await widget.repository.obtenerGastos();
      if (mounted) {
        setState(() {
          _gastos = gastos;
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
        itemCount: _gastos.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return DashboardResumen(
              ingresos: _totalIngresos,
              gastos: _totalGastos,
              saldo: _saldo,
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
