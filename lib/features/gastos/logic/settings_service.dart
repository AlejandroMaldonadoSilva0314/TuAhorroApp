import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';

class SettingsService {
  static const _keyMoneda = 'settings_moneda';
  static const _keyFormatoFecha = 'settings_formato_fecha';
  static const _keyTema = 'settings_tema';
  static const _keyPresupuesto = 'settings_presupuesto_semanal';
  static const _keyDiaInicio = 'settings_dia_inicio_semana';
  static const _keyNotifActivas = 'settings_notif_activas';
  static const _keyNotifHora = 'settings_notif_hora';
  static const _keyNotifMinuto = 'settings_notif_minuto';
  static const _keyOnboarding = 'settings_onboarding_completado';

  Future<AppSettings> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      moneda: prefs.getString(_keyMoneda) ?? 'COP',
      formatoFecha: FormatoFecha.values[prefs.getInt(_keyFormatoFecha) ?? 0],
      tema: TemaApp.values[prefs.getInt(_keyTema) ?? 2],
      presupuestoSemanal: prefs.getDouble(_keyPresupuesto) ?? 0,
      diaInicioSemana: DiaSemana.values[prefs.getInt(_keyDiaInicio) ?? 0],
      notificacionesActivas: prefs.getBool(_keyNotifActivas) ?? false,
      horaRecordatorio: prefs.getInt(_keyNotifHora) ?? 20,
      minutoRecordatorio: prefs.getInt(_keyNotifMinuto) ?? 0,
      onboardingCompletado: prefs.getBool(_keyOnboarding) ?? false,
    );
  }

  Future<void> guardar(AppSettings s) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_keyMoneda, s.moneda),
      prefs.setInt(_keyFormatoFecha, s.formatoFecha.index),
      prefs.setInt(_keyTema, s.tema.index),
      prefs.setDouble(_keyPresupuesto, s.presupuestoSemanal),
      prefs.setInt(_keyDiaInicio, s.diaInicioSemana.index),
      prefs.setBool(_keyNotifActivas, s.notificacionesActivas),
      prefs.setInt(_keyNotifHora, s.horaRecordatorio),
      prefs.setInt(_keyNotifMinuto, s.minutoRecordatorio),
      prefs.setBool(_keyOnboarding, s.onboardingCompletado),
    ]);
  }

  Future<int> espacioUtilizado() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    int bytes = 0;
    for (final key in keys) {
      final val = prefs.get(key);
      bytes += key.length;
      if (val is String) bytes += val.length;
      if (val is List<String>) bytes += val.fold(0, (s, e) => s + e.length);
      bytes += 8;
    }
    return bytes;
  }
}
