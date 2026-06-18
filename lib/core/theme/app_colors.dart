import 'package:flutter/material.dart';

export 'app_design_system.dart';

// Extension methods on ColorScheme for semantic tokens (ingresos, gastos, etc.)
// The static color constants live in AppColors (app_design_system.dart).
extension ColorSchemeTokens on ColorScheme {
  bool get _isDark => brightness == Brightness.dark;

  Color get positivo => _isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A);
  Color get positivoContainer => _isDark ? const Color(0xFF052E16) : const Color(0xFFE8F8EF);

  Color get negativo => error;
  Color get negativoContainer => errorContainer;

  Color get ahorro => _isDark ? const Color(0xFFA78BFA) : const Color(0xFF3B6AE8);
  Color get alerta => _isDark ? const Color(0xFFFFB86C) : const Color(0xFFD97706);

  // Todos los gradientes de esta extensión son suficientemente vívidos para texto blanco.
  Color get onAccentSurface => Colors.white;
  Color get onGradientSurface => Colors.white;
  Color get onGradientSurfaceVariant => Colors.white.withValues(alpha: 0.75);
  Color get onGradientSubtle => Colors.white.withValues(alpha: 0.55);

  LinearGradient get heroGradient {
    final p = primary;
    if (_isDark) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(p, Colors.black, 0.28)!,
          p,
          Color.lerp(p, Colors.white, 0.30)!,
        ],
        stops: const [0.0, 0.55, 1.0],
      );
    }
    // Light: derivado de primary + secondary del tema — cada tema tiene su propio gradiente
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.lerp(p, Colors.black, 0.20)!,
        p,
        Color.lerp(p, secondary, 0.55)!,
      ],
      stops: const [0.0, 0.55, 1.0],
    );
  }

  // Hero surfaces vívidas (encabezados hero, empty states con icono)
  LinearGradient get accentGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: _isDark
            ? [
                Color.lerp(primary, Colors.black, 0.52)!,
                Color.lerp(primary, Colors.black, 0.28)!,
              ]
            : [primary, Color.lerp(primary, Colors.white, 0.28)!],
      );

  // Cards de lista — sutil en Light, profundo en Dark
  LinearGradient get cardGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: _isDark
            ? [surfaceContainerLowest, surfaceContainerLow]
            : [surfaceContainerLowest, primary.withValues(alpha: 0.05)],
      );

  LinearGradient get insightGradient => _isDark
      ? LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary.withValues(alpha: 0.10),
            primary.withValues(alpha: 0.04),
          ],
        )
      : const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFECFDF5), Color(0xFFF0FDF4)],
        );

  Color get insightAccent => _isDark ? primary : const Color(0xFF059669);

  LinearGradient get successGradient => _isDark
      ? const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF064E3B), Color(0xFF059669)],
        )
      : const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF047857), Color(0xFF34D399)],
        );

  Color get cardSurface => surfaceContainerLowest;
  Color get cardBorder  => _isDark
      ? Colors.white.withValues(alpha: 0.07)
      : primary.withValues(alpha: 0.10);
  Color get subtleSurface => _isDark
      ? surfaceContainerLow
      : primary.withValues(alpha: 0.06);

  Color get navBarSurface    => _isDark ? surface : surfaceContainerLowest;
  Color get presupuestoSurface => _isDark ? surfaceContainerLow : primary.withValues(alpha: 0.06);
  Color get alertaSurface    => _isDark ? surfaceContainerLow : const Color(0xFFFFFBEB);

  // Sombras adaptativas — elevación real en Light, imperceptibles en Dark
  List<BoxShadow> get cardShadow => _isDark
      ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ]
      : [
          BoxShadow(
            color: primary.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ];

  List<BoxShadow> get heroShadow => [
        BoxShadow(
          color: primary.withValues(alpha: _isDark ? 0.30 : 0.22),
          blurRadius: 28,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: _isDark ? 0.15 : 0.06),
          blurRadius: 12,
          offset: const Offset(0, 3),
        ),
      ];

  List<BoxShadow> get fabShadow => [
        BoxShadow(
          color: primary.withValues(alpha: _isDark ? 0.45 : 0.35),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ];

  List<Color> get chartColors => _isDark
      ? [
          primary,
          Color.lerp(primary, Colors.white, 0.30)!,
          const Color(0xFF22C55E),
          const Color(0xFFFFB86C),
          const Color(0xFFE879F9),
          const Color(0xFF67E8F9),
          const Color(0xFFFB7185),
        ]
      : [
          primary,
          secondary,
          const Color(0xFF059669),
          const Color(0xFFD97706),
          const Color(0xFF9333EA),
          const Color(0xFF0891B2),
          const Color(0xFFE11D48),
        ];
}
