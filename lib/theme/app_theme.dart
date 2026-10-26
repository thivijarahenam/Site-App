import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Brand & Action
  static const primaryOrange = Color(0xFFFF5B22); // LabourPro vibrant action orange
  static const primaryNavy = Color(0xFF0F172A);   // Deep slate navy
  static const darkBlue = Color(0xFF1E3A8A);

  // Backgrounds & Surfaces
  static const background = Color(0xFFF4F7FC);   // Soft ice-blue/grey dashboard bg
  static const cardWhite = Color(0xFFFFFFFF);
  static const surfaceTint = Color(0xFFEEF3F9);
  static const cardBorder = Color(0xFFE2E8F0);

  // Text Colors
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF475569);
  static const textMuted = Color(0xFF94A3B8);

  // Categorical Soft Pastels & Accents
  static const pastelBlueBg = Color(0xFFEBF3FE);
  static const pastelBlueText = Color(0xFF2563EB);

  static const pastelGreenBg = Color(0xFFEAF7EE);
  static const pastelGreenText = Color(0xFF16A34A);

  static const pastelPurpleBg = Color(0xFFF4EFFF);
  static const pastelPurpleText = Color(0xFF9333EA);

  static const pastelOrangeBg = Color(0xFFFFF4ED);
  static const pastelOrangeText = Color(0xFFEA580C);

  static const pastelAmberBg = Color(0xFFFEF9E7);
  static const pastelAmberText = Color(0xFFD97706);

  static const pastelRedBg = Color(0xFFFEECEB);
  static const pastelRedText = Color(0xFFE11D48);

  static const pastelTealBg = Color(0xFFE6F8F6);
  static const pastelTealText = Color(0xFF0D9488);

  static const pastelCyanBg = Color(0xFFECFEFF);
  static const pastelCyanText = Color(0xFF0891B2);

  // Backward-compatibility aliases for existing widgets
  static const safety = primaryOrange;
  static const slate = textSecondary;
  static const ink = primaryNavy;
  static const line = cardBorder;
  static const blue = pastelBlueText;
  static const teal = pastelTealText;
  static const coral = primaryOrange;
  static const amber = pastelAmberText;
  static const green = pastelGreenText;
  static const mist = surfaceTint;
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryOrange,
        primary: AppColors.primaryOrange,
        secondary: AppColors.pastelBlueText,
        surface: AppColors.cardWhite,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
    );

    final headingFont = GoogleFonts.plusJakartaSans(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w700,
    );
    final bodyFont = GoogleFonts.plusJakartaSans(
      color: AppColors.textSecondary,
    );

    return base.copyWith(
      textTheme: TextTheme(
        displayLarge: headingFont.copyWith(fontSize: 32, letterSpacing: -0.5),
        displayMedium: headingFont.copyWith(fontSize: 26, letterSpacing: -0.5),
        headlineLarge: headingFont.copyWith(fontSize: 22, letterSpacing: -0.3),
        headlineMedium: headingFont.copyWith(fontSize: 19, letterSpacing: -0.2),
        titleLarge: headingFont.copyWith(fontSize: 17, fontWeight: FontWeight.w700),
        titleMedium: headingFont.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
        titleSmall: headingFont.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
        bodyLarge: bodyFont.copyWith(fontSize: 15, height: 1.45),
        bodyMedium: bodyFont.copyWith(fontSize: 13, height: 1.4),
        bodySmall: bodyFont.copyWith(fontSize: 11, color: AppColors.textMuted),
        labelLarge: headingFont.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
        labelMedium: headingFont.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
        labelSmall: headingFont.copyWith(fontSize: 10, fontWeight: FontWeight.w600),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: headingFont.copyWith(fontSize: 18),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.cardBorder, width: 0.8),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: bodyFont.copyWith(color: AppColors.textMuted, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryOrange, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryOrange,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: headingFont.copyWith(fontWeight: FontWeight.w700, fontSize: 15),
          elevation: 0,
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.cardBorder, thickness: 1),
    );
  }
}
