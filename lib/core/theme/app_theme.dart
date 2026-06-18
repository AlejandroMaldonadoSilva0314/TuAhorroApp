import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_design_system.dart';
export 'app_design_system.dart';

class AppTheme {
  AppTheme._();

  static const _fontFamily = 'Roboto';

  static ThemeData light([TemaColor temaColor = TemaColor.premiumRoyal]) =>
      _build(Brightness.light, temaColor);
  static ThemeData dark([TemaColor temaColor = TemaColor.premiumRoyal]) =>
      _build(Brightness.dark, temaColor);

  static Color _seedForTema(TemaColor t) => switch (t) {
    TemaColor.premiumRoyal => const Color(0xFF7B2FF7),
    TemaColor.midnight     => const Color(0xFF3B82F6),
    TemaColor.aurora       => const Color(0xFF06B6D4),
    TemaColor.emerald      => const Color(0xFF10B981),
    TemaColor.sunset       => const Color(0xFFF97316),
    TemaColor.ruby         => const Color(0xFFE11D48),
    TemaColor.lavender     => const Color(0xFF8B5CF6),
  };

  static Color _darkSurfaceForTema(TemaColor t) => switch (t) {
    TemaColor.premiumRoyal => const Color(0xFF0F0B1D),
    TemaColor.midnight     => const Color(0xFF070B14),
    TemaColor.aurora       => const Color(0xFF04141A),
    TemaColor.emerald      => const Color(0xFF041A11),
    TemaColor.sunset       => const Color(0xFF1A0D04),
    TemaColor.ruby         => const Color(0xFF1A0409),
    TemaColor.lavender     => const Color(0xFF100D1E),
  };

  static Color _darkCardForTema(TemaColor t) => switch (t) {
    TemaColor.premiumRoyal => const Color(0xFF1B1630),
    TemaColor.midnight     => const Color(0xFF0F1829),
    TemaColor.aurora       => const Color(0xFF0A2530),
    TemaColor.emerald      => const Color(0xFF0A2B1E),
    TemaColor.sunset       => const Color(0xFF2D1A0A),
    TemaColor.ruby         => const Color(0xFF2D0A15),
    TemaColor.lavender     => const Color(0xFF1C1735),
  };

  // Light mode: fondos sutilmente tintados según el tema — cada tema tiene personalidad propia
  static Color _lightSurfaceForTema(TemaColor t) => switch (t) {
    TemaColor.premiumRoyal => const Color(0xFFF5F0FF), // lavanda suave
    TemaColor.midnight     => const Color(0xFFF0F4FA), // gris perla
    TemaColor.aurora       => const Color(0xFFEEF8FF), // azul cielo pálido
    TemaColor.emerald      => const Color(0xFFEEFAF4), // menta suave
    TemaColor.sunset       => const Color(0xFFFFF6F0), // durazno pálido
    TemaColor.ruby         => const Color(0xFFFFF0F3), // rosa pálido
    TemaColor.lavender     => const Color(0xFFF7F0FF), // lavanda cálida
  };

  // Light mode: cards ligeramente tintadas — flotan sobre el fondo del tema
  static Color _lightCardForTema(TemaColor t) => switch (t) {
    TemaColor.premiumRoyal => const Color(0xFFFEFBFF),
    TemaColor.midnight     => const Color(0xFFFAFBFE),
    TemaColor.aurora       => const Color(0xFFF8FCFF),
    TemaColor.emerald      => const Color(0xFFF7FEFA),
    TemaColor.sunset       => const Color(0xFFFFFBF8),
    TemaColor.ruby         => const Color(0xFFFFFBFC),
    TemaColor.lavender     => const Color(0xFFFDF8FF),
  };

  static ThemeData _build(Brightness brightness, TemaColor temaColor) {
    final isDark = brightness == Brightness.dark;
    final seed = _seedForTema(temaColor);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
      surface: isDark ? _darkSurfaceForTema(temaColor) : _lightSurfaceForTema(temaColor),
      surfaceContainerLowest: isDark ? _darkCardForTema(temaColor) : _lightCardForTema(temaColor),
    );

    final textTheme = _textTheme(colorScheme);

    return ThemeData(
      useMaterial3: true,
      fontFamily: _fontFamily,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,

      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: colorScheme.surface,
              )
            : SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: isDark ? 0 : 2,
        shadowColor: isDark ? Colors.transparent : colorScheme.primary.withValues(alpha: 0.12),
        surfaceTintColor: Colors.transparent,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: colorScheme.surfaceContainerLowest,
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0,
        highlightElevation: 4,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
      ),

      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.25)),
      ),

      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        elevation: 0,
        backgroundColor: colorScheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
      ),

      bottomSheetTheme: BottomSheetThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        backgroundColor: colorScheme.surfaceContainerLowest,
        showDragHandle: true,
        elevation: 0,
      ),

      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),

      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: 0.15),
        space: 1,
        thickness: 1,
      ),

      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        elevation: 0,
        backgroundColor: isDark ? colorScheme.surface : colorScheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.15),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),

      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: isDark
            ? colorScheme.surfaceContainerHigh
            : colorScheme.inverseSurface,
      ),
    );
  }

  static TextTheme _textTheme(ColorScheme cs) {
    return TextTheme(
      displayLarge:  TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: cs.onSurface, letterSpacing: -0.8),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: cs.onSurface, letterSpacing: -0.5),
      headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: cs.onSurface, letterSpacing: -0.3),
      headlineMedium:TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: cs.onSurface),
      titleLarge:    TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurface),
      titleMedium:   TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface),
      titleSmall:    TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface),
      bodyLarge:     TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: cs.onSurface),
      bodyMedium:    TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: cs.onSurface),
      bodySmall:     TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: cs.onSurfaceVariant),
      labelLarge:    TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface),
      labelMedium:   TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: cs.onSurfaceVariant),
      labelSmall:    TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: cs.onSurfaceVariant, letterSpacing: 0.3),
    );
  }
}
