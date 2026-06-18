import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatos.dart';
import '../models/fiado.dart';

class DashboardResumen extends StatelessWidget {
  const DashboardResumen({
    super.key,
    required this.ingresos,
    required this.gastos,
    required this.saldo,
    required this.plataParaHoy,
    required this.presupuestoSemanal,
    required this.gastadoSemana,
    required this.disponibleSemana,
    required this.onEditarPresupuesto,
    required this.fiadosPorCobrar,
    this.insightMensajes = const [],
    this.onTapInsights,
    this.onVerFiados,
  });

  final double ingresos;
  final double gastos;
  final double saldo;
  final double plataParaHoy;
  final double presupuestoSemanal;
  final double gastadoSemana;
  final double disponibleSemana;
  final ValueChanged<double> onEditarPresupuesto;
  final List<Fiado> fiadosPorCobrar;
  final List<String> insightMensajes;
  final VoidCallback? onTapInsights;
  final VoidCallback? onVerFiados;

  @override
  Widget build(BuildContext context) {
    final pct = presupuestoSemanal > 0
        ? (gastadoSemana / presupuestoSemanal).clamp(0.0, 1.0)
        : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base, AppSpacing.sm, AppSpacing.base, AppSpacing.base,
      ),
      child: Column(
        children: [
          _HeroPlataHoy(monto: plataParaHoy, porcentajePresupuesto: pct),
          const SizedBox(height: AppSpacing.md),
          _FilaTresStats(
            saldo: saldo,
            ingresos: ingresos,
            gastos: gastos,
          ),
          const SizedBox(height: AppSpacing.md),
          _TarjetaPresupuesto(
            presupuesto: presupuestoSemanal,
            gastado: gastadoSemana,
            disponible: disponibleSemana,
            onEditar: onEditarPresupuesto,
          ),
          if (insightMensajes.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _TarjetaInsights(mensajes: insightMensajes, onTap: onTapInsights),
          ],
          const SizedBox(height: AppSpacing.md),
          _TarjetaDineroPorCobrar(
            fiados: fiadosPorCobrar,
            onVerTodos: onVerFiados,
          ),
        ],
      ),
    );
  }
}

// ── HERO: PLATA PARA HOY ─────────────────────────────────────────────────────

class _HeroPlataHoy extends StatelessWidget {
  const _HeroPlataHoy({required this.monto, this.porcentajePresupuesto});

  final double monto;
  final double? porcentajePresupuesto;

  @override
  Widget build(BuildContext context) {
    final esPositivo = monto >= 0;
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: esPositivo ? cs.heroGradient : AppGradients.danger,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: cs.heroShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        child: Stack(
          children: [
            // Círculos decorativos de profundidad
            Positioned(
              top: -36,
              right: -36,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              right: 24,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: 80,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.03),
                ),
              ),
            ),
            // Contenido
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label con ícono
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: const Icon(
                          Icons.today_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Plata para Hoy',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.90),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const Spacer(),
                      // Día de la semana
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Text(
                          _diaAbreviado(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: 0.85),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Monto principal
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      Formatos.moneda(monto.abs()),
                      style: AppTypography.heroAmount,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  // Subtítulo
                  Text(
                    esPositivo
                        ? 'Disponible para gastar hoy'
                        : 'Sin presupuesto disponible',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.72),
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.1,
                    ),
                  ),
                  // Barra de progreso semanal (si hay presupuesto)
                  if (porcentajePresupuesto != null) ...[
                    const SizedBox(height: AppSpacing.base),
                    Row(
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(AppRadius.pill),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: porcentajePresupuesto!,
                                child: Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: porcentajePresupuesto! > 0.9
                                        ? Theme.of(context).colorScheme.alerta
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(AppRadius.pill),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          '${(porcentajePresupuesto! * 100).round()}% sem.',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: 0.70),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _diaAbreviado() {
    const dias = ['DOM', 'LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB'];
    return dias[DateTime.now().weekday % 7];
  }
}

// ── FILA TRES STATS (3 COLUMNAS IGUALES) — Nubank / Revolut style ────────────

class _FilaTresStats extends StatelessWidget {
  const _FilaTresStats({
    required this.saldo,
    required this.ingresos,
    required this.gastos,
  });

  final double saldo;
  final double ingresos;
  final double gastos;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final saldoPositivo = saldo >= 0;

