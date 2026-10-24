import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppStyles {
  // Heading styles
  static TextStyle headingLarge({Color color = Colors.white}) =>
      GoogleFonts.montserrat(
        fontSize: 34,
        fontWeight: FontWeight.w900,
        color: color,
        letterSpacing: -0.5,
      );

  static TextStyle headingMedium({Color color = Colors.white}) =>
      GoogleFonts.montserrat(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: color,
        letterSpacing: -0.2,
      );

  static TextStyle headingSmall({Color color = Colors.white}) =>
      GoogleFonts.montserrat(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: color,
      );

  // Body styles - Đủ to để đọc rõ ràng từ xa
  static TextStyle bodyLarge({Color color = Colors.white}) =>
      GoogleFonts.montserrat(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.4,
      );

  static TextStyle bodyMedium({Color color = Colors.white70}) =>
      GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: color,
        height: 1.4,
      );

  static TextStyle bodySmall({Color color = Colors.white60}) =>
      GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color,
      );

  // Button styles 
  static TextStyle buttonText({Color color = Colors.white}) =>
      GoogleFonts.montserrat(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
        color: color,
      );

  // Scoreboard Number
  static TextStyle scoreNumber({Color color = Colors.white}) =>
      GoogleFonts.montserrat(
        fontSize: 38,
        fontWeight: FontWeight.w900,
        color: color,
      );

  // Glossy Drop Shadow presets
  static List<BoxShadow> glossyShadow({
    Color glowColor = AppColors.cyanNeon,
    double spread = 1,
    double blur = 24,
    Offset offset = const Offset(0, 8),
  }) =>
      [
        BoxShadow(
          color: glowColor.withValues(alpha: 0.45),
          blurRadius: blur,
          spreadRadius: spread,
          offset: offset,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.35),
          blurRadius: 12,
          offset: const Offset(0, 5),
        ),
      ];

  static List<BoxShadow> cardShadow({
    Color shadowColor = Colors.black,
    double opacity = 0.35,
  }) =>
      [
        BoxShadow(
          color: shadowColor.withValues(alpha: opacity),
          blurRadius: 20,
          spreadRadius: 2,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.1),
          blurRadius: 1,
          offset: const Offset(0, 1),
        ),
      ];
}
