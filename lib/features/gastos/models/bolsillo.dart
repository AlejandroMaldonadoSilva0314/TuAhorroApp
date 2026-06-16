class Bolsillo {
  final String id;
  final String nombre;
  final double saldoInicial;

  const Bolsillo({
    required this.id,
    required this.nombre,
    this.saldoInicial = 0,
  });

  Bolsillo copyWith({String? nombre, double? saldoInicial}) {
    return Bolsillo(
      id: id,
      nombre: nombre ?? this.nombre,
      saldoInicial: saldoInicial ?? this.saldoInicial,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'saldoInicial': saldoInicial,
    };
  }

  factory Bolsillo.fromMap(String id, Map<String, dynamic> map) {
    return Bolsillo(
      id: id,
      nombre: map['nombre'] as String,
      saldoInicial: (map['saldoInicial'] as num?)?.toDouble() ?? 0,
    );
  }
}
