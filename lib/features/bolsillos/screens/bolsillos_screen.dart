import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatos.dart';
import '../data/bolsillo_repository.dart';
import '../models/bolsillo.dart';

const _emojis = ['💰', '🏠', '✈️', '🎓', '🛒', '💊', '🎮', '🚗', '🍔', '📱', '👕', '🐾'];

class BolsillosScreen extends StatefulWidget {
  const BolsillosScreen({super.key, required this.repository});

  final BolsilloRepository repository;

  @override
  State<BolsillosScreen> createState() => _BolsillosScreenState();
}

class _BolsillosScreenState extends State<BolsillosScreen> {
  List<Bolsillo> _bolsillos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final lista = await widget.repository.obtener();
    if (mounted) setState(() { _bolsillos = lista; _cargando = false; });
  }

  double get _totalBolsillos => _bolsillos.fold(0.0, (s, b) => s + b.saldo);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _EncabezadoBolsillos(total: _cargando ? null : _totalBolsillos),
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
          else if (_bolsillos.isEmpty)
            const SliverFillRemaining(child: _EstadoVacio())
          else ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.base, 0, AppSpacing.base, AppSpacing.sm,
              ),
              sliver: SliverList.builder(
                itemCount: _bolsillos.length,
                itemBuilder: (ctx, i) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _BolsilloCard(
                    bolsillo: _bolsillos[i],
                    onTap: () => _abrirGestion(_bolsillos[i]),
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

  Future<void> _abrirGestion(Bolsillo bolsillo) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _DialogGestion(
        bolsillo: bolsillo,
        onActualizar: (b) async {
          await widget.repository.guardar(b);
          await _cargar();
        },
        onEliminar: () async {
          await widget.repository.eliminar(bolsillo.id);
          await _cargar();
        },
      ),
    );
  }

  Future<void> _abrirCrear() async {
    await showDialog<void>(
      context: context,
      builder: (_) => _DialogCrear(
        onCrear: (b) async {
          await widget.repository.guardar(b);
          await _cargar();
        },
      ),
    );
  }
}

// ── ENCABEZADO HERO ───────────────────────────────────────────────────────────

class _EncabezadoBolsillos extends StatelessWidget {
  const _EncabezadoBolsillos({this.total});

  final double? total;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
                  gradient: cs.accentGradient,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  boxShadow: [
                    BoxShadow(
                      color: cs.positivo.withValues(alpha: 0.40),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.account_balance_wallet_rounded,
                    color: Colors.white, size: 17),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Bolsillos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          if (total != null) ...[
            const SizedBox(height: AppSpacing.md),
            // Hero card — Nequi inspired
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: cs.accentGradient,
                borderRadius: BorderRadius.circular(AppRadius.xxl),
                boxShadow: [
                  BoxShadow(
                    color: cs.positivo.withValues(alpha: 0.40),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.xxl),
                child: Stack(
                  children: [
                    // Círculos decorativos de profundidad
                    Positioned(
                      top: -28,
                      right: -20,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.07),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -36,
                      right: 30,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.04),
                        ),
                      ),
                    ),
                    // Contenido
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL EN BOLSILLOS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withValues(alpha: 0.75),
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              Formatos.moneda(total!),
                              style: const TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -1.2,
                                height: 1.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'distribuido en tus bolsillos',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.70),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── CARD ─────────────────────────────────────────────────────────────────────

class _BolsilloCard extends StatelessWidget {
  const _BolsilloCard({required this.bolsillo, required this.onTap});

