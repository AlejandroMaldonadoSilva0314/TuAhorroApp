import 'package:flutter/material.dart';

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
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        title: const Text('Respaldo'),
      ),
      body: _procesando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(Icons.cloud_upload_outlined, size: 48, color: cs.primary),
                        const SizedBox(height: 12),
                        const Text(
                          'Exportar datos',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Genera un archivo JSON con todas tus transacciones, bolsillos, fiados, metas y presupuesto.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _exportar,
                          icon: const Icon(Icons.share),
                          label: const Text('Exportar y compartir'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(Icons.cloud_download_outlined, size: 48, color: cs.primary),
                        const SizedBox(height: 12),
                        const Text(
                          'Importar datos',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Selecciona un archivo de respaldo para restaurar tu información.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _importar,
                          icon: const Icon(Icons.file_open),
                          label: const Text('Seleccionar archivo'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
