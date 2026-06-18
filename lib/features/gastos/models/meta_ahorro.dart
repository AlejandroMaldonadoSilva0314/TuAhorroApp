class MetaAhorro {
  final String id;
  final String nombre;
  final double montoObjetivo;
  final double montoActual;
  final DateTime fechaCreacion;
  final bool completada;

  const MetaAhorro({
    required this.id,
    required this.nombre,
    required this.montoObjetivo,
    this.montoActual = 0,
    required this.fechaCreacion,
    this.completada = false,
  });

  double get progreso => montoObjetivo > 0 ? (montoActual / montoObjetivo).clamp(0.0, 1.0) : 0;
  double get faltante => (montoObjetivo - montoActual).clamp(0.0, double.infinity);

  MetaAhorro copyWith({
    String? nombre,
    double? montoObjetivo,
    double? montoActual,
    bool? completada,
  }) {
    return MetaAhorro(
      id: id,
      nombre: nombre ?? this.nombre,
      montoObjetivo: montoObjetivo ?? this.montoObjetivo,
      montoActual: montoActual ?? this.montoActual,
      fechaCreacion: fechaCreacion,
      completada: completada ?? this.completada,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'montoObjetivo': montoObjetivo,
      'montoActual': montoActual,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'completada': completada,
    };
  }

  factory MetaAhorro.fromMap(String id, Map<String, dynamic> map) {
    return MetaAhorro(
      id: id,
      nombre: map['nombre'] as String,
      montoObjetivo: (map['montoObjetivo'] as num).toDouble(),
      montoActual: (map['montoActual'] as num?)?.toDouble() ?? 0,
      fechaCreacion: DateTime.parse(map['fechaCreacion'] as String),
      completada: map['completada'] as bool? ?? false,
    );
  }
}
