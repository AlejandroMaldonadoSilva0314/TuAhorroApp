import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme({
    required this.id,
    required this.name,
    required this.gradientColors,
    required this.seedColor,
  });

  final String id;
  final String name;
  final List<Color> gradientColors;
  final Color seedColor;

  LinearGradient get gradient => LinearGradient(
        colors: gradientColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  LinearGradient get gradientCard => LinearGradient(
        colors: [gradientColors[1], gradientColors[2]],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );

  ThemeData toThemeData() => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      );

  ThemeData toDarkThemeData() => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      );
}

class AppThemes {
  static const List<AppTheme> all = [
    AppTheme(
      id: 'premium',
      name: 'Premium',
      gradientColors: [
        Color(0xFF4A0E8F),
        Color(0xFF7C3AED),
        Color(0xFF1C1C1E),
      ],
      seedColor: Color(0xFF5B21B6),
    ),
    AppTheme(
      id: 'aurora',
      name: 'Aurora',
      gradientColors: [
        Color(0xFF1E3A5F),
        Color(0xFF06B6D4),
        Color(0xFF6D28D9),
      ],
      seedColor: Color(0xFF0369A1),
    ),
    AppTheme(
      id: 'emerald',
      name: 'Emerald',
      gradientColors: [
        Color(0xFF065F46),
        Color(0xFF0D9488),
        Color(0xFF1E3A8A),
      ],
      seedColor: Color(0xFF047857),
    ),
    AppTheme(
      id: 'sunset',
      name: 'Sunset',
      gradientColors: [
        Color(0xFFEA580C),
        Color(0xFFF43F5E),
        Color(0xFFDB2777),
      ],
      seedColor: Color(0xFFEA580C),
    ),
    AppTheme(
      id: 'ruby',
      name: 'Ruby',
      gradientColors: [
        Color(0xFF881337),
        Color(0xFFA21CAF),
        Color(0xFF6B21A8),
      ],
      seedColor: Color(0xFF9D174D),
    ),
    AppTheme(
      id: 'ocean',
      name: 'Ocean',
      gradientColors: [
        Color(0xFF1E3A8A),
        Color(0xFF2563EB),
        Color(0xFF0891B2),
      ],
      seedColor: Color(0xFF1D4ED8),
    ),
    AppTheme(
      id: 'midnight',
      name: 'Midnight',
      gradientColors: [
        Color(0xFF1C1C1E),
        Color(0xFF374151),
        Color(0xFF4C1D95),
      ],
      seedColor: Color(0xFF4B5563),
    ),
    AppTheme(
      id: 'lavender',
      name: 'Lavender',
      gradientColors: [
        Color(0xFFA855F7),
        Color(0xFF7C3AED),
        Color(0xFF1D4ED8),
      ],
      seedColor: Color(0xFF7C3AED),
    ),
  ];

  static AppTheme byId(String id) =>
      all.firstWhere((t) => t.id == id, orElse: () => all.first);
}
