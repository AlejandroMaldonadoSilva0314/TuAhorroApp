import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
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
      appBar: AppBar(title: const Text('Bolsillos')),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _bolsillos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.wallet_rounded, size: 48,
                            color: colorScheme.primary.withValues(alpha: 0.5)),
                      ),
                      const SizedBox(height: 20),
                      Text('No tienes bolsillos aún',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Text('Crea uno para organizar tu dinero',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 12, bottom: 80),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogo(),
        child: const Icon(Icons.add_rounded),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.cardSurface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: colorScheme.accentGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.wallet_rounded, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bolsillo.nombre,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${esPositivo ? 'Saldo' : 'Déficit'}: ${Formatos.moneda(saldo.abs())}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: esPositivo ? colorScheme.positivo : colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'editar') onEditar();
                      if (v == 'eliminar') onEliminar();
                    },
                    icon: Icon(Icons.more_vert_rounded, color: colorScheme.onSurfaceVariant, size: 24),
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'editar', child: Text('Editar')),
                      PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (bolsillo.saldoInicial > 0) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Saldo inicial: ${Formatos.moneda(bolsillo.saldoInicial)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      esPositivo
                          ? '${((saldo / bolsillo.saldoInicial).clamp(0, 1) * 100).toInt()}%'
                          : '0%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: esPositivo ? colorScheme.positivo : colorScheme.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: bolsillo.saldoInicial > 0
                      ? (saldo / bolsillo.saldoInicial).clamp(0.0, 1.0)
                      : (esPositivo ? 1.0 : 0.0),
                  minHeight: 6,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  color: esPositivo ? colorScheme.positivo : colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
