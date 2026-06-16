import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
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
    final esIngreso = gasto.tipo == TipoTransaccion.ingreso;
    final montoColor = esIngreso ? colorScheme.positivo : colorScheme.error;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onLongPress: onEliminar,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: esIngreso
                      ? colorScheme.positivoContainer
                      : colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  cat?.icono ?? Icons.category_outlined,
                  color: esIngreso ? colorScheme.positivo : colorScheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gasto.titulo,
                      style: textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${cat?.nombre ?? gasto.categoriaId} · ${Formatos.fecha(gasto.fecha)}',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${esIngreso ? '+' : '-'}${Formatos.moneda(gasto.monto)}',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: montoColor,
                    ),
                  ),
                  if (onEliminar != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: montoColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          esIngreso ? 'Ingreso' : 'Gasto',
                          style: textTheme.labelSmall?.copyWith(
                            color: montoColor.withValues(alpha: 0.8),
                            fontSize: 10,
                          ),
                        ),
                      ),
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
