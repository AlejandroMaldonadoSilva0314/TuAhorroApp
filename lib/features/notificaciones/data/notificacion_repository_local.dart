import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/notificacion.dart';
import '../models/notificacion_config.dart';
import 'notificacion_repository.dart';

class NotificacionRepositoryLocal implements NotificacionRepository {
  static const _keyNotifs = 'notificaciones_v1';
  static const _keyConfig = 'notificaciones_config_v1';
  static const _maxGuardadas = 50;

  @override
  Future<List<NotificacionLocal>> obtenerNotificaciones() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyNotifs);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    final notifs = list
        .map((e) => NotificacionLocal.fromMap(e as Map<String, dynamic>))
        .toList();
    notifs.sort((a, b) => b.fecha.compareTo(a.fecha));
    return notifs;
  }

  Future<void> _guardar(List<NotificacionLocal> lista) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyNotifs,
      jsonEncode(lista.map((n) => n.toMap()).toList()),
    );
  }

  @override
  Future<void> guardarNotificacion(NotificacionLocal notificacion) async {
    final lista = await obtenerNotificaciones();
    lista.insert(0, notificacion);
    await _guardar(lista.take(_maxGuardadas).toList());
  }

  @override
  Future<void> marcarLeida(String id) async {
    final lista = await obtenerNotificaciones();
    await _guardar(lista.map((n) => n.id == id ? n.copyWith(leida: true) : n).toList());
  }

  @override
  Future<void> eliminarNotificacion(String id) async {
    final lista = await obtenerNotificaciones();
    await _guardar(lista.where((n) => n.id != id).toList());
  }

  @override
  Future<NotificacionConfig> obtenerConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyConfig);
    if (raw == null) return const NotificacionConfig();
    return NotificacionConfig.fromMap(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> guardarConfig(NotificacionConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyConfig, jsonEncode(config.toMap()));
  }

  @override
  Future<DateTime?> ultimaEnviadaDeTipo(TipoNotificacion tipo) async {
    final lista = await obtenerNotificaciones();
    try {
      return lista.firstWhere((n) => n.tipo == tipo).fecha;
    } catch (_) {
      return null;
    }
  }
}
