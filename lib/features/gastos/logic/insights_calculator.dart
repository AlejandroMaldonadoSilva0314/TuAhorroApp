import '../models/gasto.dart';

class InsightResult {
  final String? categoriaMayorId;
  final double montoCategoriaMayor;
  final double promedioDiario;
  final double gastoSemanaActual;
  final double gastoSemanaAnterior;
  final double porcentajeCambio;
  final List<String> mensajes;

  const InsightResult({
    required this.categoriaMayorId,
    required this.montoCategoriaMayor,
    required this.promedioDiario,
    required this.gastoSemanaActual,
    required this.gastoSemanaAnterior,
    required this.porcentajeCambio,
    required this.mensajes,
  });
}

class InsightsCalculator {
  InsightsCalculator({DateTime? ahora, this.nombreCategoria})
      : _ahora = ahora ?? DateTime.now();

  final DateTime _ahora;
  final String Function(String id)? nombreCategoria;

  DateTime get _inicioSemanaActual {
    final d = DateTime(_ahora.year, _ahora.month, _ahora.day);
    return d.subtract(Duration(days: d.weekday - 1));
  }

  DateTime get _inicioSemanaAnterior =>
      _inicioSemanaActual.subtract(const Duration(days: 7));

  List<Gasto> _soloGastos(List<Gasto> gastos) =>
      gastos.where((g) => g.tipo == TipoTransaccion.gasto).toList();

  List<Gasto> _enRango(List<Gasto> gastos, DateTime desde, DateTime hasta) =>
      gastos.where((g) => !g.fecha.isBefore(desde) && g.fecha.isBefore(hasta)).toList();

  InsightResult calcular(List<Gasto> todosLosGastos) {
    final gastos = _soloGastos(todosLosGastos);
    final semanaActual = _enRango(gastos, _inicioSemanaActual, _inicioSemanaActual.add(const Duration(days: 7)));
    final semanaAnterior = _enRango(gastos, _inicioSemanaAnterior, _inicioSemanaActual);

    final totalActual = semanaActual.fold(0.0, (s, g) => s + g.monto);
    final totalAnterior = semanaAnterior.fold(0.0, (s, g) => s + g.monto);

    final porCategoria = <String, double>{};
    for (final g in semanaActual) {
      porCategoria[g.categoriaId] = (porCategoria[g.categoriaId] ?? 0) + g.monto;
    }
    String? categoriaMayorId;
    double montoMayor = 0;
    for (final e in porCategoria.entries) {
      if (e.value > montoMayor) {
        montoMayor = e.value;
        categoriaMayorId = e.key;
      }
    }

    final diasTranscurridos = _ahora.weekday;
    final promedio = diasTranscurridos > 0 ? totalActual / diasTranscurridos : 0.0;

    double porcentaje = 0;
    if (totalAnterior > 0) {
      porcentaje = ((totalActual - totalAnterior) / totalAnterior) * 100;
    }

    final mensajes = <String>[];
    if (categoriaMayorId != null) {
      final nombre = nombreCategoria?.call(categoriaMayorId) ?? categoriaMayorId;
      mensajes.add('Tu mayor gasto fue ${nombre.toLowerCase()}.');
    }
    if (totalAnterior > 0) {
      if (porcentaje < 0) {
        mensajes.add('Reduciste tus gastos un ${porcentaje.abs().toStringAsFixed(0)}%.');
      } else if (porcentaje > 0) {
        mensajes.add('Gastaste ${porcentaje.toStringAsFixed(0)}% más que la semana pasada.');
      } else {
        mensajes.add('Gastaste igual que la semana pasada.');
      }
    }
    if (categoriaMayorId != null && totalActual > 0) {
      final nombre = nombreCategoria?.call(categoriaMayorId) ?? categoriaMayorId;
      final porcentajeCategoria = (montoMayor / totalActual * 100).toStringAsFixed(0);
      mensajes.add('$nombre representa el $porcentajeCategoria% de tus gastos.');
    }
    if (semanaActual.isEmpty && semanaAnterior.isEmpty) {
      mensajes.add('Registra gastos para ver tus insights.');
    }

    return InsightResult(
      categoriaMayorId: categoriaMayorId,
      montoCategoriaMayor: montoMayor,
      promedioDiario: promedio,
      gastoSemanaActual: totalActual,
      gastoSemanaAnterior: totalAnterior,
      porcentajeCambio: porcentaje,
      mensajes: mensajes,
    );
  }
}
