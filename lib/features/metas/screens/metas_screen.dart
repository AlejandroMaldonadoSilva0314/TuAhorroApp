import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatos.dart';
import '../data/meta_repository.dart';
import '../models/meta.dart';

const _emojis = ['🎯', '🏖️', '🏠', '🚗', '💻', '📚', '💍', '✈️', '🎓', '🏋️', '💰', '🎁'];

class MetasScreen extends StatefulWidget {
  const MetasScreen({super.key, required this.repository});

  final MetaRepository repository;

  @override
  State<MetasScreen> createState() => _MetasScreenState();
}

class _MetasScreenState extends State<MetasScreen> {
  List<Meta> _metas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final lista = await widget.repository.obtener();
    if (mounted) setState(() { _metas = lista; _cargando = false; });
  }

  double get _totalAhorrado => _metas.fold(0.0, (s, m) => s + m.ahorrado);
  double get _totalObjetivo => _metas.fold(0.0, (s, m) => s + m.objetivo);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _Encabezado(
              totalAhorrado: _cargando ? null : _totalAhorrado,
              totalObjetivo: _cargando ? null : _totalObjetivo,
            ),
          ),
          if (_cargando)
            SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                  strokeWidth: 2.5,
                ),
              ),
            )
          else if (_metas.isEmpty)
            const SliverFillRemaining(child: _EstadoVacio())
          else ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.base, 0, AppSpacing.base, AppSpacing.sm,
              ),
              sliver: SliverList.builder(
                itemCount: _metas.length,
                itemBuilder: (ctx, i) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _MetaCard(
                    meta: _metas[i],
                    onAbonar: () => _abrirAbonar(_metas[i]),
                    onEliminar: () => _eliminar(_metas[i].id),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 96)),
          ],
        ],
      ),
      floatingActionButton: _FABPremium(onPressed: _abrirCrear),
    );
  }

  Future<void> _eliminar(String id) async {
    await widget.repository.eliminar(id);
    await _cargar();
  }

  Future<void> _abrirAbonar(Meta meta) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _DialogAbonar(
        meta: meta,
        onAbonar: (monto) async {
          final actualizada = meta.copyWith(
            ahorrado: (meta.ahorrado + monto).clamp(0, double.infinity),
          );
          await widget.repository.guardar(actualizada);
          await _cargar();
        },
        onEliminar: () async {
          await widget.repository.eliminar(meta.id);
          await _cargar();
        },
      ),
    );
  }

  Future<void> _abrirCrear() async {
    await showDialog<void>(
      context: context,
      builder: (_) => _DialogCrear(
        onCrear: (m) async {
          await widget.repository.guardar(m);
          await _cargar();
        },
      ),
    );
  }
}

// ── ENCABEZADO HERO — Apple Fitness ring ─────────────────────────────────────

class _Encabezado extends StatelessWidget {
  const _Encabezado({this.totalAhorrado, this.totalObjetivo});

