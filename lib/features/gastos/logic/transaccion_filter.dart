import '../models/gasto.dart';
import '../models/transaccion_filtro.dart';

class TransaccionFilter {
  List<Gasto> aplicar(List<Gasto> gastos, TransaccionFiltro filtro) {
    if (!filtro.estaActivo) return gastos;

    return gastos.where((g) {
      if (filtro.busqueda != null && filtro.busqueda!.isNotEmpty) {
        final query = filtro.busqueda!.toLowerCase();
        if (!g.titulo.toLowerCase().contains(query)) return false;
      }

      if (filtro.categoriaId != null && g.categoriaId != filtro.categoriaId) {
        return false;
      }

      if (filtro.tipo != null && g.tipo != filtro.tipo) {
        return false;
      }

      if (filtro.fechaDesde != null && g.fecha.isBefore(filtro.fechaDesde!)) {
        return false;
      }

      if (filtro.fechaHasta != null) {
        final finDia = DateTime(
          filtro.fechaHasta!.year,
          filtro.fechaHasta!.month,
          filtro.fechaHasta!.day,
          23, 59, 59,
        );
        if (g.fecha.isAfter(finDia)) return false;
      }

      return true;
    }).toList();
  }
}
