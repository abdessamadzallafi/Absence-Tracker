import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryColor = Color(0xFF2563EB); // Royal Blue
  static const Color secondaryColor = Color(0xFF0F172A); // Dark Slate
  static const Color accentColor = Color(0xFF3B82F6);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFEF4444);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);

  static final light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      background: backgroundColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimary,
      onBackground: textPrimary,
    ),

    // Typography
    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge:
          const TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
      displayMedium:
          const TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
      displaySmall:
          const TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
      headlineMedium:
          const TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
      titleLarge:
          const TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
      bodyLarge: const TextStyle(color: textPrimary),
      bodyMedium: const TextStyle(color: textSecondary),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: surfaceColor,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
    ),

    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor),
      ),
      labelStyle: const TextStyle(color: textSecondary),
      prefixIconColor: textSecondary,
    ),

    // Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: primaryColor.withOpacity(0.4),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    // Filled Button (Same as elevated but usually used for high emphasis action)
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    // Outlined Button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        side: const BorderSide(color: primaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // App Bar
    appBarTheme: AppBarTheme(
      centerTitle: true,
      backgroundColor: surfaceColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: const IconThemeData(color: textPrimary),
      titleTextStyle: GoogleFonts.inter(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Navigation Bar
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surfaceColor,
      height: 70,
      indicatorColor: primaryColor.withOpacity(0.15),
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: primaryColor,
          );
        }
        return const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textSecondary,
        );
      }),
      iconTheme: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const IconThemeData(color: primaryColor);
        }
        return const IconThemeData(color: textSecondary);
      }),
    ),

    // List Tile (for Drawer mainly)
    listTileTheme: ListTileThemeData(
      iconColor: textSecondary,
      textColor: textPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ),
  );
}
