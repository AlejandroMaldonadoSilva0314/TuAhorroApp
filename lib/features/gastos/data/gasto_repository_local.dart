import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/bolsillo.dart';
import '../models/categoria.dart';
import '../models/fiado.dart';
import '../models/gasto.dart';
import '../models/meta_ahorro.dart';
import 'gasto_repository.dart';

/// Persistencia local con SharedPreferences (clave-valor, lista serializada en JSON).
///
/// Misma forma de datos (Map vía toMap/fromMap) que se usará con Firestore:
/// al migrar, solo se reemplaza esta clase por una que lea/escriba documentos,
/// sin tocar la UI ni el contrato [GastoRepository].
class GastoRepositoryLocal implements GastoRepository {
  static const _clave = 'gastos';
  static const _clavePresupuesto = 'presupuesto_semanal';
  static const _claveBolsillos = 'bolsillos';
  static const _claveFiados = 'fiados';
  static const _claveMetas = 'metas_ahorro';
  static const _claveCategorias = 'categorias_custom';

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

  @override
  Future<double> obtenerPresupuestoSemanal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_clavePresupuesto) ?? 0;
  }

  @override
  Future<void> guardarPresupuestoSemanal(double monto) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_clavePresupuesto, monto);
  }

  @override
  Future<List<Bolsillo>> obtenerBolsillos() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_claveBolsillos);
    if (raw == null) return [];
    final lista = jsonDecode(raw) as List<dynamic>;
    return lista
        .map((item) {
          final map = item as Map<String, dynamic>;
          return Bolsillo.fromMap(map['id'] as String, map);
        })
        .toList();
  }

  @override
  Future<void> agregarBolsillo(Bolsillo bolsillo) async {
    final bolsillos = await obtenerBolsillos();
    bolsillos.add(bolsillo);
    await _guardarBolsillos(bolsillos);
  }

  @override
  Future<void> actualizarBolsillo(Bolsillo bolsillo) async {
    final bolsillos = await obtenerBolsillos();
    final i = bolsillos.indexWhere((b) => b.id == bolsillo.id);
    if (i != -1) bolsillos[i] = bolsillo;
    await _guardarBolsillos(bolsillos);
  }

  @override
  Future<void> eliminarBolsillo(String id) async {
    final bolsillos = await obtenerBolsillos();
    bolsillos.removeWhere((b) => b.id == id);
    await _guardarBolsillos(bolsillos);
  }

  Future<void> _guardarBolsillos(List<Bolsillo> bolsillos) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = bolsillos.map((b) => {'id': b.id, ...b.toMap()}).toList();
    await prefs.setString(_claveBolsillos, jsonEncode(lista));
  }

  @override
  Future<List<Fiado>> obtenerFiados() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_claveFiados);
    if (raw == null) return [];
    final lista = jsonDecode(raw) as List<dynamic>;
    return lista
        .map((item) {
          final map = item as Map<String, dynamic>;
          return Fiado.fromMap(map['id'] as String, map);
        })
        .toList();
  }

  @override
  Future<void> agregarFiado(Fiado fiado) async {
    final fiados = await obtenerFiados();
    fiados.add(fiado);
    await _guardarFiados(fiados);
  }

  @override
  Future<void> actualizarFiado(Fiado fiado) async {
    final fiados = await obtenerFiados();
    final i = fiados.indexWhere((f) => f.id == fiado.id);
    if (i != -1) fiados[i] = fiado;
    await _guardarFiados(fiados);
  }

  @override
  Future<void> eliminarFiado(String id) async {
    final fiados = await obtenerFiados();
    fiados.removeWhere((f) => f.id == id);
    await _guardarFiados(fiados);
  }

  Future<void> _guardarFiados(List<Fiado> fiados) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = fiados.map((f) => {'id': f.id, ...f.toMap()}).toList();
    await prefs.setString(_claveFiados, jsonEncode(lista));
  }

  @override
  Future<List<MetaAhorro>> obtenerMetas() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_claveMetas);
    if (raw == null) return [];
    final lista = jsonDecode(raw) as List<dynamic>;
    return lista
        .map((item) {
          final map = item as Map<String, dynamic>;
          return MetaAhorro.fromMap(map['id'] as String, map);
        })
        .toList();
  }

  @override
  Future<void> agregarMeta(MetaAhorro meta) async {
    final metas = await obtenerMetas();
    metas.add(meta);
    await _guardarMetas(metas);
  }

  @override
  Future<void> actualizarMeta(MetaAhorro meta) async {
    final metas = await obtenerMetas();
    final i = metas.indexWhere((m) => m.id == meta.id);
    if (i != -1) metas[i] = meta;
    await _guardarMetas(metas);
  }

  @override
  Future<void> eliminarMeta(String id) async {
    final metas = await obtenerMetas();
    metas.removeWhere((m) => m.id == id);
    await _guardarMetas(metas);
  }

  Future<void> _guardarMetas(List<MetaAhorro> metas) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = metas.map((m) => {'id': m.id, ...m.toMap()}).toList();
    await prefs.setString(_claveMetas, jsonEncode(lista));
  }

  Future<void> _guardarTodos(List<Gasto> gastos) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = gastos.map((g) => {'id': g.id, ...g.toMap()}).toList();
    await prefs.setString(_clave, jsonEncode(lista));
  }

  @override
  Future<List<Categoria>> obtenerCategorias() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_claveCategorias);
    final custom = <Categoria>[];
    if (raw != null) {
      final lista = jsonDecode(raw) as List<dynamic>;
      custom.addAll(lista.map((item) {
        final map = item as Map<String, dynamic>;
        return Categoria.fromMap(map['id'] as String, map);
      }));
    }
    return [...Categoria.predeterminadas, ...custom];
  }

  @override
  Future<void> agregarCategoria(Categoria categoria) async {
    final custom = await _obtenerCustomCategorias();
    custom.add(categoria);
    await _guardarCategorias(custom);
  }

  @override
  Future<void> actualizarCategoria(Categoria categoria) async {
    final custom = await _obtenerCustomCategorias();
    final i = custom.indexWhere((c) => c.id == categoria.id);
    if (i != -1) custom[i] = categoria;
    await _guardarCategorias(custom);
  }

  @override
  Future<void> eliminarCategoria(String id) async {
    final custom = await _obtenerCustomCategorias();
    custom.removeWhere((c) => c.id == id);
    await _guardarCategorias(custom);
  }

  Future<List<Categoria>> _obtenerCustomCategorias() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_claveCategorias);
    if (raw == null) return [];
    final lista = jsonDecode(raw) as List<dynamic>;
    return lista
        .map((item) {
          final map = item as Map<String, dynamic>;
          return Categoria.fromMap(map['id'] as String, map);
        })
        .toList();
  }

  Future<void> _guardarCategorias(List<Categoria> categorias) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = categorias.map((c) => {'id': c.id, ...c.toMap()}).toList();
    await prefs.setString(_claveCategorias, jsonEncode(lista));
  }
}
