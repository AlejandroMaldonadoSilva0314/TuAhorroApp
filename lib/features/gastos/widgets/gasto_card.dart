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
    final cs = Theme.of(context).colorScheme;
    final cat = _categoria;
    final esIngreso = gasto.tipo == TipoTransaccion.ingreso;
    final montoColor = esIngreso ? cs.positivo : cs.error;
    final iconBg = esIngreso
        ? cs.positivo.withValues(alpha: 0.12)
        : cs.error.withValues(alpha: 0.10);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          onLongPress: onEliminar,
          child: Container(
            decoration: BoxDecoration(
              color: cs.cardSurface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: cs.cardBorder),
              boxShadow: cs.cardShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    // Borde lateral de color semántico
                    Container(
                      width: 3,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            montoColor,
                            montoColor.withValues(alpha: 0.4),
                          ],
                        ),
                      ),
                    ),
                    // Contenido
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14,
                        ),
                        child: Row(
                          children: [
                            // Ícono de categoría
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: iconBg,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                              ),
                              child: Icon(
                                cat?.icono ?? Icons.category_outlined,
                                color: montoColor,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Título y categoría
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    gasto.titulo,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.1,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${cat?.nombre ?? gasto.categoriaId} · ${Formatos.fecha(gasto.fecha)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Monto
                            Text(
                              '${esIngreso ? '+' : '−'}${Formatos.moneda(gasto.monto)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: montoColor,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
