import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/gasto.dart';
import 'gasto_repository.dart';

/// Persistencia local con SharedPreferences (clave-valor, lista serializada en JSON).
///
/// Misma forma de datos (Map vía toMap/fromMap) que se usará con Firestore:
/// al migrar, solo se reemplaza esta clase por una que lea/escriba documentos,
/// sin tocar la UI ni el contrato [GastoRepository].
class GastoRepositoryLocal implements GastoRepository {
  static const _clave = 'gastos';

  @override
  Future<List<Gasto>> obtenerGastos() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_clave);
    if (raw == null) return [];

    final lista = jsonDecode(raw) as List<dynamic>;
    return lista
        .map((item) {
          final map = item as Map<String, dynamic>;
          return Gasto.fromMap(map['id'] as String, map);
        })
        .toList();
  }

  @override
  Future<void> agregarGasto(Gasto gasto) async {
    final gastos = await obtenerGastos();
    gastos.add(gasto);
    await _guardarTodos(gastos);
  }

  @override
  Future<void> eliminarGasto(String id) async {
    final gastos = await obtenerGastos();
    gastos.removeWhere((g) => g.id == id);
    await _guardarTodos(gastos);
  }

  Future<void> _guardarTodos(List<Gasto> gastos) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = gastos.map((g) => {'id': g.id, ...g.toMap()}).toList();
    await prefs.setString(_clave, jsonEncode(lista));
  }
}
