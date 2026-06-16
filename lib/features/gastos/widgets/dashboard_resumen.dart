import 'package:flutter/material.dart';

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
  });

  final double ingresos;
  final double gastos;
  final double saldo;
  final double plataParaHoy;
  final double presupuestoSemanal;
  final double gastadoSemana;
  final double disponibleSemana;
  final ValueChanged<double> onEditarPresupuesto;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          // --- Saldo principal ---
          _TarjetaSaldo(saldo: saldo),
          const SizedBox(height: 12),
          // --- Plata para Hoy ---
          _TarjetaPlataHoy(monto: plataParaHoy),
          const SizedBox(height: 12),
          // --- Presupuesto semanal ---
          _TarjetaPresupuesto(
            presupuesto: presupuestoSemanal,
            gastado: gastadoSemana,
            disponible: disponibleSemana,
            onEditar: onEditarPresupuesto,
          ),
          const SizedBox(height: 12),
          // --- Ingresos / Gastos ---
          Row(
            children: [
              Expanded(
                child: _TarjetaIndicador(
                  label: 'Ingresos',
                  monto: ingresos,
                  icono: Icons.arrow_upward_rounded,
                  color: Colors.green.shade700,
                  colorFondo: Colors.green.shade50,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TarjetaIndicador(
                  label: 'Gastos',
                  monto: gastos,
                  icono: Icons.arrow_downward_rounded,
                  color: colorScheme.error,
                  colorFondo: colorScheme.errorContainer.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _TarjetaSaldo extends StatelessWidget {
  const _TarjetaSaldo({required this.saldo});

  final double saldo;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final esPositivo = saldo >= 0;
    final color = esPositivo ? Colors.green.shade700 : colorScheme.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined,
                  size: 18, color: colorScheme.onPrimaryContainer),
              const SizedBox(width: 6),
              Text(
                'Saldo disponible',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            Formatos.moneda(saldo.abs()),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (!esPositivo)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Gastos superan los ingresos',
                style: TextStyle(fontSize: 11, color: colorScheme.error),
              ),
            ),
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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.tertiary,
            colorScheme.tertiary.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.today_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plata para Hoy',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  Formatos.moneda(monto),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month_rounded, size: 18, color: colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                'Presupuesto semanal',
                style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _mostrarDialogo(context),
                child: Icon(
                  tienePresupuesto ? Icons.edit_rounded : Icons.add_circle_outline,
                  size: 20,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          if (!tienePresupuesto) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _mostrarDialogo(context),
              child: Text(
                'Toca para definir tu presupuesto',
                style: TextStyle(fontSize: 13, color: colorScheme.primary, fontWeight: FontWeight.w500),
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progreso,
                minHeight: 8,
                backgroundColor: colorScheme.surfaceContainerHighest,
                color: excedido ? colorScheme.error : colorScheme.primary,
              ),
            ),
            const SizedBox(height: 10),
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
                  color: Colors.green.shade700,
                ),
              ],
            ),
            if (excedido)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Excediste tu presupuesto semanal',
                  style: TextStyle(fontSize: 11, color: colorScheme.error),
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
        Text(label, style: TextStyle(fontSize: 10, color: color)),
        const SizedBox(height: 2),
        Text(
          Formatos.moneda(monto),
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}

class _TarjetaIndicador extends StatelessWidget {
  const _TarjetaIndicador({
    required this.label,
    required this.monto,
    required this.icono,
    required this.color,
    required this.colorFondo,
  });

  final String label;
  final double monto;
  final IconData icono;
  final Color color;
  final Color colorFondo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      decoration: BoxDecoration(
        color: colorFondo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            Formatos.moneda(monto),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