  final Bolsillo bolsillo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tieneObjetivo = bolsillo.objetivo > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          gradient: cs.cardGradient,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: cs.cardBorder),
          boxShadow: cs.cardShadow,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (tieneObjetivo)
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: CircularProgressIndicator(
                        value: bolsillo.progreso,
                        strokeWidth: 3,
                        backgroundColor: cs.cardBorder,
                        valueColor: AlwaysStoppedAnimation(
                          bolsillo.progreso >= 1.0
                              ? cs.positivo
                              : bolsillo.progreso >= 0.6
                                  ? cs.positivo
                                  : bolsillo.progreso >= 0.3
                                      ? cs.alerta
                                      : cs.primaryContainer,
                        ),
                      ),
                    ),
                  Container(
                    width: tieneObjetivo ? 44 : 52,
                    height: tieneObjetivo ? 44 : 52,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainer,
                      borderRadius: BorderRadius.circular(
                          tieneObjetivo ? AppRadius.pill : AppRadius.md),
                    ),
                    child: Center(
                      child: Text(
                        bolsillo.emoji,
                        style: TextStyle(fontSize: tieneObjetivo ? 22 : 26),
                      ),
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
                  Text(
                    bolsillo.nombre,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  if (tieneObjetivo)
                    Text(
                      '${(bolsillo.progreso * 100).toStringAsFixed(0)}% · meta ${Formatos.moneda(bolsillo.objetivo)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                      ),
                    )
                  else
                    Text(
                      'Sin objetivo',
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Formatos.moneda(bolsillo.saldo),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: cs.onSurfaceVariant,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── DIÁLOGO: GESTIÓN ─────────────────────────────────────────────────────────

class _DialogGestion extends StatefulWidget {
  const _DialogGestion({
    required this.bolsillo,
    required this.onActualizar,
    required this.onEliminar,
  });

  final Bolsillo bolsillo;
  final Future<void> Function(Bolsillo) onActualizar;
  final Future<void> Function() onEliminar;

  @override
  State<_DialogGestion> createState() => _DialogGestionState();
}

class _DialogGestionState extends State<_DialogGestion> {
  final _ctrl = TextEditingController();
  bool _agregar = true;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final monto = double.tryParse(_ctrl.text.replaceAll(',', '.'));
    if (monto == null || monto <= 0) return;
    final nuevoSaldo = _agregar
        ? widget.bolsillo.saldo + monto
        : (widget.bolsillo.saldo - monto).clamp(0.0, double.infinity);
    await widget.onActualizar(widget.bolsillo.copyWith(saldo: nuevoSaldo));
    if (mounted) Navigator.pop(context);
  }

  Future<void> _eliminar() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar bolsillo'),
        content: Text('¿Eliminar "${widget.bolsillo.nombre}"? El saldo se perderá.'),
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
    return AlertDialog(
      title: Row(
        children: [
          Text(widget.bolsillo.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              widget.bolsillo.nombre,
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
          Text(
            'Saldo actual: ${Formatos.moneda(widget.bolsillo.saldo)}',
            style: TextStyle(
              fontSize: 14,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          // Toggle agregar/retirar
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Row(
              children: [
                _ToggleBtn(
                  label: 'Agregar',
                  activo: _agregar,
                  color: cs.positivo,
                  onTap: () => setState(() => _agregar = true),
                ),
                _ToggleBtn(
                  label: 'Retirar',
                  activo: !_agregar,
                  color: cs.error,
                  onTap: () => setState(() => _agregar = false),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
            autofocus: true,
            decoration: const InputDecoration(
              prefixText: '\$ ',
              hintText: '0',
              labelText: 'Monto',
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
        FilledButton(onPressed: _guardar, child: const Text('Guardar')),
      ],
    );
  }
}

// ── DIÁLOGO: CREAR ───────────────────────────────────────────────────────────

class _DialogCrear extends StatefulWidget {
  const _DialogCrear({required this.onCrear});

  final Future<void> Function(Bolsillo) onCrear;

  @override
  State<_DialogCrear> createState() => _DialogCrearState();
}

class _DialogCrearState extends State<_DialogCrear> {
  final _nombreCtrl = TextEditingController();
  final _objetivoCtrl = TextEditingController();
  String _emoji = '💰';

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _objetivoCtrl.dispose();
    super.dispose();
  }

  Future<void> _crear() async {
    final nombre = _nombreCtrl.text.trim();
    if (nombre.isEmpty) return;
    final objetivo = double.tryParse(_objetivoCtrl.text.replaceAll(',', '.')) ?? 0;
    final bolsillo = Bolsillo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: nombre,
      emoji: _emoji,
      objetivo: objetivo,
      saldo: 0,
    );
    await widget.onCrear(bolsillo);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AlertDialog(
      title: const Text('Nuevo bolsillo'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nombreCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Nombre', hintText: 'Ej: Vacaciones'),
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
            const SizedBox(height: AppSpacing.base),
            TextField(
              controller: _objetivoCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
              decoration: const InputDecoration(
                prefixText: '\$ ',
                labelText: 'Objetivo (opcional)',
                hintText: '0',
              ),
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

// ── HELPERS ──────────────────────────────────────────────────────────────────

class _ToggleBtn extends StatelessWidget {
  const _ToggleBtn({
    required this.label,
    required this.activo,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool activo;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: activo ? color.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: activo ? color.withValues(alpha: 0.5) : Colors.transparent,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: activo ? color : cs.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

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
                gradient: cs.accentGradient,
                borderRadius: BorderRadius.circular(AppRadius.xxl),
                boxShadow: [
                  BoxShadow(
                    color: cs.positivo.withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.account_balance_wallet_rounded,
                  color: Colors.white, size: 36),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Sin bolsillos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Crea bolsillos para organizar\ntu dinero por categorías.',
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
        gradient: cs.accentGradient,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: cs.fabShadow,
      ),
      child: FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        highlightElevation: 0,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Nuevo bolsillo',
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
