/// Calcula cuánto puede gastar el usuario hoy sin descuadrar su semana.
///
/// v1: saldo ÷ días restantes de la semana.
/// Futuras versiones pueden recibir un presupuesto semanal personalizado.
class PlataParaHoy {
  PlataParaHoy({DateTime? ahora}) : _ahora = ahora ?? DateTime.now();

  final DateTime _ahora;

  /// Días que faltan para terminar la semana (lunes = 1 … domingo = 7).
  /// Domingo → 1 para evitar división por cero y que el usuario
  /// vea lo que le queda solo para hoy.
  int get diasRestantes {
    final faltan = DateTime.daysPerWeek - _ahora.weekday;
    return faltan == 0 ? 1 : faltan + 1; // +1 porque hoy cuenta
  }

  /// Monto disponible para gastar hoy.
  /// Si hay presupuesto semanal, usa [disponibleSemanal] en vez de [saldo].
  double calcular({
    required double saldo,
    double? disponibleSemanal,
  }) {
    final base = disponibleSemanal ?? saldo;
    if (base <= 0) return 0;
    return base / diasRestantes;
  }
}
