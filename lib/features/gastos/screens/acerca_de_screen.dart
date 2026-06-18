import 'package:flutter/material.dart';

class AcercaDeScreen extends StatelessWidget {
  const AcercaDeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(title: const Text('Acerca de')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.savings_rounded, size: 56, color: cs.primary),
          ),
          const SizedBox(height: 20),
          Text(
            'TuAhorro',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.primary,
                  letterSpacing: -0.3,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Versión 1.0.0',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          Text(
            'Tu compañero para controlar gastos, organizar tu dinero '
            'en bolsillos y alcanzar tus metas de ahorro.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 32),
          Divider(color: cs.outlineVariant.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          _InfoTile(
            icon: Icons.code_rounded,
            titulo: 'Desarrollado con',
            subtitulo: 'Flutter & Dart',
          ),
          _InfoTile(
            icon: Icons.storage_rounded,
            titulo: 'Almacenamiento',
            subtitulo: 'Local en tu dispositivo',
          ),
          _InfoTile(
            icon: Icons.lock_rounded,
            titulo: 'Privacidad',
            subtitulo: 'Tus datos nunca salen de tu teléfono',
          ),
          const SizedBox(height: 24),
          Divider(color: cs.outlineVariant.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(
            '© 2026 TuAhorro',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.titulo,
    required this.subtitulo,
  });

  final IconData icon;
  final String titulo;
  final String subtitulo;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: cs.primary, size: 20),
      ),
      title: Text(titulo),
      subtitle: Text(subtitulo),
    );
  }
}
