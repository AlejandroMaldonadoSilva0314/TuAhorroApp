import 'package:flutter/material.dart';

class NotificacionBadge extends StatelessWidget {
  const NotificacionBadge({
    super.key,
    required this.sinLeer,
    required this.onTap,
  });

  final int sinLeer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Notificaciones',
      onPressed: onTap,
      icon: Badge(
        isLabelVisible: sinLeer > 0,
        label: Text(sinLeer > 9 ? '9+' : '$sinLeer'),
        child: const Icon(Icons.notifications_outlined),
      ),
    );
  }
}
