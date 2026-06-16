enum CategoriaGasto {
  comida,
  transporte,
  servicios,
  entretenimiento,
  salud,
  educacion,
  otros;

  String get nombre {
    const nombres = {
      CategoriaGasto.comida: 'Comida',
      CategoriaGasto.transporte: 'Transporte',
      CategoriaGasto.servicios: 'Servicios',
      CategoriaGasto.entretenimiento: 'Entretenimiento',
      CategoriaGasto.salud: 'Salud',
      CategoriaGasto.educacion: 'Educación',
      CategoriaGasto.otros: 'Otros',
    };
    return nombres[this]!;
  }
}

enum TipoTransaccion { ingreso, gasto }

class Gasto {
  final String id;
  final String titulo;
  final double monto;
  final CategoriaGasto categoria;
  final DateTime fecha;
  final TipoTransaccion tipo;

  const Gasto({
    required this.id,
    required this.titulo,
    required this.monto,
    required this.categoria,
    required this.fecha,
    this.tipo = TipoTransaccion.gasto,
  });

  Gasto copyWith({
    String? id,
    String? titulo,
    double? monto,
    CategoriaGasto? categoria,
    DateTime? fecha,
    TipoTransaccion? tipo,
  }) {
    return Gasto(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      monto: monto ?? this.monto,
      categoria: categoria ?? this.categoria,
      fecha: fecha ?? this.fecha,
      tipo: tipo ?? this.tipo,
    );
  }

  /// El [id] no va dentro del Map — sigue el patrón Firestore (doc.id separado).
  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'monto': monto,
      'categoria': categoria.name,
      'fecha': fecha.toIso8601String(),
      'tipo': tipo.name,
    };
  }

  factory Gasto.fromMap(String id, Map<String, dynamic> map) {
    return Gasto(
      id: id,
      titulo: map['titulo'] as String,
      monto: (map['monto'] as num).toDouble(),
      categoria: CategoriaGasto.values.byName(map['categoria'] as String),
      fecha: DateTime.parse(map['fecha'] as String),
      tipo: map['tipo'] != null
          ? TipoTransaccion.values.byName(map['tipo'] as String)
          : TipoTransaccion.gasto,
    );
  }

  @override
  String toString() =>
      'Gasto(id: $id, titulo: $titulo, monto: $monto, categoria: ${categoria.name}, fecha: $fecha, tipo: ${tipo.name})';
}
