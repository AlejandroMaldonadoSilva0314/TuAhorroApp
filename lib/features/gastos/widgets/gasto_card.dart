import 'package:flutter/material.dart';

import '../../../core/utils/formatos.dart';
import '../models/gasto.dart';

class GastoCard extends StatelessWidget {
  const GastoCard({
    super.key,
    required this.gasto,
    this.onEliminar,
  });

  final Gasto gasto;
  final VoidCallback? onEliminar;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(
            _iconoPorCategoria(gasto.categoria),
            color: colorScheme.onPrimaryContainer,
            size: 20,
          ),
        ),
        title: Text(
          gasto.titulo,
          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${gasto.categoria.nombre} · ${Formatos.fecha(gasto.fecha)}',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              Formatos.moneda(gasto.monto),
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            if (onEliminar != null)
              IconButton(
                icon: Icon(Icons.delete_outline,
                    color: colorScheme.error, size: 20),
                onPressed: onEliminar,
                tooltip: 'Eliminar gasto',
              ),
          ],
        ),
      ),
    );
  }

  IconData _iconoPorCategoria(CategoriaGasto categoria) {
    return switch (categoria) {
      CategoriaGasto.comida => Icons.restaurant_outlined,
      CategoriaGasto.transporte => Icons.directions_bus_outlined,
      CategoriaGasto.servicios => Icons.receipt_long_outlined,
      CategoriaGasto.entretenimiento => Icons.movie_outlined,
      CategoriaGasto.salud => Icons.local_hospital_outlined,
      CategoriaGasto.educacion => Icons.school_outlined,
      CategoriaGasto.otros => Icons.category_outlined,
    };
  }
}
