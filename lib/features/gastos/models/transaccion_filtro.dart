import 'gasto.dart';

class TransaccionFiltro {
  final String? busqueda;
  final String? categoriaId;
  final TipoTransaccion? tipo;
  final DateTime? fechaDesde;
  final DateTime? fechaHasta;

  const TransaccionFiltro({
    this.busqueda,
    this.categoriaId,
    this.tipo,
    this.fechaDesde,
    this.fechaHasta,
  });

  bool get estaActivo =>
      (busqueda != null && busqueda!.isNotEmpty) ||
      categoriaId != null ||
      tipo != null ||
      fechaDesde != null ||
      fechaHasta != null;

  TransaccionFiltro copyWith({
    String? busqueda,
    String? categoriaId,
    TipoTransaccion? tipo,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    bool limpiarBusqueda = false,
    bool limpiarCategoria = false,
    bool limpiarTipo = false,
    bool limpiarFechaDesde = false,
    bool limpiarFechaHasta = false,
  }) {
    return TransaccionFiltro(
      busqueda: limpiarBusqueda ? null : (busqueda ?? this.busqueda),
      categoriaId: limpiarCategoria ? null : (categoriaId ?? this.categoriaId),
      tipo: limpiarTipo ? null : (tipo ?? this.tipo),
      fechaDesde: limpiarFechaDesde ? null : (fechaDesde ?? this.fechaDesde),
      fechaHasta: limpiarFechaHasta ? null : (fechaHasta ?? this.fechaHasta),
    );
  }

  static const vacio = TransaccionFiltro();
}
