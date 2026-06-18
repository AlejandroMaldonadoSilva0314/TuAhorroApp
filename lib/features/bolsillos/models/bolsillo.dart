class Bolsillo {
  final String id;
  final String nombre;
  final String emoji;
  final double objetivo;
  final double saldo;

  const Bolsillo({
    required this.id,
    required this.nombre,
    this.emoji = '💰',
    this.objetivo = 0,
    required this.saldo,
  });

  double get progreso =>
      objetivo > 0 ? (saldo / objetivo).clamp(0.0, 1.0) : 0.0;

  Bolsillo copyWith({
    String? nombre,
    String? emoji,
    double? objetivo,
    double? saldo,
  }) =>
      Bolsillo(
        id: id,
        nombre: nombre ?? this.nombre,
        emoji: emoji ?? this.emoji,
        objetivo: objetivo ?? this.objetivo,
        saldo: saldo ?? this.saldo,
      );

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'emoji': emoji,
        'objetivo': objetivo,
        'saldo': saldo,
      };

  factory Bolsillo.fromMap(String id, Map<String, dynamic> map) => Bolsillo(
        id: id,
        nombre: map['nombre'] as String,
        emoji: (map['emoji'] as String?) ?? '💰',
        objetivo: (map['objetivo'] as num?)?.toDouble() ?? 0,
        saldo: (map['saldo'] as num?)?.toDouble() ?? 0,
      );
}
