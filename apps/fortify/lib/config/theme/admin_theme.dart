import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:fortify/config/theme/admin_colors.dart';

/// Builds the admin ThemeData with the dark elevated aesthetic.
class AdminTheme {
  AdminTheme._();

  static ThemeData build() {
    final TextTheme montserratTextTheme = GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AdminColors.surface,
      colorScheme: const ColorScheme.dark(
        primary: AdminColors.primary,
        secondary: AdminColors.primaryVariant,
        surface: AdminColors.surface,
        error: AdminColors.error,
        onPrimary: AdminColors.background,
        onSurface: AdminColors.onSurface,
        onError: AdminColors.onSurface,
      ),
      textTheme: montserratTextTheme.copyWith(
        headlineLarge: montserratTextTheme.headlineLarge?.copyWith(
          color: AdminColors.onSurface,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: montserratTextTheme.headlineMedium?.copyWith(
          color: AdminColors.onSurface,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: montserratTextTheme.bodyLarge?.copyWith(color: AdminColors.onSurface),
        bodyMedium: montserratTextTheme.bodyMedium?.copyWith(color: AdminColors.onSurface),
        bodySmall: montserratTextTheme.bodySmall?.copyWith(color: AdminColors.onSurfaceVariant),
        labelLarge: montserratTextTheme.labelLarge?.copyWith(color: AdminColors.onSurfaceVariant, letterSpacing: 1.0),
      ),
      cardTheme: const CardThemeData(
        color: AdminColors.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          side: BorderSide(color: AdminColors.surfaceBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AdminColors.surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AdminColors.surfaceBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AdminColors.surfaceBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AdminColors.primary),
        ),
        labelStyle: const TextStyle(color: AdminColors.onSurfaceVariant),
        hintStyle: const TextStyle(color: AdminColors.onSurfaceVariant),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AdminColors.primary,
          foregroundColor: AdminColors.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AdminColors.onSurface,
          side: const BorderSide(color: AdminColors.surfaceBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AdminColors.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      ),
      dividerTheme: const DividerThemeData(color: AdminColors.surfaceBorderSubtle, thickness: 1),
      appBarTheme: const AppBarTheme(
        backgroundColor: AdminColors.surface,
        foregroundColor: AdminColors.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  /// Orbitron text style for the app name and important headings. Use sparingly.
  static TextStyle orbitronStyle({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w700,
    Color color = AdminColors.primary,
  }) {
    return GoogleFonts.orbitron(fontSize: fontSize, fontWeight: fontWeight, color: color);
  }
}
