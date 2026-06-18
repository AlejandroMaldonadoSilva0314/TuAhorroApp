import 'package:flutter/material.dart';

enum TipoCategoria { ingreso, gasto, ambos }

class Categoria {
  final String id;
  final String nombre;
  final TipoCategoria tipo;
  final int iconoCodePoint;
  final bool esPredeterminada;

  const Categoria({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.iconoCodePoint,
    this.esPredeterminada = false,
  });

  IconData get icono => IconData(iconoCodePoint, fontFamily: 'MaterialIcons');

  Categoria copyWith({
    String? nombre,
    TipoCategoria? tipo,
    int? iconoCodePoint,
  }) {
    return Categoria(
      id: id,
      nombre: nombre ?? this.nombre,
      tipo: tipo ?? this.tipo,
      iconoCodePoint: iconoCodePoint ?? this.iconoCodePoint,
      esPredeterminada: esPredeterminada,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'tipo': tipo.name,
      'iconoCodePoint': iconoCodePoint,
      'esPredeterminada': esPredeterminada,
    };
  }

  factory Categoria.fromMap(String id, Map<String, dynamic> map) {
    return Categoria(
      id: id,
      nombre: map['nombre'] as String,
      tipo: TipoCategoria.values.byName(map['tipo'] as String),
      iconoCodePoint: map['iconoCodePoint'] as int,
      esPredeterminada: map['esPredeterminada'] as bool? ?? false,
    );
  }

  static const List<Categoria> predeterminadas = [
    Categoria(
      id: 'comida',
      nombre: 'Comida',
      tipo: TipoCategoria.gasto,
      iconoCodePoint: 0xe532, // restaurant_outlined
      esPredeterminada: true,
    ),
    Categoria(
      id: 'transporte',
      nombre: 'Transporte',
      tipo: TipoCategoria.gasto,
      iconoCodePoint: 0xe1d5, // directions_bus_outlined
      esPredeterminada: true,
    ),
    Categoria(
      id: 'servicios',
      nombre: 'Servicios',
      tipo: TipoCategoria.ambos,
      iconoCodePoint: 0xef6b, // receipt_long_outlined
      esPredeterminada: true,
    ),
    Categoria(
      id: 'entretenimiento',
      nombre: 'Entretenimiento',
      tipo: TipoCategoria.gasto,
      iconoCodePoint: 0xe404, // movie_outlined
      esPredeterminada: true,
    ),
    Categoria(
      id: 'salud',
      nombre: 'Salud',
      tipo: TipoCategoria.gasto,
      iconoCodePoint: 0xe399, // local_hospital_outlined
      esPredeterminada: true,
    ),
    Categoria(
      id: 'educacion',
      nombre: 'Educación',
      tipo: TipoCategoria.gasto,
      iconoCodePoint: 0xe559, // school_outlined
      esPredeterminada: true,
    ),
    Categoria(
      id: 'otros',
      nombre: 'Otros',
      tipo: TipoCategoria.ambos,
      iconoCodePoint: 0xe148, // category_outlined
      esPredeterminada: true,
    ),
  ];

  static const iconosDisponibles = [
    0xe532, // restaurant
    0xe1d5, // directions_bus
    0xef6b, // receipt_long
    0xe404, // movie
    0xe399, // local_hospital
    0xe559, // school
    0xe148, // category
    0xe59c, // shopping_cart
    0xe88a, // home
    0xe84f, // flight
    0xe263, // fitness_center
    0xea65, // pets
    0xe8cc, // phone_android
    0xe86c, // favorite
    0xe2bd, // local_cafe
    0xe54e, // work
    0xe87d, // card_giftcard
    0xef63, // savings
    0xe227, // attach_money
    0xe8e8, // star
  ];
}
