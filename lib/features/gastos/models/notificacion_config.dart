class NotificacionConfig {
  final bool activado;
  final int hora;
  final int minuto;

  const NotificacionConfig({
    this.activado = false,
    this.hora = 20,
    this.minuto = 0,
  });

  NotificacionConfig copyWith({bool? activado, int? hora, int? minuto}) {
    return NotificacionConfig(
      activado: activado ?? this.activado,
      hora: hora ?? this.hora,
      minuto: minuto ?? this.minuto,
    );
  }
}
