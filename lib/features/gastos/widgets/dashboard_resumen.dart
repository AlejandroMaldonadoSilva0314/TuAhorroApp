import 'package:flutter/material.dart';

import '../../../core/utils/formatos.dart';

class DashboardResumen extends StatelessWidget {
  const DashboardResumen({
    super.key,
    required this.ingresos,
    required this.gastos,
    required this.saldo,
  });

  final double ingresos;
  final double gastos;
  final double saldo;

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
