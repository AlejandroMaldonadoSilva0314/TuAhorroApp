import 'package:flutter/material.dart';

import '../data/notificacion_repository_local.dart';
import '../models/notificacion.dart';
import '../models/notificacion_config.dart';

class NotificacionesAjustesSection extends StatefulWidget {
  const NotificacionesAjustesSection({super.key});

  @override
  State<NotificacionesAjustesSection> createState() =>
      _NotificacionesAjustesSectionState();
}

class _NotificacionesAjustesSectionState
    extends State<NotificacionesAjustesSection> {
  final _repo = NotificacionRepositoryLocal();
  NotificacionConfig _config = const NotificacionConfig();
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final config = await _repo.obtenerConfig();
    if (mounted) setState(() { _config = config; _cargando = false; });
  }

  Future<void> _actualizar(NotificacionConfig config) async {
    setState(() => _config = config);
    await _repo.guardarConfig(config);
  }

  Future<void> _seleccionarHora({required bool esInicio}) async {
    final horaActual = esInicio ? _config.horaInicio : _config.horaFin;
    final result = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: horaActual, minute: 0),
      helpText: esInicio ? 'Hora de inicio' : 'Hora de fin',
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (result == null) return;
    await _actualizar(
      esInicio
          ? _config.copyWith(horaInicio: result.hour)
          : _config.copyWith(horaFin: result.hour),
    );
  }

  Future<void> _toggleSilenciada(TipoNotificacion tipo) async {
    final set = Set<TipoNotificacion>.from(_config.silenciadas);
    if (set.contains(tipo)) {
      set.remove(tipo);
    } else {
      set.add(tipo);
    }
    await _actualizar(_config.copyWith(silenciadas: set));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_cargando) {
      return const SizedBox(height: 80, child: Center(child: CircularProgressIndicator()));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Encabezado ───────────────────────────────────────────────────────
        Text(
          'Notificaciones',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Avisos automáticos para mejorar tus hábitos',
          style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 16),

        // ── Toggle maestro ───────────────────────────────────────────────────
        _SwitchTile(
          titulo: 'Activar notificaciones',
          subtitulo: 'Recibe consejos y recordatorios',
          valor: _config.activadas,
          onChanged: (v) => _actualizar(_config.copyWith(activadas: v)),
          cs: cs,
        ),

        // ── Horario silencioso ───────────────────────────────────────────────
        if (_config.activadas) ...[
          const SizedBox(height: 8),
          _HoraTile(
            titulo: 'Horario permitido',
            subtitulo: _formatHoras(_config.horaInicio, _config.horaFin),
            onTapInicio: () => _seleccionarHora(esInicio: true),
            onTapFin: () => _seleccionarHora(esInicio: false),
            cs: cs,
          ),
          const SizedBox(height: 16),
          Text(
            'Silenciar por categoría',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          ...TipoNotificacion.values.map(
            (tipo) => _SwitchTile(
              titulo: tipo.nombre,
              subtitulo: _descripcionTipo(tipo),
              valor: !_config.silenciadas.contains(tipo),
              onChanged: (_) => _toggleSilenciada(tipo),
              cs: cs,
            ),
          ),
        ],
      ],
    );
  }

  String _formatHoras(int inicio, int fin) {
    String h(int v) => '${v.toString().padLeft(2, '0')}:00';
    return '${h(inicio)} – ${h(fin)}';
  }

  String _descripcionTipo(TipoNotificacion tipo) {
    const desc = {
      TipoNotificacion.registroDiario: 'Recordatorio de registro diario',
      TipoNotificacion.plataParaHoy: 'Cuánto puedes gastar hoy',
      TipoNotificacion.presupuestoSemanal: 'Alerta al 80% del presupuesto',
      TipoNotificacion.metaAhorro: 'Avances hacia tus metas',
      TipoNotificacion.prestamos: 'Préstamos pendientes',
      TipoNotificacion.insight: 'Comparativa semanal de gastos',
    };
    return desc[tipo] ?? '';
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.titulo,
    required this.subtitulo,
    required this.valor,
    required this.onChanged,
    required this.cs,
  });

  final String titulo;
  final String subtitulo;
  final bool valor;
  final ValueChanged<bool> onChanged;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: cs.surfaceContainerLow,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: cs.onSurface)),
                Text(subtitulo,
                    style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          Switch(value: valor, onChanged: onChanged),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _HoraTile extends StatelessWidget {
  const _HoraTile({
    required this.titulo,
    required this.subtitulo,
    required this.onTapInicio,
    required this.onTapFin,
    required this.cs,
  });

  final String titulo;
  final String subtitulo;
  final VoidCallback onTapInicio;
  final VoidCallback onTapFin;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: cs.surfaceContainerLow,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: cs.onSurface)),
                Text(subtitulo,
                    style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          TextButton(
            onPressed: onTapInicio,
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
            child: const Text('Inicio'),
          ),
          TextButton(
            onPressed: onTapFin,
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
            child: const Text('Fin'),
          ),
        ],
      ),
    );
  }
}
