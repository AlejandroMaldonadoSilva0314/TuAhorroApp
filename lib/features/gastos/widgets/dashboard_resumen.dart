import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatos.dart';

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
    this.insightMensajes = const [],
    this.onTapInsights,
  });

  final double ingresos;
  final double gastos;
  final double saldo;
  final double plataParaHoy;
  final double presupuestoSemanal;
  final double gastadoSemana;
  final double disponibleSemana;
  final ValueChanged<double> onEditarPresupuesto;
  final List<String> insightMensajes;
  final VoidCallback? onTapInsights;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          _TarjetaPlataHoy(monto: plataParaHoy),
          const SizedBox(height: 12),
          _TarjetaSaldo(saldo: saldo),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _TarjetaIndicador(
                  label: 'Ingresos',
                  monto: ingresos,
                  icono: Icons.south_west_rounded,
                  esPositivo: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TarjetaIndicador(
                  label: 'Gastos',
                  monto: gastos,
                  icono: Icons.north_east_rounded,
                  esPositivo: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _TarjetaPresupuesto(
            presupuesto: presupuestoSemanal,
            gastado: gastadoSemana,
            disponible: disponibleSemana,
            onEditar: onEditarPresupuesto,
          ),
          if (insightMensajes.isNotEmpty) ...[
            const SizedBox(height: 12),
            _TarjetaInsights(
              mensajes: insightMensajes,
              onTap: onTapInsights,
            ),
          ],
        ],
      ),
    );
  }
}

class _TarjetaPlataHoy extends StatelessWidget {
  const _TarjetaPlataHoy({required this.monto});

  final double monto;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        gradient: colorScheme.heroGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.today_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                'Plata para Hoy',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.9),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            Formatos.moneda(monto),
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Disponible para gastar hoy',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaSaldo extends StatelessWidget {
  const _TarjetaSaldo({required this.saldo});

  final double saldo;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final esPositivo = saldo >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.account_balance_wallet_rounded,
                size: 20, color: colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saldo disponible',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${esPositivo ? '' : '-'}${Formatos.moneda(saldo.abs())}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          if (!esPositivo)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Déficit',
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TarjetaIndicador extends StatelessWidget {
  const _TarjetaIndicador({
    required this.label,
    required this.monto,
    required this.icono,
    required this.esPositivo,
  });

  final String label;
  final double monto;
  final IconData icono;
  final bool esPositivo;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = esPositivo ? colorScheme.positivo : colorScheme.error;
    final bgColor = esPositivo
        ? colorScheme.positivoContainer
        : colorScheme.errorContainer.withValues(alpha: 0.3);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icono, size: 14, color: color),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            Formatos.moneda(monto),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

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
    final colorScheme = Theme.of(context).colorScheme;
    final tienePresupuesto = presupuesto > 0;
    final progreso = tienePresupuesto ? (gastado / presupuesto).clamp(0.0, 1.0) : 0.0;
    final excedido = tienePresupuesto && gastado > presupuesto;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.calendar_month_rounded, size: 16, color: colorScheme.primary),
              ),
              const SizedBox(width: 8),
              Text(
                'Presupuesto semanal',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _mostrarDialogo(context),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    tienePresupuesto ? Icons.edit_rounded : Icons.add_rounded,
                    size: 14,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          if (!tienePresupuesto) ...[
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => _mostrarDialogo(context),
              child: Text(
                'Toca para definir tu presupuesto',
                style: TextStyle(fontSize: 13, color: colorScheme.primary, fontWeight: FontWeight.w500),
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progreso,
                minHeight: 8,
                backgroundColor: colorScheme.surfaceContainerHighest,
                color: excedido ? colorScheme.error : colorScheme.primary,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _MiniIndicador(
                  label: 'Presupuesto',
                  monto: presupuesto,
                  color: colorScheme.onSurfaceVariant,
                ),
                _MiniIndicador(
                  label: 'Gastado',
                  monto: gastado,
                  color: excedido ? colorScheme.error : colorScheme.onSurfaceVariant,
                ),
                _MiniIndicador(
                  label: 'Disponible',
                  monto: disponible,
                  color: colorScheme.positivo,
                ),
              ],
            ),
            if (excedido)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 14, color: colorScheme.error),
                      const SizedBox(width: 4),
                      Text(
                        'Excediste tu presupuesto semanal',
                        style: TextStyle(fontSize: 11, color: colorScheme.error, fontWeight: FontWeight.w500),
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
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
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
        Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(
          Formatos.moneda(monto),
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}

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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.subtleSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.primary.withValues(alpha: 0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.auto_awesome_rounded, size: 16, color: cs.primary),
                ),
                const SizedBox(width: 8),
                Text(
                  'Insights',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                const Spacer(),
                if (onTap != null)
                  Icon(Icons.chevron_right_rounded, size: 18, color: cs.onSurfaceVariant),
              ],
            ),
            const SizedBox(height: 10),
            for (final msg in mensajes)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  msg,
                  style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
