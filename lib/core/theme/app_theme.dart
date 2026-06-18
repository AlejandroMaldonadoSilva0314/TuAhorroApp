import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

export 'app_design_system.dart';

class AppTheme {
  AppTheme._();

  static const _fontFamily = 'Roboto';

  // Premium Royal seed — deep violet #7B2FF7
  static const _seedColor = Color(0xFF7B2FF7);

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark()  => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: brightness,
      // Premium Royal dark surfaces
      surface:                  isDark ? const Color(0xFF0F0B1D) : const Color(0xFFF7F6FC),
      surfaceContainerLowest:   isDark ? const Color(0xFF1B1630) : Colors.white,
      surfaceContainerLow:      isDark ? const Color(0xFF241B3E) : const Color(0xFFF1F0F8),
      surfaceContainer:         isDark ? const Color(0xFF2D2250) : const Color(0xFFEBEAF4),
      surfaceContainerHigh:     isDark ? const Color(0xFF362A5E) : const Color(0xFFE4E3EF),
      surfaceContainerHighest:  isDark ? const Color(0xFF3F316A) : const Color(0xFFDBDAE8),
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
                systemNavigationBarColor: const Color(0xFF0F0B1D),
              )
            : SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: colorScheme.surfaceContainerLowest,
        shadowColor: Colors.black.withValues(alpha: 0.18),
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
        backgroundColor: isDark ? const Color(0xFF1B1630) : Colors.white,
        surfaceTintColor: Colors.transparent,
      ),

      bottomSheetTheme: BottomSheetThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        backgroundColor: isDark ? const Color(0xFF1B1630) : Colors.white,
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
        backgroundColor: isDark ? const Color(0xFF130F22) : Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: const Color(0xFF7B2FF7).withValues(alpha: 0.15),
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
        backgroundColor: isDark ? const Color(0xFF241B3E) : const Color(0xFF1B1630),
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
