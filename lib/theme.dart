import 'package:flutter/material.dart';

// ########################################################
// # App Theme — Multi-color palette for Smart Study Buddy
// ########################################################

class AppTheme {
  // Primary colors
  static const Color primary = Color(0xFF1F4E79); // Dark Blue
  static const Color primaryLight = Color(0xFF2196F3); // Bright Blue
  static const Color accent = Color(0xFF00BCD4); // Cyan

  // Status colors
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color warning = Color(0xFFFFC107); // Yellow
  static const Color error = Color(0xFFF44336); // Red
  static const Color info = Color(0xFF2196F3); // Blue

  // Additional palette colors
  static const Color purple = Color(0xFF9C27B0);
  static const Color orange = Color(0xFFFF9800);
  static const Color indigo = Color(0xFF3F51B5);
  static const Color teal = Color(0xFF009688);

  // Neutral colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE0E0E0);

  // Light backgrounds for cards
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warningLight = Color(0xFFFFF9C4);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color infoLight = Color(0xFFE3F2FD);
  static const Color primaryLightBg = Color(0xFFE8F4FD);

  // Get theme data
  static ThemeData getThemeData() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: Colors.white,
        secondary: accent,
        onSecondary: Colors.white,
        error: error,
        onError: Colors.white,
        background: background,
        onBackground: Colors.black87,
        surface: surface,
        onSurface: Colors.black87,
        outline: border,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: success,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: surface,
      ),
    );
  }
}

// ########################################################
// # Color utility for dynamic color selection
// ########################################################

class AppColors {
  static final List<Color> allColors = [
    AppTheme.primary,
    AppTheme.success,
    AppTheme.warning,
    AppTheme.error,
    AppTheme.info,
    AppTheme.purple,
    AppTheme.orange,
    AppTheme.indigo,
    AppTheme.teal,
  ];

  static final List<Color> allColorsLight = [
    AppTheme.primaryLightBg,
    AppTheme.successLight,
    AppTheme.warningLight,
    AppTheme.errorLight,
    AppTheme.infoLight,
    const Color(0xFFF3E5F5), // Purple light
    const Color(0xFFFFE0B2), // Orange light
    const Color(0xFFE8EAF6), // Indigo light
    const Color(0xFFE0F2F1), // Teal light
  ];

  static Color getColorByIndex(int index) {
    return allColors[index % allColors.length];
  }

  static Color getColorLightByIndex(int index) {
    return allColorsLight[index % allColorsLight.length];
  }

  static Color getColorByType(String type) {
    switch (type.toLowerCase()) {
      case 'notes':
        return AppTheme.info;
      case 'past paper':
        return AppTheme.warning;
      case 'group':
        return AppTheme.success;
      case 'message':
        return AppTheme.purple;
      case 'notification':
        return AppTheme.error;
      default:
        return AppTheme.primary;
    }
  }
}
