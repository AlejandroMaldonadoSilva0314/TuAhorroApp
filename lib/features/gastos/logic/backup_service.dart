import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/gasto_repository.dart';
import '../models/bolsillo.dart';
import '../models/fiado.dart';
import '../models/gasto.dart';
import '../models/meta_ahorro.dart';

class BackupService {
  static const _version = 1;

  final GastoRepository repository;

  BackupService(this.repository);

  Future<Map<String, dynamic>> _leerTodo() async {
    final resultados = await Future.wait([
      repository.obtenerGastos(),
      repository.obtenerBolsillos(),
      repository.obtenerFiados(),
      repository.obtenerMetas(),
      repository.obtenerPresupuestoSemanal(),
    ]);

    return {
      'version': _version,
      'fecha': DateTime.now().toIso8601String(),
      'gastos': (resultados[0] as List<Gasto>)
          .map((g) => {'id': g.id, ...g.toMap()})
          .toList(),
      'bolsillos': (resultados[1] as List<Bolsillo>)
          .map((b) => {'id': b.id, ...b.toMap()})
          .toList(),
      'fiados': (resultados[2] as List<Fiado>)
          .map((f) => {'id': f.id, ...f.toMap()})
          .toList(),
      'metas': (resultados[3] as List<MetaAhorro>)
          .map((m) => {'id': m.id, ...m.toMap()})
          .toList(),
      'presupuestoSemanal': resultados[4] as double,
    };
  }

  Future<XFile> exportar() async {
    final datos = await _leerTodo();
    final json = const JsonEncoder.withIndent('  ').convert(datos);
    final dir = await getTemporaryDirectory();
    final archivo = File('${dir.path}/tuahorro_backup.json');
    await archivo.writeAsString(json);
    return XFile(archivo.path, mimeType: 'application/json');
  }

  Future<void> compartir() async {
    final archivo = await exportar();
    await Share.shareXFiles([archivo], text: 'Respaldo TuAhorro');
  }

  Future<Map<String, dynamic>?> seleccionarArchivo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.single.path == null) return null;
    final contenido = await File(result.files.single.path!).readAsString();
    return jsonDecode(contenido) as Map<String, dynamic>;
  }

  String? validar(Map<String, dynamic> datos) {
    if (datos['version'] == null) return 'Archivo sin versión.';
    if (datos['version'] is! int) return 'Versión inválida.';
    if (datos['gastos'] is! List) return 'Falta la lista de gastos.';
    if (datos['bolsillos'] is! List) return 'Falta la lista de bolsillos.';
    if (datos['fiados'] is! List) return 'Falta la lista de fiados.';
    if (datos['metas'] is! List) return 'Falta la lista de metas.';
    if (datos['presupuestoSemanal'] is! num) return 'Falta el presupuesto.';

    try {
      for (final item in datos['gastos'] as List) {
        final map = item as Map<String, dynamic>;
        Gasto.fromMap(map['id'] as String, map);
      }
      for (final item in datos['bolsillos'] as List) {
        final map = item as Map<String, dynamic>;
        Bolsillo.fromMap(map['id'] as String, map);
      }
      for (final item in datos['fiados'] as List) {
        final map = item as Map<String, dynamic>;
        Fiado.fromMap(map['id'] as String, map);
      }
      for (final item in datos['metas'] as List) {
        final map = item as Map<String, dynamic>;
        MetaAhorro.fromMap(map['id'] as String, map);
      }
    } catch (e) {
      return 'Datos corruptos: $e';
    }

    return null;
  }

  Future<void> importar(Map<String, dynamic> datos) async {
    final gastos = (datos['gastos'] as List)
        .map((item) {
          final map = item as Map<String, dynamic>;
          return Gasto.fromMap(map['id'] as String, map);
        })
        .toList();

    final bolsillos = (datos['bolsillos'] as List)
        .map((item) {
          final map = item as Map<String, dynamic>;
          return Bolsillo.fromMap(map['id'] as String, map);
        })
        .toList();

    final fiados = (datos['fiados'] as List)
        .map((item) {
          final map = item as Map<String, dynamic>;
          return Fiado.fromMap(map['id'] as String, map);
        })
        .toList();

    final metas = (datos['metas'] as List)
        .map((item) {
          final map = item as Map<String, dynamic>;
          return MetaAhorro.fromMap(map['id'] as String, map);
        })
        .toList();

    final presupuesto = (datos['presupuestoSemanal'] as num).toDouble();

    for (final g in gastos) {
      await repository.agregarGasto(g);
    }
    for (final b in bolsillos) {
      await repository.agregarBolsillo(b);
    }
    for (final f in fiados) {
      await repository.agregarFiado(f);
    }
    for (final m in metas) {
      await repository.agregarMeta(m);
    }
    await repository.guardarPresupuestoSemanal(presupuesto);
  }
}
