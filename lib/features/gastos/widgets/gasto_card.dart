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
    final iconBg = esIngreso
        ? colorScheme.positivo.withValues(alpha: 0.15)
        : colorScheme.error.withValues(alpha: 0.12);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onLongPress: onEliminar,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  cat?.icono ?? Icons.category_outlined,
                  color: montoColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gasto.titulo,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${cat?.nombre ?? gasto.categoriaId} · ${Formatos.fecha(gasto.fecha)}',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${esIngreso ? '+' : '-'}${Formatos.moneda(gasto.monto)}',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: montoColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
