import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatos.dart';
import '../data/gasto_repository.dart';
import '../models/meta_ahorro.dart';

class MetasScreen extends StatefulWidget {
  const MetasScreen({super.key, required this.repository});

  final GastoRepository repository;

  @override
  State<MetasScreen> createState() => _MetasScreenState();
}

class _MetasScreenState extends State<MetasScreen> {
  List<MetaAhorro> _metas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final metas = await widget.repository.obtenerMetas();
    if (mounted) setState(() { _metas = metas; _cargando = false; });
  }

  List<MetaAhorro> get _activas => _metas.where((m) => !m.completada).toList();
  List<MetaAhorro> get _completadas => _metas.where((m) => m.completada).toList();

  Future<void> _crearOEditar({MetaAhorro? existente}) async {
    final nombreCtrl = TextEditingController(text: existente?.nombre ?? '');
    final objetivoCtrl = TextEditingController(
      text: existente != null ? existente.montoObjetivo.toStringAsFixed(0) : '',
    );

    final resultado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existente != null ? 'Editar meta' : 'Nueva meta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nombre *',
                hintText: 'Ej: Viaje, Emergencias, Celular...',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: objetivoCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
              decoration: const InputDecoration(
                labelText: 'Monto objetivo *',
                prefixText: '\$ ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              if (nombreCtrl.text.trim().isEmpty) return;
              if (double.tryParse(objetivoCtrl.text.replaceAll(',', '.')) == null) return;
              Navigator.pop(ctx, true);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (resultado != true) return;

    final objetivo = double.parse(objetivoCtrl.text.replaceAll(',', '.'));

    if (existente != null) {
      await widget.repository.actualizarMeta(
        existente.copyWith(nombre: nombreCtrl.text.trim(), montoObjetivo: objetivo),
      );
    } else {
      await widget.repository.agregarMeta(MetaAhorro(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nombre: nombreCtrl.text.trim(),
        montoObjetivo: objetivo,
        fechaCreacion: DateTime.now(),
      ));
    }
    await _cargar();
  }

  Future<void> _abonar(MetaAhorro meta) async {
    final controller = TextEditingController();

    final resultado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Abonar a "${meta.nombre}"'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Faltante: ${Formatos.moneda(meta.faltante)}'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
              decoration: const InputDecoration(
                labelText: 'Monto a abonar',
                prefixText: '\$ ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              if (double.tryParse(controller.text.replaceAll(',', '.')) == null) return;
              Navigator.pop(ctx, true);
            },
            child: const Text('Abonar'),
          ),
        ],
      ),
    );

    if (resultado != true) return;

    final abono = double.parse(controller.text.replaceAll(',', '.'));
    final nuevoActual = meta.montoActual + abono;
    final completada = nuevoActual >= meta.montoObjetivo;

    await widget.repository.actualizarMeta(
      meta.copyWith(montoActual: nuevoActual, completada: completada),
    );
    await _cargar();
  }

  Future<void> _eliminar(MetaAhorro meta) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar meta'),
        content: Text('¿Eliminar "${meta.nombre}"?'),
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
    await widget.repository.eliminarMeta(meta.id);
    await _cargar();
  }

  Future<void> _marcarCompletada(MetaAhorro meta) async {
    await widget.repository.actualizarMeta(meta.copyWith(completada: true));
    await _cargar();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Metas de Ahorro')),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _metas.isEmpty
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
                        child: Icon(Icons.flag_rounded, size: 48,
                            color: colorScheme.primary.withValues(alpha: 0.5)),
                      ),
                      const SizedBox(height: 20),
                      Text('No tienes metas de ahorro',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Text('Crea una para empezar a ahorrar',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  children: [
                    if (_activas.isNotEmpty) ...[
                      _SeccionHeader(titulo: 'Activas (${_activas.length})'),
                      ..._activas.map((m) => _MetaCard(
                            meta: m,
                            onAbonar: () => _abonar(m),
                            onEditar: () => _crearOEditar(existente: m),
                            onCompletar: () => _marcarCompletada(m),
                            onEliminar: () => _eliminar(m),
                          )),
                    ],
                    if (_completadas.isNotEmpty) ...[
                      _SeccionHeader(titulo: 'Completadas (${_completadas.length})'),
                      ..._completadas.map((m) => _MetaCard(
                            meta: m,
                            onEditar: () => _crearOEditar(existente: m),
                            onEliminar: () => _eliminar(m),
                          )),
                    ],
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _crearOEditar(),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _SeccionHeader extends StatelessWidget {
  const _SeccionHeader({required this.titulo});

  final String titulo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        titulo,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _MetaCard extends StatelessWidget {
  const _MetaCard({
    required this.meta,
    this.onAbonar,
    required this.onEditar,
    this.onCompletar,
    required this.onEliminar,
  });

  final MetaAhorro meta;
  final VoidCallback? onAbonar;
  final VoidCallback onEditar;
  final VoidCallback? onCompletar;
  final VoidCallback onEliminar;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final porcentaje = (meta.progreso * 100).toInt();
    final progressColor = meta.completada ? colorScheme.positivo : colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.cardSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colorScheme.cardBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: meta.completada
                          ? colorScheme.positivoContainer
                          : colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      meta.completada ? Icons.check_rounded : Icons.flag_rounded,
                      color: meta.completada ? colorScheme.positivo : colorScheme.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meta.nombre,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            decoration: meta.completada ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${Formatos.moneda(meta.montoActual)} de ${Formatos.moneda(meta.montoObjetivo)}',
                          style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'abonar') onAbonar?.call();
                      if (v == 'editar') onEditar();
                      if (v == 'completar') onCompletar?.call();
                      if (v == 'eliminar') onEliminar();
                    },
                    itemBuilder: (_) => [
                      if (!meta.completada && onAbonar != null)
                        const PopupMenuItem(value: 'abonar', child: Text('Abonar')),
                      const PopupMenuItem(value: 'editar', child: Text('Editar')),
                      if (!meta.completada && onCompletar != null)
                        const PopupMenuItem(value: 'completar', child: Text('Completar')),
                      const PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: meta.progreso,
                  minHeight: 8,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  color: progressColor,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: progressColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$porcentaje%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: progressColor,
                      ),
                    ),
                  ),
                  if (!meta.completada)
                    Text(
                      'Faltan ${Formatos.moneda(meta.faltante)}',
                      style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                    ),
                  if (meta.completada)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded, size: 14, color: colorScheme.positivo),
                        const SizedBox(width: 4),
                        Text(
                          'Meta alcanzada',
                          style: TextStyle(fontSize: 12, color: colorScheme.positivo, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
