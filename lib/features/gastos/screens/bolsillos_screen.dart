import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/formatos.dart';
import '../data/gasto_repository.dart';
import '../models/bolsillo.dart';
import '../models/gasto.dart';

class BolsillosScreen extends StatefulWidget {
  const BolsillosScreen({super.key, required this.repository});

  final GastoRepository repository;

  @override
  State<BolsillosScreen> createState() => _BolsillosScreenState();
}

class _BolsillosScreenState extends State<BolsillosScreen> {
  List<Bolsillo> _bolsillos = [];
  List<Gasto> _gastos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final resultados = await Future.wait([
      widget.repository.obtenerBolsillos(),
      widget.repository.obtenerGastos(),
    ]);
    if (mounted) {
      setState(() {
        _bolsillos = resultados[0] as List<Bolsillo>;
        _gastos = resultados[1] as List<Gasto>;
        _cargando = false;
      });
    }
  }

  double _saldoBolsillo(String bolsilloId) {
    final bolsillo = _bolsillos.firstWhere((b) => b.id == bolsilloId);
    double saldo = bolsillo.saldoInicial;
    for (final g in _gastos.where((g) => g.bolsilloId == bolsilloId)) {
      saldo += g.tipo == TipoTransaccion.ingreso ? g.monto : -g.monto;
    }
    return saldo;
  }

  Future<void> _mostrarDialogo({Bolsillo? existente}) async {
    final nombreCtrl = TextEditingController(text: existente?.nombre ?? '');
    final saldoCtrl = TextEditingController(
      text: existente != null && existente.saldoInicial > 0
          ? existente.saldoInicial.toStringAsFixed(0)
          : '',
    );
    final esEdicion = existente != null;

    final resultado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(esEdicion ? 'Editar bolsillo' : 'Nuevo bolsillo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                hintText: 'Ej: Comida, Transporte, Ahorro...',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: saldoCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
              decoration: const InputDecoration(
                labelText: 'Saldo inicial',
                prefixText: '\$ ',
                hintText: '0',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              if (nombreCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx, true);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (resultado != true) return;

    final nombre = nombreCtrl.text.trim();
    final saldo = double.tryParse(saldoCtrl.text.replaceAll(',', '.')) ?? 0;

    if (esEdicion) {
      await widget.repository.actualizarBolsillo(
        existente.copyWith(nombre: nombre, saldoInicial: saldo),
      );
    } else {
      final nuevo = Bolsillo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nombre: nombre,
        saldoInicial: saldo,
      );
      await widget.repository.agregarBolsillo(nuevo);
    }
    await _cargar();
  }

  Future<void> _eliminar(Bolsillo bolsillo) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar bolsillo'),
        content: Text('¿Eliminar "${bolsillo.nombre}"? Las transacciones asociadas no se borran.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    await widget.repository.eliminarBolsillo(bolsillo.id);
    await _cargar();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bolsillos'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _bolsillos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.wallet_rounded, size: 64, color: colorScheme.outlineVariant),
                      const SizedBox(height: 12),
                      const Text('No tienes bolsillos aún'),
                      const SizedBox(height: 8),
                      const Text('Crea uno para organizar tu dinero', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemCount: _bolsillos.length,
                  itemBuilder: (context, index) {
                    final b = _bolsillos[index];
                    final saldo = _saldoBolsillo(b.id);
                    return _BolsilloCard(
                      bolsillo: b,
                      saldo: saldo,
                      onEditar: () => _mostrarDialogo(existente: b),
                      onEliminar: () => _eliminar(b),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarDialogo(),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo bolsillo'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );
  }
}

class _BolsilloCard extends StatelessWidget {
  const _BolsilloCard({
    required this.bolsillo,
    required this.saldo,
    required this.onEditar,
    required this.onEliminar,
  });

  final Bolsillo bolsillo;
  final double saldo;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final esPositivo = saldo >= 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(Icons.wallet_rounded, color: colorScheme.primary),
        ),
        title: Text(bolsillo.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          Formatos.moneda(saldo.abs()),
          style: TextStyle(
            color: esPositivo ? Colors.green.shade700 : colorScheme.error,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'editar') onEditar();
            if (v == 'eliminar') onEliminar();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'editar', child: Text('Editar')),
            PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
          ],
        ),
      ),
    );
  }
}
