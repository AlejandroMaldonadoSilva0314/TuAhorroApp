import 'notificacion.dart';

class NotificacionConfig {
  final bool activadas;
  final int horaInicio;
  final int horaFin;
  final Set<TipoNotificacion> silenciadas;

  const NotificacionConfig({
    this.activadas = true,
    this.horaInicio = 8,
    this.horaFin = 21,
    this.silenciadas = const {},
  });

  NotificacionConfig copyWith({
    bool? activadas,
    int? horaInicio,
    int? horaFin,
    Set<TipoNotificacion>? silenciadas,
  }) {
    return NotificacionConfig(
      activadas: activadas ?? this.activadas,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      silenciadas: silenciadas ?? this.silenciadas,
    );
  }

  Map<String, dynamic> toMap() => {
        'activadas': activadas,
        'horaInicio': horaInicio,
        'horaFin': horaFin,
        'silenciadas': silenciadas.map((t) => t.name).toList(),
      };

  factory NotificacionConfig.fromMap(Map<String, dynamic> map) {
    final raw = map['silenciadas'] as List<dynamic>? ?? [];
    final silenciadas = raw
        .map((e) => TipoNotificacion.values.byName(e as String))
        .toSet();
    return NotificacionConfig(
      activadas: map['activadas'] as bool? ?? true,
      horaInicio: map['horaInicio'] as int? ?? 8,
      horaFin: map['horaFin'] as int? ?? 21,
      silenciadas: silenciadas,
    );
  }
}
