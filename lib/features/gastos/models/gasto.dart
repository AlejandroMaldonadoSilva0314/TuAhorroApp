enum TipoTransaccion { ingreso, gasto }

class Gasto {
  final String id;
  final String titulo;
  final double monto;
  final String categoriaId;
  final DateTime fecha;
  final TipoTransaccion tipo;
  final String? bolsilloId;

  const Gasto({
    required this.id,
    required this.titulo,
    required this.monto,
    required this.categoriaId,
    required this.fecha,
    this.tipo = TipoTransaccion.gasto,
    this.bolsilloId,
  });

  Gasto copyWith({
    String? id,
    String? titulo,
    double? monto,
    String? categoriaId,
    DateTime? fecha,
    TipoTransaccion? tipo,
    String? bolsilloId,
  }) {
    return Gasto(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      monto: monto ?? this.monto,
      categoriaId: categoriaId ?? this.categoriaId,
      fecha: fecha ?? this.fecha,
      tipo: tipo ?? this.tipo,
      bolsilloId: bolsilloId ?? this.bolsilloId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'monto': monto,
      'categoria': categoriaId,
      'fecha': fecha.toIso8601String(),
      'tipo': tipo.name,
      if (bolsilloId != null) 'bolsilloId': bolsilloId,
    };
  }

  factory Gasto.fromMap(String id, Map<String, dynamic> map) {
    return Gasto(
      id: id,
      titulo: map['titulo'] as String,
      monto: (map['monto'] as num).toDouble(),
      categoriaId: map['categoria'] as String,
      fecha: DateTime.parse(map['fecha'] as String),
      tipo: map['tipo'] != null
          ? TipoTransaccion.values.byName(map['tipo'] as String)
          : TipoTransaccion.gasto,
      bolsilloId: map['bolsilloId'] as String?,
    );
  }

  @override
  String toString() =>
      'Gasto(id: $id, titulo: $titulo, monto: $monto, categoriaId: $categoriaId, fecha: $fecha, tipo: ${tipo.name})';
}
