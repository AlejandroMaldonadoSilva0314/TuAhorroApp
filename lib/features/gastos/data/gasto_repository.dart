import '../models/gasto.dart';

/// Contrato que toda fuente de datos de gastos debe implementar.
/// La UI depende solo de esta abstracción, nunca de la implementación concreta.
abstract class GastoRepository {
  Future<List<Gasto>> obtenerGastos();
  Future<void> agregarGasto(Gasto gasto);
  Future<void> eliminarGasto(String id);
}
