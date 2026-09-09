import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App color palette designed for MetroGo:
/// Soft, calm, modern blue & white tones avoiding harsh corporate navy.
class AppColors {
  // Primary brand blues
  static const Color primary = Color(0xFF2F6FED);
  static const Color primaryLight = Color(0xFFE8F0FE);
  static const Color primarySubtle = Color(0xFFF3F7FE);
  static const Color primaryDark = Color(0xFF1E54C7);
  static const Color primaryGradientStart = Color(0xFF2F6FED);
  static const Color primaryGradientEnd = Color(0xFF4C85F5);

  // Backgrounds and surfaces
  static const Color background = Color(0xFFF7F9FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF1F5F9);
  static const Color surfaceMuted = Color(0xFFEBF1F7);

  // Text colors
  static const Color textPrimary = Color(0xFF1A1D29);
  static const Color textSecondary = Color(0xFF7B8794);
  static const Color textMuted = Color(0xFF9AA5B1);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Borders and dividers
  static const Color border = Color(0xFFE5E9F0);
  static const Color borderSubtle = Color(0xFFEDF2F7);
  static const Color borderMedium = Color(0xFFD0D7DE);
  static const Color borderFocused = Color(0xFF2F6FED);

  // Semantic & status colors
  static const Color success = Color(0xFF34C759);
  static const Color successLight = Color(0xFFEBF9EE);
  static const Color successText = Color(0xFF1E8238);

  static const Color warning = Color(0xFFFF9F0A);
  static const Color warningLight = Color(0xFFFFF6E7);
  static const Color warningText = Color(0xFFB46A00);

  static const Color error = Color(0xFFFF3B30);
  static const Color errorLight = Color(0xFFFEECEB);
  static const Color errorText = Color(0xFFD32F2F);

  static const Color info = Color(0xFF0EA5E9);
  static const Color infoLight = Color(0xFFE0F2FE);
  static const Color infoText = Color(0xFF0369A1);

  // Ticket Status Colors
  static const Color ticketPaid = Color(0xFF22C55E);
  static const Color ticketPaidBg = Color(0xFFEAF8F0);
  static const Color ticketPaidText = Color(0xFF15803D);

  static const Color ticketPending = Color(0xFFF59E0B);
  static const Color ticketPendingBg = Color(0xFFFFF8E7);
  static const Color ticketPendingText = Color(0xFFB45309);

  static const Color ticketUsed = Color(0xFF2F6FED);
  static const Color ticketUsedBg = Color(0xFFEBF3FE);
  static const Color ticketUsedText = Color(0xFF1D4ED8);

  static const Color ticketExpired = Color(0xFF64748B);
  static const Color ticketExpiredBg = Color(0xFFF1F4F8);
  static const Color ticketExpiredText = Color(0xFF475569);
}

/// Spacing scale (4px grid)
class AppSpacing {
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;
  static const double huge = 48.0;
}

/// Standardized border radius scale:
/// sm (4px), md (8px), lg (12px), xl (16px), full/pill (9999px)
class AppRadius {
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double full = 9999.0;
  static const double pill = 9999.0;

  // Compatibility aliases
  static const double xs = 4.0;

  static const Radius rXs = Radius.circular(xs);
  static const Radius rSm = Radius.circular(sm);
  static const Radius rMd = Radius.circular(md);
  static const Radius rLg = Radius.circular(lg);
  static const Radius rXl = Radius.circular(xl);
  static const Radius rFull = Radius.circular(full);
  static const Radius rPill = Radius.circular(pill);

  static const BorderRadius borderXs = BorderRadius.all(rXs);
  static const BorderRadius borderSm = BorderRadius.all(rSm);
  static const BorderRadius borderMd = BorderRadius.all(rMd);
  static const BorderRadius borderLg = BorderRadius.all(rLg);
  static const BorderRadius borderXl = BorderRadius.all(rXl);
  static const BorderRadius borderFull = BorderRadius.all(rFull);
  static const BorderRadius borderPill = BorderRadius.all(rPill);
}

/// Soft, subtle shadows — never harsh or heavy
class AppShadows {
  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color(0x0A1A1D29),
      blurRadius: 14,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0C1A1D29),
      blurRadius: 18,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> floating = [
    BoxShadow(
      color: Color(0x121A1D29),
      blurRadius: 24,
      offset: Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> buttonPrimary = [
    BoxShadow(
      color: Color(0x332F6FED),
      blurRadius: 16,
      offset: Offset(0, 6),
      spreadRadius: 0,
    ),
  ];
}

/// Typography configured using Google Fonts "Merriweather"
/// Provides an elegant, readable serif typography hierarchy with system serif fallbacks.
class AppTypography {
  static const List<String> fontFallback = ['Georgia', 'serif'];

  static TextTheme textTheme = GoogleFonts.merriweatherTextTheme(
    const TextTheme(
      displayLarge: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
        height: 1.3,
        fontFamilyFallback: fontFallback,
      ),
      displayMedium: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.4,
        height: 1.32,
        fontFamilyFallback: fontFallback,
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
        height: 1.35,
        fontFamilyFallback: fontFallback,
      ),
      headlineMedium: TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.2,
        height: 1.38,
        fontFamilyFallback: fontFallback,
      ),
      titleLarge: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.1,
        height: 1.4,
        fontFamilyFallback: fontFallback,
      ),
      titleMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0,
        height: 1.42,
        fontFamilyFallback: fontFallback,
      ),
      bodyLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        letterSpacing: 0,
        height: 1.55,
        fontFamilyFallback: fontFallback,
      ),
      bodyMedium: TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        letterSpacing: 0,
        height: 1.55,
        fontFamilyFallback: fontFallback,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        letterSpacing: 0,
        height: 1.5,
        fontFamilyFallback: fontFallback,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: 0.1,
        height: 1.3,
        fontFamilyFallback: fontFallback,
      ),
      labelMedium: TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.1,
        height: 1.3,
        fontFamilyFallback: fontFallback,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing: 0.2,
        height: 1.25,
        fontFamilyFallback: fontFallback,
      ),
    ),
  );

  // Convenient static accessors
  static TextStyle get display => textTheme.displayLarge!;
  static TextStyle get headline => textTheme.headlineLarge!;
  static TextStyle get title => textTheme.titleLarge!;
  static TextStyle get body => textTheme.bodyLarge!;
  static TextStyle get bodySecondary => textTheme.bodyMedium!;
  static TextStyle get caption => textTheme.bodySmall!;
}

/// Flutter ThemeData configured for MetroGo
class AppTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = AppTypography.textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: GoogleFonts.merriweather().fontFamily,
      fontFamilyFallback: AppTypography.fontFallback,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.textOnPrimary,
        primaryContainer: AppColors.primaryLight,
        onPrimaryContainer: AppColors.primaryDark,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: Colors.white,
        outline: AppColors.border,
      ),
      textTheme: baseTextTheme,
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderLg,
          side: BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: baseTextTheme.titleLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: 22,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(color: AppColors.borderFocused, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(color: AppColors.error, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(color: AppColors.error, width: 1.6),
        ),
        hintStyle: TextStyle(
          color: AppColors.textMuted,
        ),
        labelStyle: TextStyle(
          color: AppColors.textSecondary,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSubtle,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
