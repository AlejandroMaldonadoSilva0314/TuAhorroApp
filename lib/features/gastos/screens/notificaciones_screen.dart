import 'package:flutter/material.dart';

import '../logic/notificacion_service.dart';
import '../models/notificacion_config.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  final _service = NotificacionService();
  NotificacionConfig _config = const NotificacionConfig();
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final config = await _service.cargarConfig();
    if (mounted) setState(() { _config = config; _cargando = false; });
  }

  Future<void> _guardar(NotificacionConfig nueva) async {
    setState(() => _config = nueva);
    await _service.guardarConfig(nueva);
  }

  Future<void> _seleccionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _config.hora, minute: _config.minuto),
    );
    if (hora != null) {
      await _guardar(_config.copyWith(hora: hora.hour, minuto: hora.minute));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        title: const Text('Notificaciones'),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: SwitchListTile(
                    title: const Text('Recordatorio diario'),
                    subtitle: const Text('Recibe un aviso para registrar tus gastos'),
                    value: _config.activado,
                    onChanged: (v) => _guardar(_config.copyWith(activado: v)),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    enabled: _config.activado,
                    leading: const Icon(Icons.access_time_rounded),
                    title: const Text('Hora del recordatorio'),
                    subtitle: Text(
                      TimeOfDay(hour: _config.hora, minute: _config.minuto)
                          .format(context),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _config.activado ? _seleccionarHora : null,
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Mensajes de ejemplo:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                for (final msg in const [
                  '¿Registraste tus gastos de hoy?',
                  'Actualiza tu Plata para Hoy.',
                ])
                  Card(
                    color: cs.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.notifications_outlined, size: 20, color: cs.onPrimaryContainer),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(msg, style: TextStyle(color: cs.onPrimaryContainer)),
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
