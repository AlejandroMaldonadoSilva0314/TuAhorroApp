import '../../gastos/models/gasto.dart';

class ResumenSemanal {
  final double presupuesto;
  final double gastado;

  const ResumenSemanal({required this.presupuesto, required this.gastado});

  double get disponible => presupuesto - gastado;
  double get porcentajeUsado =>
      presupuesto > 0 ? (gastado / presupuesto).clamp(0.0, 1.0) : 0.0;
  bool get excedido => gastado > presupuesto;
}

class PresupuestoSemanalService {
  const PresupuestoSemanalService();

  static (DateTime, DateTime) rangoSemanaActual([DateTime? ahora]) {
    final hoy = ahora ?? DateTime.now();
    final inicio = hoy.subtract(Duration(days: hoy.weekday - 1));
    final inicioLimpio = DateTime(inicio.year, inicio.month, inicio.day);
    final fin = inicioLimpio
        .add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    return (inicioLimpio, fin);
  }

  double gastosSemana(List<Gasto> gastos, [DateTime? ahora]) {
    final (inicio, fin) = rangoSemanaActual(ahora);
    return gastos
        .where((g) =>
            g.tipo == TipoTransaccion.gasto &&
            !g.fecha.isBefore(inicio) &&
            !g.fecha.isAfter(fin))
        .fold(0.0, (sum, g) => sum + g.monto);
  }

  ResumenSemanal calcularResumen(
      double presupuesto, List<Gasto> gastos, [DateTime? ahora]) {
    return ResumenSemanal(
      presupuesto: presupuesto,
      gastado: gastosSemana(gastos, ahora),
    );
  }

  /// Disponible diario para "Plata para Hoy".
  double disponibleDiario(double presupuesto, List<Gasto> gastos,
      [DateTime? ahora]) {
    final hoy = ahora ?? DateTime.now();
    final diasRestantes = 7 - hoy.weekday + 1;
    final resumen = calcularResumen(presupuesto, gastos, ahora);
    if (resumen.disponible <= 0 || diasRestantes <= 0) return 0;
    return resumen.disponible / diasRestantes;
  }
}
