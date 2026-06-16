import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
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
      appBar: AppBar(title: const Text('Notificaciones')),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: cs.cardSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cs.cardBorder),
                  ),
                  child: SwitchListTile(
                    title: const Text('Recordatorio diario'),
                    subtitle: const Text('Recibe un aviso para registrar tus gastos'),
                    value: _config.activado,
                    onChanged: (v) => _guardar(_config.copyWith(activado: v)),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: cs.cardSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cs.cardBorder),
                  ),
                  child: ListTile(
                    enabled: _config.activado,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.access_time_rounded, color: cs.primary, size: 20),
                    ),
                    title: const Text('Hora del recordatorio'),
                    subtitle: Text(
                      TimeOfDay(hour: _config.hora, minute: _config.minuto)
                          .format(context),
                    ),
                    trailing: Icon(Icons.chevron_right_rounded, size: 20,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
                    onTap: _config.activado ? _seleccionarHora : null,
                  ),
                ),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'MENSAJES DE EJEMPLO',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: cs.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                for (final msg in const [
                  '¿Registraste tus gastos de hoy?',
                  'Actualiza tu Plata para Hoy.',
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cs.subtleSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: cs.primary.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.notifications_outlined, size: 16, color: cs.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(msg, style: TextStyle(color: cs.onSurface, fontSize: 14)),
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
