import 'package:flutter/material.dart';

// ── APP COLORS ────────────────────────────────────────────────────────────────
// Premium Royal palette – static constants for direct use.
// Extension methods on ColorScheme live in app_colors.dart.

class AppColors {
  AppColors._();

  // Base (deep purple-black)
  static const Color base900 = Color(0xFF0F0B1D);
  static const Color base800 = Color(0xFF171229);
  static const Color base700 = Color(0xFF201538);

  // Primary / Secondary
  static const Color primary    = Color(0xFF7B2FF7);
  static const Color primaryLight = Color(0xFFA855F7);

  // Accents
  static const Color accent1 = Color(0xFFC084FC);
  static const Color accent2 = Color(0xFFE9D5FF);

  // Surfaces
  static const Color surface100 = Color(0xFF1B1630);
  static const Color surface200 = Color(0xFF241B3E);
  static const Color surface300 = Color(0xFF2D2250);

  // Text
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFD1D5DB);
  static const Color textTertiary  = Color(0xFF9CA3AF);

  // Semantic
  static const Color success  = Color(0xFF22C55E);
  static const Color error    = Color(0xFFEF4444);
  static const Color warning  = Color(0xFFF59E0B);

  // Borders / Dividers
  static const Color outlineDim    = Color(0x1AFFFFFF); // white 10 %
  static const Color outlineMedium = Color(0x33FFFFFF); // white 20 %
}

// ── APP GRADIENTS ─────────────────────────────────────────────────────────────

class AppGradients {
  AppGradients._();

  static const LinearGradient hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5B18D4), Color(0xFF8B35F7), Color(0xFFC084FC)],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7B2FF7), Color(0xFFA855F7)],
  );

  static const LinearGradient card = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B1630), Color(0xFF241B3E)],
  );

  static const LinearGradient success = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF064E3B), Color(0xFF059669)],
  );

  static const LinearGradient surface = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF201538), Color(0xFF0F0B1D)],
  );

  // Shimmer para loading states
  static const LinearGradient shimmer = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF241B3E), Color(0xFF2D2250), Color(0xFF241B3E)],
  );

  // Bolsillos — Emerald (inspirado en Nequi)
  static const LinearGradient emerald = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF047857), Color(0xFF10B981)],
  );

  // Metas — Golden (aspiracional)
  static const LinearGradient golden = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF92400E), Color(0xFFF59E0B)],
  );

  // Peligro / alerta crítica
  static const LinearGradient danger = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF881337), Color(0xFFE11D48)],
  );

  // Aurora — stats/datos
  static const LinearGradient aurora = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E3A5F), Color(0xFF2563EB), Color(0xFF7C3AED)],
    stops: [0.0, 0.5, 1.0],
  );
}

// ── APP SPACING ───────────────────────────────────────────────────────────────

class AppSpacing {
  AppSpacing._();

  static const double xs   = 4.0;
  static const double sm   = 8.0;
  static const double md   = 12.0;
  static const double base = 16.0;
  static const double lg   = 20.0;
  static const double xl   = 24.0;
  static const double xxl  = 32.0;
  static const double xxxl = 48.0;
}

// ── APP RADIUS ────────────────────────────────────────────────────────────────

class AppRadius {
  AppRadius._();

  static const double xs   = 4.0;
  static const double sm   = 8.0;
  static const double md   = 12.0;
  static const double lg   = 16.0;
  static const double xl   = 20.0;
  static const double xxl  = 24.0;
  static const double xxxl = 32.0;
  static const double pill = 100.0;
}

// ── APP SHADOWS ───────────────────────────────────────────────────────────────

class AppShadows {
  AppShadows._();

  static List<BoxShadow> get card => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.25),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get hero => [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.35),
      blurRadius: 32,
      offset: const Offset(0, 12),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.20),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get fab => [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.45),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get success => [
    BoxShadow(
      color: AppColors.success.withValues(alpha: 0.40),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get navBar => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.30),
      blurRadius: 24,
      offset: const Offset(0, -4),
    ),
  ];
}

// ── APP ANIMATIONS ────────────────────────────────────────────────────────────

class AppAnimations {
  AppAnimations._();

  static const Duration fast   = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 250);
  static const Duration slow   = Duration(milliseconds: 400);
}

// ── APP TYPOGRAPHY ────────────────────────────────────────────────────────────

class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Roboto';

  static const TextStyle heroAmount = TextStyle(
    fontSize: 52,
    fontWeight: FontWeight.w900,
    color: Colors.white,
    letterSpacing: -1.5,
    height: 1.0,
  );

  static const TextStyle largeAmount = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.8,
  );

  static const TextStyle sectionLabel = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.textTertiary,
    letterSpacing: 1.5,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
  );
}
