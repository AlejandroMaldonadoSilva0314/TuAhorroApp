import '../models/gasto.dart';

class EstadisticasMensuales {
  final double totalGastos;
  final double totalIngresos;
  final double ahorroNeto;
  final String? categoriaMayorGastoId;
  final double montoMayorCategoria;
  final List<MapEntry<String, double>> top3Categorias;
  final Map<String, double> gastosPorCategoria;

  const EstadisticasMensuales({
    required this.totalGastos,
    required this.totalIngresos,
    required this.ahorroNeto,
    required this.categoriaMayorGastoId,
    required this.montoMayorCategoria,
    required this.top3Categorias,
    required this.gastosPorCategoria,
  });
}

class EstadisticasCalculator {
  EstadisticasMensuales calcular(List<Gasto> gastos, int anio, int mes) {
    final delMes = gastos.where((g) => g.fecha.year == anio && g.fecha.month == mes).toList();

    final soloGastos = delMes.where((g) => g.tipo == TipoTransaccion.gasto);
    final soloIngresos = delMes.where((g) => g.tipo == TipoTransaccion.ingreso);

    final totalGastos = soloGastos.fold(0.0, (s, g) => s + g.monto);
    final totalIngresos = soloIngresos.fold(0.0, (s, g) => s + g.monto);

    final porCategoria = <String, double>{};
    for (final g in soloGastos) {
      porCategoria[g.categoriaId] = (porCategoria[g.categoriaId] ?? 0) + g.monto;
    }

    final ordenadas = porCategoria.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return EstadisticasMensuales(
      totalGastos: totalGastos,
      totalIngresos: totalIngresos,
      ahorroNeto: totalIngresos - totalGastos,
      categoriaMayorGastoId: ordenadas.isNotEmpty ? ordenadas.first.key : null,
      montoMayorCategoria: ordenadas.isNotEmpty ? ordenadas.first.value : 0,
      top3Categorias: ordenadas.take(3).toList(),
      gastosPorCategoria: porCategoria,
    );
  }
}
