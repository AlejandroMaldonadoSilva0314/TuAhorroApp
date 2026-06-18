import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bolsillo.dart';

class BolsilloRepository {
  static const _clave = 'bolsillos_v1';

  Future<List<Bolsillo>> obtener() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_clave);
    if (raw == null) return [];
    final lista = jsonDecode(raw) as List<dynamic>;
    return lista.map((item) {
      final map = item as Map<String, dynamic>;
      return Bolsillo.fromMap(map['id'] as String, map);
    }).toList();
  }

  Future<void> guardar(Bolsillo bolsillo) async {
    final lista = await obtener();
    final idx = lista.indexWhere((b) => b.id == bolsillo.id);
    if (idx >= 0) {
      lista[idx] = bolsillo;
    } else {
      lista.add(bolsillo);
    }
    await _persistir(lista);
  }

  Future<void> eliminar(String id) async {
    final lista = await obtener();
    lista.removeWhere((b) => b.id == id);
    await _persistir(lista);
  }

  Future<void> _persistir(List<Bolsillo> lista) async {
    final prefs = await SharedPreferences.getInstance();
    final data = lista.map((b) => {'id': b.id, ...b.toMap()}).toList();
    await prefs.setString(_clave, jsonEncode(data));
  }
}
