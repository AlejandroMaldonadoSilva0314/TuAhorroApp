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

  Color get onAccentSurface => Colors.white;

  LinearGradient get heroGradient {
    final p = primary;
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

  LinearGradient get accentGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: _isDark
            ? [const Color(0xFF1B1630), const Color(0xFF2D2250)]
            : [const Color(0xFF4F46E5), const Color(0xFF818CF8)],
      );

  LinearGradient get successGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF064E3B), Color(0xFF059669)],
      );

  Color get cardSurface => _isDark ? const Color(0xFF1B1630) : Colors.white;
  Color get cardBorder  => _isDark
      ? Colors.white.withValues(alpha: 0.07)
      : Colors.black.withValues(alpha: 0.04);
  Color get subtleSurface => _isDark ? const Color(0xFF241B3E) : const Color(0xFFF8F7FF);

  List<Color> get chartColors => _isDark
      ? [
          const Color(0xFF7B2FF7),
          const Color(0xFFA855F7),
          const Color(0xFF22C55E),
          const Color(0xFFFFB86C),
          const Color(0xFFE879F9),
          const Color(0xFF67E8F9),
          const Color(0xFFFB7185),
        ]
      : [
          const Color(0xFF7B2FF7),
          const Color(0xFF4F46E5),
          const Color(0xFF059669),
          const Color(0xFFD97706),
          const Color(0xFF9333EA),
          const Color(0xFF0891B2),
          const Color(0xFFE11D48),
        ];
}
