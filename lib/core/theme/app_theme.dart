import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/game_enums.dart';

class ThemeConfig {
  final Color backgroundColor;
  final Color surfaceColor;
  final Color cardColor;
  final Color gridLineColor;
  final Color boardBackgroundColor;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final Color xPrimaryColor;
  final Color oPrimaryColor;
  final bool isDark;

  const ThemeConfig({
    required this.backgroundColor,
    required this.surfaceColor,
    required this.cardColor,
    required this.gridLineColor,
    required this.boardBackgroundColor,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.xPrimaryColor,
    required this.oPrimaryColor,
    required this.isDark,
  });
}

class AppTheme {
  static ThemeConfig getConfig(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.modernLight:
        return const ThemeConfig(
          backgroundColor: Color(0xFFF1F5F9),
          surfaceColor: Color(0xFFFFFFFF),
          cardColor: Color(0xFFFFFFFF),
          gridLineColor: Color(0xFFCBD5E1),
          boardBackgroundColor: Color(0xFFFFFFFF),
          primaryTextColor: Color(0xFF0F172A),
          secondaryTextColor: Color(0xFF475569),
          xPrimaryColor: Color(0xFF0072FF),
          oPrimaryColor: Color(0xFFFF3366),
          isDark: false,
        );
      case AppThemeMode.cyberpunkNeon:
        return const ThemeConfig(
          backgroundColor: Color(0xFF0B132B),
          surfaceColor: Color(0xFF1C2541),
          cardColor: Color(0xFF1C2541),
          gridLineColor: Color(0xFF3A506B),
          boardBackgroundColor: Color(0xFF111D3B),
          primaryTextColor: Colors.white,
          secondaryTextColor: Color(0xFF94A3B8),
          xPrimaryColor: Color(0xFF00F2FE),
          oPrimaryColor: Color(0xFFFF5858),
          isDark: true,
        );
      case AppThemeMode.classicWood:
        return const ThemeConfig(
          backgroundColor: Color(0xFFFBF7F2),
          surfaceColor: Color(0xFFEFE6DD),
          cardColor: Color(0xFFFFFFFF),
          gridLineColor: Color(0xFF8D6E63),
          boardBackgroundColor: Color(0xFFF3E9DD),
          primaryTextColor: Color(0xFF3E2723),
          secondaryTextColor: Color(0xFF6D4C41),
          xPrimaryColor: Color(0xFFD32F2F),
          oPrimaryColor: Color(0xFF1976D2),
          isDark: false,
        );
      case AppThemeMode.midnightObsidian:
        return const ThemeConfig(
          backgroundColor: Color(0xFF070B19),
          surfaceColor: Color(0xFF141C33),
          cardColor: Color(0xFF182342),
          gridLineColor: Color(0xFF283860),
          boardBackgroundColor: Color(0xFF0D162B),
          primaryTextColor: Colors.white,
          secondaryTextColor: Color(0xFFA0AEC0),
          xPrimaryColor: Color(0xFF00E5FF),
          oPrimaryColor: Color(0xFFFF4081),
          isDark: true,
        );
    }
  }

  static ThemeData getThemeData(AppThemeMode mode) {
    final cfg = getConfig(mode);
    return ThemeData(
      brightness: cfg.isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: cfg.backgroundColor,
      cardColor: cfg.cardColor,
      colorScheme: ColorScheme(
        brightness: cfg.isDark ? Brightness.dark : Brightness.light,
        primary: cfg.xPrimaryColor,
        secondary: cfg.oPrimaryColor,
        surface: cfg.surfaceColor,
        error: Colors.redAccent,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: cfg.primaryTextColor,
        onError: Colors.white,
      ),
      useMaterial3: true,
      fontFamily: GoogleFonts.manrope().fontFamily,
    );
  }
}
