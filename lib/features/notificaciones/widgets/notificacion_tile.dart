import 'package:flutter/material.dart';
import '../models/notificacion.dart';

class NotificacionTile extends StatelessWidget {
  const NotificacionTile({
    super.key,
    required this.notificacion,
    required this.onTap,
    required this.onDismissed,
  });

  final NotificacionLocal notificacion;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  static const _iconos = <TipoNotificacion, IconData>{
    TipoNotificacion.registroDiario: Icons.edit_note_rounded,
    TipoNotificacion.plataParaHoy: Icons.today_rounded,
    TipoNotificacion.presupuestoSemanal: Icons.bar_chart_rounded,
    TipoNotificacion.metaAhorro: Icons.savings_rounded,
    TipoNotificacion.prestamos: Icons.handshake_outlined,
    TipoNotificacion.insight: Icons.lightbulb_outline_rounded,
  };

  String _tiempoRelativo(DateTime fecha) {
    final diff = DateTime.now().difference(fecha);
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'hace ${diff.inHours} h';
    if (diff.inDays == 1) return 'ayer';
    return 'hace ${diff.inDays} días';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final leida = notificacion.leida;

    return Dismissible(
      key: ValueKey(notificacion.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: cs.errorContainer,
        child: Icon(Icons.delete_outline_rounded, color: cs.onErrorContainer),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: leida
                ? cs.surfaceContainerLow
                : cs.primaryContainer.withValues(alpha: 0.25),
            border: Border.all(
              color: leida
                  ? cs.outlineVariant.withValues(alpha: 0.4)
                  : cs.primary.withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: leida ? cs.surfaceContainerHighest : cs.primaryContainer,
                ),
                child: Icon(
                  _iconos[notificacion.tipo] ?? Icons.notifications_outlined,
                  size: 19,
                  color: leida ? cs.onSurfaceVariant : cs.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notificacion.titulo,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: leida ? FontWeight.w400 : FontWeight.w600,
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                        if (!leida)
                          Container(
                            width: 7,
                            height: 7,
                            margin: const EdgeInsets.only(left: 6, top: 2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: cs.primary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notificacion.mensaje,
                      style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _tiempoRelativo(notificacion.fecha),
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
