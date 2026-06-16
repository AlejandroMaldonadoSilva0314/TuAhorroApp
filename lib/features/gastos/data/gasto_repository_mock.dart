import '../models/gasto.dart';
import 'gasto_repository.dart';

class GastoRepositoryMock implements GastoRepository {
  // Datos simulados en memoria — misma estructura que usarías en Firestore.
  final List<Map<String, dynamic>> _db = [
    {
      'id': 'gasto-001',
      'titulo': 'Almuerzo ejecutivo',
      'monto': 15000.0,
      'categoria': 'comida',
      'fecha': '2026-06-14T12:30:00.000',
      'tipo': 'gasto',
    },
    {
      'id': 'gasto-002',
      'titulo': 'Transmilenio recarga',
      'monto': 6000.0,
      'categoria': 'transporte',
      'fecha': '2026-06-15T07:45:00.000',
      'tipo': 'gasto',
    },
    {
      'id': 'gasto-003',
      'titulo': 'Plan de datos Claro',
      'monto': 35900.0,
      'categoria': 'servicios',
      'fecha': '2026-06-16T09:00:00.000',
      'tipo': 'gasto',
    },
    {
      'id': 'ingreso-001',
      'titulo': 'Salario',
      'monto': 2500000.0,
      'categoria': 'otros',
      'fecha': '2026-06-15T08:00:00.000',
      'tipo': 'ingreso',
    },
    {
      'id': 'ingreso-002',
      'titulo': 'Freelance diseño web',
      'monto': 450000.0,
      'categoria': 'otros',
      'fecha': '2026-06-16T10:00:00.000',
      'tipo': 'ingreso',
    },
  ];

  /// Simula latencia de red (200 ms).
  static const _latencia = Duration(milliseconds: 200);

  @override
  Future<List<Gasto>> obtenerGastos() async {
    await Future.delayed(_latencia);
    return _db
        .map((map) => Gasto.fromMap(map['id'] as String, map))
        .toList();
  }

  @override
  Future<void> agregarGasto(Gasto gasto) async {
    await Future.delayed(_latencia);
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    _db.add({'id': id, ...gasto.toMap()});
  }

  @override
  Future<void> eliminarGasto(String id) async {
    await Future.delayed(_latencia);
    _db.removeWhere((map) => map['id'] == id);
  }

  double _presupuesto = 0;

  @override
  Future<double> obtenerPresupuestoSemanal() async => _presupuesto;

  @override
  Future<void> guardarPresupuestoSemanal(double monto) async {
    _presupuesto = monto;
  }
}
