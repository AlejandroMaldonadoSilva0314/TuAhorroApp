import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meta.dart';

class MetaRepository {
  static const _clave = 'metas_v1';

  Future<List<Meta>> obtener() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_clave);
    if (raw == null) return [];
    final lista = jsonDecode(raw) as List<dynamic>;
    return lista.map((item) {
      final map = item as Map<String, dynamic>;
      return Meta.fromMap(map['id'] as String, map);
    }).toList();
  }

  Future<void> guardar(Meta meta) async {
    final lista = await obtener();
    final idx = lista.indexWhere((m) => m.id == meta.id);
    if (idx >= 0) {
      lista[idx] = meta;
    } else {
      lista.add(meta);
    }
    await _persistir(lista);
  }

  Future<void> eliminar(String id) async {
    final lista = await obtener();
    lista.removeWhere((m) => m.id == id);
    await _persistir(lista);
  }

  Future<void> _persistir(List<Meta> lista) async {
    final prefs = await SharedPreferences.getInstance();
    final data = lista.map((m) => {'id': m.id, ...m.toMap()}).toList();
    await prefs.setString(_clave, jsonEncode(data));
  }
}
