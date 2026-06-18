enum TipoFiado { porCobrar, porPagar }

class Fiado {
  final String id;
  final String nombre;
  final double monto;
  final DateTime fecha;
  final TipoFiado tipo;
  final String? nota;
  final bool pagado;

  const Fiado({
    required this.id,
    required this.nombre,
    required this.monto,
    required this.fecha,
    required this.tipo,
    this.nota,
    this.pagado = false,
  });

  Fiado copyWith({
    String? nombre,
    double? monto,
    TipoFiado? tipo,
    String? nota,
    bool? pagado,
  }) {
    return Fiado(
      id: id,
      nombre: nombre ?? this.nombre,
      monto: monto ?? this.monto,
      fecha: fecha,
      tipo: tipo ?? this.tipo,
      nota: nota ?? this.nota,
      pagado: pagado ?? this.pagado,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'monto': monto,
      'fecha': fecha.toIso8601String(),
      'tipo': tipo.name,
      if (nota != null) 'nota': nota,
      'pagado': pagado,
    };
  }

  factory Fiado.fromMap(String id, Map<String, dynamic> map) {
    return Fiado(
      id: id,
      nombre: map['nombre'] as String,
      monto: (map['monto'] as num).toDouble(),
      fecha: DateTime.parse(map['fecha'] as String),
      tipo: TipoFiado.values.byName(map['tipo'] as String),
      nota: map['nota'] as String?,
      pagado: map['pagado'] as bool? ?? false,
    );
  }
}
