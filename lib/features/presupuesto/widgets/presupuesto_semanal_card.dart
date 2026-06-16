import 'package:flutter/material.dart';

import '../../../core/utils/formatos.dart';
import '../services/presupuesto_semanal_service.dart';

class PresupuestoSemanalCard extends StatelessWidget {
  const PresupuestoSemanalCard({
    super.key,
    required this.resumen,
    required this.onEditarPresupuesto,
  });

  final ResumenSemanal resumen;
  final VoidCallback onEditarPresupuesto;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (resumen.presupuesto <= 0) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: OutlinedButton.icon(
          onPressed: onEditarPresupuesto,
          icon: const Icon(Icons.savings_outlined),
          label: const Text('Definir presupuesto semanal'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      );
    }

    final color = resumen.excedido
        ? colorScheme.error
        : resumen.porcentajeUsado > 0.8
            ? Colors.orange.shade700
            : Colors.green.shade700;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.date_range_rounded, size: 16, color: color),
                const SizedBox(width: 6),
                Text(
                  'Presupuesto semanal',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onEditarPresupuesto,
                  child: Icon(Icons.edit_outlined,
                      size: 16, color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: resumen.porcentajeUsado,
                minHeight: 8,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _Indicador(
                  label: 'Presupuesto',
                  monto: resumen.presupuesto,
                  color: colorScheme.onSurface,
                ),
                _Indicador(
                  label: 'Gastado',
                  monto: resumen.gastado,
                  color: colorScheme.error,
                ),
                _Indicador(
                  label: 'Disponible',
                  monto: resumen.disponible.abs(),
                  color: color,
                  sufijo: resumen.excedido ? ' (excedido)' : '',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Indicador extends StatelessWidget {
  const _Indicador({
    required this.label,
    required this.monto,
    required this.color,
    this.sufijo = '',
  });

  final String label;
  final double monto;
  final Color color;
  final String sufijo;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 2),
          Text(
            '${Formatos.moneda(monto)}$sufijo',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
