enum TemaApp { claro, oscuro, sistema }

enum FormatoFecha { diaMesAnio, mesAnioDia, anioMesDia }

enum DiaSemana { lunes, martes, miercoles, jueves, viernes, sabado, domingo }

class AppSettings {
  final String moneda;
  final FormatoFecha formatoFecha;
  final TemaApp tema;
  final double presupuestoSemanal;
  final DiaSemana diaInicioSemana;
  final bool notificacionesActivas;
  final int horaRecordatorio;
  final int minutoRecordatorio;
  final bool onboardingCompletado;

  const AppSettings({
    this.moneda = 'COP',
    this.formatoFecha = FormatoFecha.diaMesAnio,
    this.tema = TemaApp.sistema,
    this.presupuestoSemanal = 0,
    this.diaInicioSemana = DiaSemana.lunes,
    this.notificacionesActivas = false,
    this.horaRecordatorio = 20,
    this.minutoRecordatorio = 0,
    this.onboardingCompletado = false,
  });

  AppSettings copyWith({
    String? moneda,
    FormatoFecha? formatoFecha,
    TemaApp? tema,
    double? presupuestoSemanal,
    DiaSemana? diaInicioSemana,
    bool? notificacionesActivas,
    int? horaRecordatorio,
    int? minutoRecordatorio,
    bool? onboardingCompletado,
  }) {
    return AppSettings(
      moneda: moneda ?? this.moneda,
      formatoFecha: formatoFecha ?? this.formatoFecha,
      tema: tema ?? this.tema,
      presupuestoSemanal: presupuestoSemanal ?? this.presupuestoSemanal,
      diaInicioSemana: diaInicioSemana ?? this.diaInicioSemana,
      notificacionesActivas: notificacionesActivas ?? this.notificacionesActivas,
      horaRecordatorio: horaRecordatorio ?? this.horaRecordatorio,
      minutoRecordatorio: minutoRecordatorio ?? this.minutoRecordatorio,
      onboardingCompletado: onboardingCompletado ?? this.onboardingCompletado,
    );
  }

  static const monedas = ['COP', 'USD', 'EUR', 'MXN', 'ARS', 'PEN', 'CLP'];

  String get formatoFechaLabel {
    switch (formatoFecha) {
      case FormatoFecha.diaMesAnio:
        return 'DD/MM/AAAA';
      case FormatoFecha.mesAnioDia:
        return 'MM/DD/AAAA';
      case FormatoFecha.anioMesDia:
        return 'AAAA/MM/DD';
    }
  }

  String get temaLabel {
    switch (tema) {
      case TemaApp.claro:
        return 'Claro';
      case TemaApp.oscuro:
        return 'Oscuro';
      case TemaApp.sistema:
        return 'Sistema';
    }
  }

  String get diaInicioSemanaLabel {
    switch (diaInicioSemana) {
      case DiaSemana.lunes:
        return 'Lunes';
      case DiaSemana.martes:
        return 'Martes';
      case DiaSemana.miercoles:
        return 'Miércoles';
      case DiaSemana.jueves:
        return 'Jueves';
      case DiaSemana.viernes:
        return 'Viernes';
      case DiaSemana.sabado:
        return 'Sábado';
      case DiaSemana.domingo:
        return 'Domingo';
    }
  }
}
