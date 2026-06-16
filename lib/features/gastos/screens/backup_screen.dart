import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/gasto_repository.dart';
import '../logic/backup_service.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key, required this.repository});

  final GastoRepository repository;

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _procesando = false;

  late final BackupService _backup = BackupService(widget.repository);

  Future<void> _exportar() async {
    setState(() => _procesando = true);
    try {
      await _backup.compartir();
      if (mounted) _mostrarSnack('Respaldo compartido.');
    } catch (e) {
      if (mounted) _mostrarSnack('Error al exportar: $e');
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  Future<void> _importar() async {
    setState(() => _procesando = true);
    try {
      final datos = await _backup.seleccionarArchivo();
      if (datos == null) {
        if (mounted) setState(() => _procesando = false);
        return;
      }

      final error = _backup.validar(datos);
      if (error != null) {
        if (mounted) _mostrarSnack(error);
        if (mounted) setState(() => _procesando = false);
        return;
      }

      if (!mounted) return;
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Restaurar datos'),
          content: const Text(
            'Esto agregará los datos del respaldo a tu información actual. ¿Continuar?',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Restaurar')),
          ],
        ),
      );

      if (confirmar != true) {
        if (mounted) setState(() => _procesando = false);
        return;
      }

      await _backup.importar(datos);
      if (mounted) _mostrarSnack('Datos restaurados correctamente.');
    } catch (e) {
      if (mounted) _mostrarSnack('Error al importar: $e');
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  void _mostrarSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(title: const Text('Respaldo')),
      body: _procesando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cs.cardSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: cs.cardBorder),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.cloud_upload_outlined, size: 36, color: cs.primary),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Exportar datos',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Genera un archivo JSON con todas tus transacciones, bolsillos, fiados, metas y presupuesto.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: cs.onSurfaceVariant, height: 1.4),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _exportar,
                          icon: const Icon(Icons.share_rounded),
                          label: const Text('Exportar y compartir'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cs.cardSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: cs.cardBorder),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.cloud_download_outlined, size: 36, color: cs.primary),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Importar datos',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Selecciona un archivo de respaldo para restaurar tu información.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: cs.onSurfaceVariant, height: 1.4),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _importar,
                          icon: const Icon(Icons.file_open_rounded),
                          label: const Text('Seleccionar archivo'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