    return Row(
      children: [
        Expanded(
          child: _StatCell(
            label: 'Saldo',
            monto: saldo.abs(),
            signo: saldoPositivo ? '' : '−',
            icono: Icons.account_balance_wallet_rounded,
            color: saldoPositivo ? cs.positivo : cs.error,
            cs: cs,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCell(
            label: 'Ingresos',
            monto: ingresos,
            icono: Icons.south_west_rounded,
            color: cs.positivo,
            cs: cs,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCell(
            label: 'Gastos',
            monto: gastos,
            icono: Icons.north_east_rounded,
            color: cs.error,
            cs: cs,
          ),
        ),
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.monto,
    required this.icono,
    required this.color,
    required this.cs,
    this.signo = '',
  });

  final String label;
  final double monto;
  final IconData icono;
  final Color color;
  final ColorScheme cs;
  final String signo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: cs.cardSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: cs.cardBorder),
        boxShadow: cs.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(icono, size: 13, color: color),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                    letterSpacing: 0.1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '$signo${Formatos.moneda(monto)}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: -0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── TARJETA PRESUPUESTO SEMANAL ───────────────────────────────────────────────

class _TarjetaPresupuesto extends StatelessWidget {
  const _TarjetaPresupuesto({
    required this.presupuesto,
    required this.gastado,
    required this.disponible,
    required this.onEditar,
  });

  final double presupuesto;
  final double gastado;
  final double disponible;
  final ValueChanged<double> onEditar;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tienePresupuesto = presupuesto > 0;
    final progreso = tienePresupuesto ? (gastado / presupuesto).clamp(0.0, 1.0) : 0.0;
    final excedido = tienePresupuesto && gastado > presupuesto;
    final progresoColor = excedido ? cs.error : cs.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: cs.presupuestoSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: cs.cardBorder),
        boxShadow: cs.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(Icons.calendar_month_rounded,
                    size: 16, color: cs.primary),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Presupuesto semanal',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _mostrarDialogo(context),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    tienePresupuesto ? Icons.edit_rounded : Icons.add_rounded,
                    size: 14,
                    color: cs.primary,
                  ),
                ),
              ),
            ],
          ),
          if (!tienePresupuesto) ...[
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: () => _mostrarDialogo(context),
              child: Text(
                'Toca para definir tu presupuesto',
                style: TextStyle(
                  fontSize: 13,
                  color: cs.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: AppSpacing.base),
            // Barra de progreso premium
            Stack(
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progreso,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: excedido
                            ? [cs.error, cs.error.withValues(alpha: 0.8)]
                            : [cs.primary, cs.primaryContainer],
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      boxShadow: [
                        BoxShadow(
                          color: progresoColor.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _MiniIndicador(
                  label: 'Presupuesto',
                  monto: presupuesto,
                  color: cs.onSurfaceVariant,
                ),
                _MiniIndicador(
                  label: 'Gastado',
                  monto: gastado,
                  color: excedido ? cs.error : cs.onSurfaceVariant,
                ),
                _MiniIndicador(
                  label: 'Disponible',
                  monto: disponible,
                  color: cs.positivo,
                ),
              ],
            ),
            if (excedido) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: cs.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 13, color: cs.error),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Excediste tu presupuesto',
                      style: TextStyle(
                          fontSize: 11,
                          color: cs.error,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  void _mostrarDialogo(BuildContext context) {
    final controller = TextEditingController(
      text: presupuesto > 0 ? presupuesto.toStringAsFixed(0) : '',
    );
    showDialog(
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
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              final valor = double.tryParse(controller.text) ?? 0;
              if (valor >= 0) onEditar(valor);
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

class _MiniIndicador extends StatelessWidget {
  const _MiniIndicador({
    required this.label,
    required this.monto,
    required this.color,
  });

  final String label;
  final double monto;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 10, color: color, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(
          Formatos.moneda(monto),
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700, color: color),
        ),
      ],
    );
  }
}

// ── TARJETA DINERO POR COBRAR ────────────────────────────────────────────────

class _TarjetaDineroPorCobrar extends StatelessWidget {
  const _TarjetaDineroPorCobrar({required this.fiados, this.onVerTodos});

  final List<Fiado> fiados;
  final VoidCallback? onVerTodos;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = cs.alerta;
    final hayFiados = fiados.isNotEmpty;
    final total = fiados.fold(0.0, (s, f) => s + f.monto);
    final personas = fiados.map((f) => f.nombre).toSet().length;
    final proximo = hayFiados
        ? fiados.reduce((a, b) => a.fecha.isBefore(b.fecha) ? a : b)
        : null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.alertaSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: cs.cardBorder),
        boxShadow: cs.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Línea de acento superior
            Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.30)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Icon(Icons.handshake_outlined, size: 16, color: color),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Dinero por Cobrar',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: onVerTodos,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Ver todos',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(Icons.chevron_right_rounded, size: 14, color: color),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.base),
                  // Contenido
                  if (!hayFiados)
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          size: 16,
                          color: cs.onSurfaceVariant.withValues(alpha: 0.45),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'No tienes dinero pendiente por cobrar',
                            style: TextStyle(
                              fontSize: 13,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    )
                  else ...[
                    // Monto total
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Te deben ${Formatos.moneda(total)}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: color,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      personas == 1
                          ? '1 persona tiene dinero pendiente'
                          : '$personas personas tienen dinero pendiente',
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // Próximo pendiente
                    if (proximo != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  proximo.nombre.isNotEmpty
                                      ? proximo.nombre[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: color,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    proximo.nombre,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: cs.onSurface,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (proximo.nota != null && proximo.nota!.isNotEmpty)
                                    Text(
                                      proximo.nota!,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: cs.onSurfaceVariant,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              Formatos.moneda(proximo.monto),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── TARJETA INSIGHTS ─────────────────────────────────────────────────────────

class _TarjetaInsights extends StatelessWidget {
  const _TarjetaInsights({required this.mensajes, this.onTap});

  final List<String> mensajes;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          gradient: cs.insightGradient,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: cs.insightAccent.withValues(alpha: 0.25),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: cs.insightAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(Icons.auto_awesome_rounded,
                      size: 15, color: cs.insightAccent),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Insights',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const Spacer(),
                if (onTap != null)
                  Icon(Icons.chevron_right_rounded,
                      size: 18, color: cs.onSurfaceVariant),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final msg in mensajes)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5, right: 6),
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cs.insightAccent.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        msg,
                        style: TextStyle(
                            fontSize: 13, color: cs.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