  final double? totalAhorrado;
  final double? totalObjetivo;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tieneObjetivo =
        totalObjetivo != null && totalAhorrado != null && totalObjetivo! > 0;
    final progreso = tieneObjetivo
        ? (totalAhorrado! / totalObjetivo!).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      color: cs.surface,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.base,
        MediaQuery.of(context).padding.top + AppSpacing.sm,
        AppSpacing.base,
        AppSpacing.base,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge título
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: cs.heroGradient,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.40),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.rocket_launch_rounded,
                    color: Colors.white, size: 17),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Metas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          if (tieneObjetivo) ...[
            const SizedBox(height: AppSpacing.lg),
            // Hero ring — Apple Fitness style
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: cs.accentGradient,
                borderRadius: BorderRadius.circular(AppRadius.xxl),
                border: Border.all(color: cs.cardBorder),
              ),
              child: Row(
                children: [
                  // Ring de progreso circular
                  SizedBox(
                    width: 96,
                    height: 96,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 96,
                          height: 96,
                          child: CircularProgressIndicator(
                            value: progreso,
                            strokeWidth: 7,
                            backgroundColor: cs.cardBorder,
                            valueColor: AlwaysStoppedAnimation(
                              progreso >= 1.0
                                  ? cs.positivo
                                  : cs.primaryContainer,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${(progreso * 100).round()}%',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: cs.onSurface,
                                letterSpacing: -0.8,
                                height: 1.0,
                              ),
                            ),
                            Text(
                              'logrado',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: cs.onSurfaceVariant,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xl),
                  // Stats
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AHORRADO',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurfaceVariant,
                            letterSpacing: 1.3,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            Formatos.moneda(totalAhorrado!),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: cs.onSurface,
                              letterSpacing: -0.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'meta ${Formatos.moneda(totalObjetivo!)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── CARD ─────────────────────────────────────────────────────────────────────

class _MetaCard extends StatelessWidget {
  const _MetaCard({
    required this.meta,
    required this.onAbonar,
    required this.onEliminar,
  });

  final Meta meta;
  final VoidCallback onAbonar;
  final VoidCallback onEliminar;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pct = (meta.progreso * 100).toStringAsFixed(0);
    final color = meta.completada ? cs.positivo : cs.primaryContainer;

    return GestureDetector(
      onTap: onAbonar,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          gradient: cs.accentGradient,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: meta.completada
                ? cs.positivo.withValues(alpha: 0.4)
                : cs.cardBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Ring circular Apple Fitness style
                SizedBox(
                  width: 56,
                  height: 56,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 56,
                        height: 56,
                        child: CircularProgressIndicator(
                          value: meta.progreso,
                          strokeWidth: 3.5,
                          backgroundColor: cs.cardBorder,
                          valueColor: AlwaysStoppedAnimation(color),
                        ),
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: cs.surfaceContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(meta.emoji,
                              style: const TextStyle(fontSize: 22)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              meta.nombre,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: cs.onSurface,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (meta.completada)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: cs.positivo.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                              ),
                              child: Text(
                                '✓ Lograda',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: cs.positivo,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${Formatos.moneda(meta.ahorrado)} de ${Formatos.moneda(meta.objetivo)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '$pct%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            if (meta.fechaObjetivo != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Fecha objetivo: ${Formatos.fecha(meta.fechaObjetivo!)}',
                style: TextStyle(
                  fontSize: 11,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── DIÁLOGO: ABONAR ──────────────────────────────────────────────────────────

class _DialogAbonar extends StatefulWidget {
  const _DialogAbonar({
    required this.meta,
    required this.onAbonar,
    required this.onEliminar,
  });

  final Meta meta;
  final Future<void> Function(double) onAbonar;
  final Future<void> Function() onEliminar;

  @override
  State<_DialogAbonar> createState() => _DialogAbonarState();
}

class _DialogAbonarState extends State<_DialogAbonar> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final monto = double.tryParse(_ctrl.text.replaceAll(',', '.'));
    if (monto == null || monto <= 0) return;
    await widget.onAbonar(monto);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _eliminar() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar meta'),
        content: Text('¿Eliminar "${widget.meta.nombre}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await widget.onEliminar();
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final faltante = widget.meta.faltante;

    return AlertDialog(
      title: Row(
        children: [
          Text(widget.meta.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              widget.meta.nombre,
              style: TextStyle(color: cs.onSurface),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.meta.completada)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: cs.positivo.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                '¡Meta completada! 🎉',
                style: TextStyle(color: cs.positivo, fontWeight: FontWeight.w600),
              ),
            )
          else
            Text(
              'Faltan ${Formatos.moneda(faltante)}',
              style: TextStyle(
                fontSize: 14,
                color: cs.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: AppSpacing.base),
          TextField(
            controller: _ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
            autofocus: true,
            decoration: const InputDecoration(
              prefixText: '\$ ',
              hintText: '0',
              labelText: 'Monto a abonar',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _eliminar,
          style: TextButton.styleFrom(foregroundColor: cs.error),
          child: const Text('Eliminar'),
        ),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(onPressed: _guardar, child: const Text('Abonar')),
      ],
    );
  }
}

// ── DIÁLOGO: CREAR ───────────────────────────────────────────────────────────

class _DialogCrear extends StatefulWidget {
  const _DialogCrear({required this.onCrear});

  final Future<void> Function(Meta) onCrear;

  @override
  State<_DialogCrear> createState() => _DialogCrearState();
}

class _DialogCrearState extends State<_DialogCrear> {
  final _nombreCtrl = TextEditingController();
  final _objetivoCtrl = TextEditingController();
  String _emoji = '🎯';

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _objetivoCtrl.dispose();
    super.dispose();
  }

  Future<void> _crear() async {
    final nombre = _nombreCtrl.text.trim();
    final objetivo = double.tryParse(_objetivoCtrl.text.replaceAll(',', '.')) ?? 0;
    if (nombre.isEmpty || objetivo <= 0) return;
    final meta = Meta(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: nombre,
      emoji: _emoji,
      objetivo: objetivo,
    );
    await widget.onCrear(meta);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AlertDialog(
      title: const Text('Nueva meta'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nombreCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Nombre', hintText: 'Ej: Viaje a Cartagena'),
            ),
            const SizedBox(height: AppSpacing.base),
            TextField(
              controller: _objetivoCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
              decoration: const InputDecoration(
                prefixText: '\$ ',
                labelText: 'Objetivo',
                hintText: '500000',
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            Text(
              'ÍCONO',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _emojis.map((e) {
                final sel = e == _emoji;
                return GestureDetector(
                  onTap: () => setState(() => _emoji = e),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: sel ? cs.primary.withValues(alpha: 0.2) : cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: sel ? Border.all(color: cs.primary) : null,
                    ),
                    child: Center(child: Text(e, style: const TextStyle(fontSize: 22))),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(onPressed: _crear, child: const Text('Crear')),
      ],
    );
  }
}

// ── ESTADO VACÍO ─────────────────────────────────────────────────────────────

class _EstadoVacio extends StatelessWidget {
  const _EstadoVacio();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: cs.heroGradient,
                borderRadius: BorderRadius.circular(AppRadius.xxl),
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.flag_rounded, color: Colors.white, size: 36),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Sin metas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Crea una meta de ahorro\ny empieza a cumplir tus sueños.',
              style: TextStyle(
                fontSize: 14,
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FABPremium extends StatelessWidget {
  const _FABPremium({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: cs.heroGradient,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        highlightElevation: 0,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Nueva meta',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
