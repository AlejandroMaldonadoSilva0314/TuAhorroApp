import 'package:flutter/material.dart';

extension AppColors on ColorScheme {
  bool get _isDark => brightness == Brightness.dark;

  Color get positivo => _isDark ? const Color(0xFF6EE7A0) : const Color(0xFF16A34A);
  Color get positivoContainer => _isDark ? const Color(0xFF0A2E1A) : const Color(0xFFE8F8EF);

  Color get negativo => error;
  Color get negativoContainer => errorContainer;

  Color get ahorro => _isDark ? const Color(0xFF93B5FF) : const Color(0xFF3B6AE8);
  Color get alerta => _isDark ? const Color(0xFFFFB86C) : const Color(0xFFD97706);

  Color get onAccentSurface => Colors.white;

  LinearGradient get heroGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: _isDark
            ? [const Color(0xFF4C1D95), const Color(0xFF7C3AED)]
            : [const Color(0xFF6D28D9), const Color(0xFF8B5CF6)],
      );

  LinearGradient get accentGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: _isDark
            ? [const Color(0xFF1E1B4B), const Color(0xFF4338CA)]
            : [const Color(0xFF4F46E5), const Color(0xFF818CF8)],
      );

  LinearGradient get successGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: _isDark
            ? [const Color(0xFF064E3B), const Color(0xFF059669)]
            : [const Color(0xFF059669), const Color(0xFF34D399)],
      );

  Color get cardSurface => _isDark ? const Color(0xFF16161E) : Colors.white;
  Color get cardBorder => _isDark
      ? Colors.white.withValues(alpha: 0.06)
      : Colors.black.withValues(alpha: 0.04);
  Color get subtleSurface => _isDark ? const Color(0xFF1C1C27) : const Color(0xFFF8F7FF);

  List<Color> get chartColors => _isDark
      ? [primary, const Color(0xFF818CF8), tertiary, const Color(0xFFFFB86C), const Color(0xFFE879F9), const Color(0xFF67E8F9), const Color(0xFFFB7185)]
      : [primary, const Color(0xFF4F46E5), tertiary, const Color(0xFFD97706), const Color(0xFF9333EA), const Color(0xFF0891B2), const Color(0xFFE11D48)];
}
