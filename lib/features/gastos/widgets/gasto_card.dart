import 'package:flutter/material.dart';

import '../../../core/utils/formatos.dart';
import '../models/categoria.dart';
import '../models/gasto.dart';

class GastoCard extends StatelessWidget {
  const GastoCard({
    super.key,
    required this.gasto,
    required this.categorias,
    this.onEliminar,
  });

  final Gasto gasto;
  final List<Categoria> categorias;
  final VoidCallback? onEliminar;

  Categoria? get _categoria =>
      categorias.where((c) => c.id == gasto.categoriaId).firstOrNull;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final cat = _categoria;

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
            cat?.icono ?? Icons.category_outlined,
            color: colorScheme.onPrimaryContainer,
            size: 20,
          ),
        ),
        title: Text(
          gasto.titulo,
          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${cat?.nombre ?? gasto.categoriaId} · ${Formatos.fecha(gasto.fecha)}',
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
}
