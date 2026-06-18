class Meta {
  final String id;
  final String nombre;
  final String emoji;
  final double objetivo;
  final double ahorrado;
  final DateTime? fechaObjetivo;

  const Meta({
    required this.id,
    required this.nombre,
    this.emoji = '🎯',
    required this.objetivo,
    this.ahorrado = 0,
    this.fechaObjetivo,
  });

  double get progreso =>
      objetivo > 0 ? (ahorrado / objetivo).clamp(0.0, 1.0) : 0.0;
  bool get completada => ahorrado >= objetivo && objetivo > 0;
  double get faltante => (objetivo - ahorrado).clamp(0, double.infinity);

  Meta copyWith({
    String? nombre,
    String? emoji,
    double? objetivo,
    double? ahorrado,
    DateTime? fechaObjetivo,
  }) =>
      Meta(
        id: id,
        nombre: nombre ?? this.nombre,
        emoji: emoji ?? this.emoji,
        objetivo: objetivo ?? this.objetivo,
        ahorrado: ahorrado ?? this.ahorrado,
        fechaObjetivo: fechaObjetivo ?? this.fechaObjetivo,
      );

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'emoji': emoji,
        'objetivo': objetivo,
        'ahorrado': ahorrado,
        'fechaObjetivo': fechaObjetivo?.toIso8601String(),
      };

  factory Meta.fromMap(String id, Map<String, dynamic> map) => Meta(
        id: id,
        nombre: map['nombre'] as String,
        emoji: (map['emoji'] as String?) ?? '🎯',
        objetivo: (map['objetivo'] as num).toDouble(),
        ahorrado: (map['ahorrado'] as num?)?.toDouble() ?? 0,
        fechaObjetivo: map['fechaObjetivo'] != null
            ? DateTime.parse(map['fechaObjetivo'] as String)
            : null,
      );
}
