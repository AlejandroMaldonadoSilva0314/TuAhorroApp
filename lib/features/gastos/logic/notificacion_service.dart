import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/notificacion_config.dart';

class NotificacionService {
  static final NotificacionService _instance = NotificacionService._();
  factory NotificacionService() => _instance;
  NotificacionService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  static const _kActivado = 'notif_activado';
  static const _kHora = 'notif_hora';
  static const _kMinuto = 'notif_minuto';
  static const _channelId = 'recordatorio_diario';
  static const _notifId = 0;

  static const _mensajes = [
    '¿Registraste tus gastos de hoy?',
    'Actualiza tu Plata para Hoy.',
    'No olvides anotar lo que gastaste hoy.',
    'Un minuto para registrar y mantener el control.',
  ];

  Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings: initSettings);

    final config = await cargarConfig();
    if (config.activado) {
      await programar(config);
    }
  }

  Future<NotificacionConfig> cargarConfig() async {
    final prefs = await SharedPreferences.getInstance();
    return NotificacionConfig(
      activado: prefs.getBool(_kActivado) ?? false,
      hora: prefs.getInt(_kHora) ?? 20,
      minuto: prefs.getInt(_kMinuto) ?? 0,
    );
  }

  Future<void> guardarConfig(NotificacionConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kActivado, config.activado);
    await prefs.setInt(_kHora, config.hora);
    await prefs.setInt(_kMinuto, config.minuto);

    if (config.activado) {
      await programar(config);
    } else {
      await cancelar();
    }
  }

  Future<void> programar(NotificacionConfig config) async {
    final mensaje = _mensajes[Random().nextInt(_mensajes.length)];

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      'Recordatorio diario',
      channelDescription: 'Recordatorio para registrar gastos',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    final ahora = tz.TZDateTime.now(tz.local);
    var programado = tz.TZDateTime(
      tz.local,
      ahora.year,
      ahora.month,
      ahora.day,
      config.hora,
      config.minuto,
    );
    if (programado.isBefore(ahora)) {
      programado = programado.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id: _notifId,
      title: 'TuAhorro',
      body: mensaje,
      scheduledDate: programado,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelar() async {
    await _plugin.cancel(id: _notifId);
  }
}
