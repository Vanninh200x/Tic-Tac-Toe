import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Logo XO with a bright game-board tile and crisp, dimensional lettering.
class XOLogoWidget extends StatefulWidget {
  final bool isDark;
  final double size;

  const XOLogoWidget({super.key, required this.isDark, this.size = 126});

  @override
  State<XOLogoWidget> createState() => _XOLogoWidgetState();
}

class _XOLogoWidgetState extends State<XOLogoWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _pulseAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final size = widget.size;

    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, _) {
        final glowFactor = _pulseAnim.value;

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.29),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF38BDF8), Color(0xFF2563EB), Color(0xFF22D3EE)],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.72), width: 2.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.cyanNeon.withValues(alpha: 0.28 + 0.12 * glowFactor),
                blurRadius: 24 + 8 * glowFactor,
                spreadRadius: 1,
                offset: const Offset(0, 9),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _LogoGridPainter(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
              ),
              CustomPaint(
                size: Size(size * 0.78, size * 0.52),
                painter: _XOLogoPainter(isDark: isDark),
              ),
              Positioned(
                right: size * 0.13,
                top: size * 0.12,
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: size * 0.13,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LogoGridPainter extends CustomPainter {
  final Color color;

  const _LogoGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    final spacing = size.width / 4;
    for (var i = 1; i < 4; i++) {
      final offset = spacing * i;
      canvas.drawLine(Offset(offset, 0), Offset(offset, size.height), paint);
      canvas.drawLine(Offset(0, offset), Offset(size.width, offset), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LogoGridPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _XOLogoPainter extends CustomPainter {
  final bool isDark;

  _XOLogoPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    // Chiều cao bằng nhau tuyệt đối cho cả X và O:
    final symbolHeight = size.height; // Chiều cao = size.height
    final strokeW = symbolHeight * 0.14;

    // Chiều rộng của X và đường kính của O:
    final xWidth = symbolHeight * 0.78;
    final oDiameter = symbolHeight * 0.78;

    // Tổng chiều rộng của cụm XO và khoảng cách bố cục
    final gap = symbolHeight * 0.13;
    final totalWidth = xWidth + oDiameter + gap;
    final startX = (size.width - totalWidth) / 2;
    final startY = 0.0;

    final xRect = Rect.fromLTWH(startX, startY, xWidth, symbolHeight);
    final oRect = Rect.fromLTWH(
      startX + xWidth + gap,
      startY,
      oDiameter,
      symbolHeight,
    );

    // 1. Vẽ quân X (Electric Cyan / Royal Blue)
    final xShader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: AppColors.xGradient,
    ).createShader(xRect);

    // Lớp bóng neon phát sáng của X
    final xGlowPaint = Paint()
      ..color = AppColors.cyanNeon.withValues(alpha: isDark ? 0.6 : 0.45)
      ..strokeWidth = strokeW + 7.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // Lớp nét chính của X
    final xPaint = Paint()
      ..shader = xShader
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Nét highlight sáng bóng 3D của X
    final xHighlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = strokeW * 0.32
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Vẽ nét chéo 1: trên-trái xuống dưới-phải
    final xP1 = Offset(xRect.left + strokeW * 0.4, xRect.top + strokeW * 0.4);
    final xP2 = Offset(
      xRect.right - strokeW * 0.4,
      xRect.bottom - strokeW * 0.4,
    );

    // Vẽ nét chéo 2: trên-phải xuống dưới-trái
    final xP3 = Offset(xRect.right - strokeW * 0.4, xRect.top + strokeW * 0.4);
    final xP4 = Offset(
      xRect.left + strokeW * 0.4,
      xRect.bottom - strokeW * 0.4,
    );

    // Vẽ Glow X
    canvas.drawLine(xP1, xP2, xGlowPaint);
    canvas.drawLine(xP3, xP4, xGlowPaint);

    // Vẽ Nét Chính X
    canvas.drawLine(xP1, xP2, xPaint);
    canvas.drawLine(xP3, xP4, xPaint);

    // Vẽ Highlight X
    canvas.drawLine(
      Offset(xP1.dx + 2, xP1.dy + 2),
      Offset(xP2.dx - 2, xP2.dy - 2),
      xHighlightPaint,
    );

    // 2. Vẽ quân O (Sunset Coral / Ruby Rose)
    final oShader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: AppColors.oGradient,
    ).createShader(oRect);

    final oCenter = oRect.center;
    final oRadius = (symbolHeight - strokeW) / 2;

    // Lớp bóng neon phát sáng của O
    final oGlowPaint = Paint()
      ..color = AppColors.coralNeon.withValues(alpha: isDark ? 0.6 : 0.45)
      ..strokeWidth = strokeW + 7.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // Lớp nét chính của O
    final oPaint = Paint()
      ..shader = oShader
      ..strokeWidth = strokeW
      ..style = PaintingStyle.stroke;

    // Lớp ánh sáng vòm 3D của O
    final oHighlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = strokeW * 0.32
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Vẽ Glow O
    canvas.drawCircle(oCenter, oRadius, oGlowPaint);

    // Vẽ Nét Chính O
    canvas.drawCircle(oCenter, oRadius, oPaint);

    // Vẽ Highlight O (Cung tròn góc trên bên trái tạo độ bóng lượn 3D)
    canvas.drawArc(
      Rect.fromCircle(center: oCenter, radius: oRadius),
      -pi * 0.85,
      pi * 0.55,
      false,
      oHighlightPaint,
    );

    // 3. Điểm nhấn tâm giao thoa (Sparkle / Energy Core)
  }

  @override
  bool shouldRepaint(covariant _XOLogoPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
