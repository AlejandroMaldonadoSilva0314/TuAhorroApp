import '../models/gasto.dart';

/// Calcula indicadores del presupuesto semanal.
///
/// v1: presupuesto fijo guardado en SharedPreferences.
/// Futuras versiones pueden manejar presupuestos por categoría.
class PresupuestoSemanal {
  PresupuestoSemanal({DateTime? ahora}) : _ahora = ahora ?? DateTime.now();

  final DateTime _ahora;

  /// Lunes 00:00 de la semana actual.
  DateTime get _inicioSemana {
    final d = DateTime(_ahora.year, _ahora.month, _ahora.day);
    return d.subtract(Duration(days: d.weekday - 1));
  }

  /// Suma solo los gastos (no ingresos) de la semana en curso.
  double gastadoEstaSemana(List<Gasto> gastos) {
    final inicio = _inicioSemana;
    return gastos
        .where((g) =>
            g.tipo == TipoTransaccion.gasto &&
            !g.fecha.isBefore(inicio) &&
            g.fecha.isBefore(inicio.add(const Duration(days: 7))))
        .fold(0.0, (sum, g) => sum + g.monto);
  }

  /// Cuánto le queda al usuario esta semana.
  double disponible({
    required double presupuesto,
    required List<Gasto> gastos,
  }) {
    final restante = presupuesto - gastadoEstaSemana(gastos);
    return restante < 0 ? 0 : restante;
  }
}
