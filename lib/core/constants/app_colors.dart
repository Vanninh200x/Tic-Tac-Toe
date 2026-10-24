import 'package:flutter/material.dart';

class AppColors {
  // Giao diện Sáng Sang Trọng (Modern Vibrant / Light)
  static const Color lightBg = Color(0xFFF1F5F9);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightGrid = Color(0xFFCBD5E1);

  // Quân X: Electric Cyan / Royal Azure Gradient
  static const Color cyanNeon = Color(0xFF0072FF);
  static const Color blueElectric = Color(0xFF00C6FF);
  static const List<Color> xGradient = [
    Color(0xFF00C6FF),
    Color(0xFF0072FF),
  ];

  // Quân O: Sunset Coral / Ruby Rose Gradient
  static const Color coralNeon = Color(0xFFFF416C);
  static const Color pinkNeon = Color(0xFFFF4B2B);
  static const List<Color> oGradient = [
    Color(0xFFFF416C),
    Color(0xFFFF4B2B),
  ];

  // Màu Vàng Kim Hoàng Gia (Chiến thắng, cúp, highlight)
  static const Color gold = Color(0xFFF59E0B);
  static const Color amberNeon = Color(0xFFFBBF24);
  static const List<Color> goldGradient = [
    Color(0xFFFBBF24),
    Color(0xFFD97706),
  ];

  // Màu Trạng Thái
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Bóng Đổ & Viền Phát Sáng
  static const Color borderHighlight = Color(0x33FFFFFF);
  static const Color glassFill = Color(0x1AFFFFFF);
  static const Color shadowGlowCyan = Color(0x400072FF);
  static const Color shadowGlowCoral = Color(0x40FF416C);
  static const Color shadowSoft = Color(0x1F000000);
}
