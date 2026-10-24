import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Logo XO cao cấp, hiện đại với chữ X và O có chiều cao bằng nhau tuyệt đối (52px),
/// hoàn thiện hiệu ứng Neon 3D, bóng đổ đa lớp và khung viền gradient sang trọng.
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
            borderRadius: BorderRadius.circular(32),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF1E294B), const Color(0xFF0F172A)]
                  : [Colors.white, const Color(0xFFF8FAFC)],
            ),
            border: Border.all(
              color: isDark ? Colors.white24 : const Color(0xFFE2E8F0),
              width: 2.2,
            ),
            boxShadow: [
              // Cyan glow (trái)
              BoxShadow(
                color: AppColors.cyanNeon.withValues(
                  alpha: isDark
                      ? (0.28 + 0.12 * glowFactor)
                      : (0.16 + 0.08 * glowFactor),
                ),
                blurRadius: 26 + 6 * glowFactor,
                spreadRadius: 2,
                offset: const Offset(-5, 4),
              ),
              // Coral glow (phải)
              BoxShadow(
                color: AppColors.coralNeon.withValues(
                  alpha: isDark
                      ? (0.28 + 0.12 * glowFactor)
                      : (0.16 + 0.08 * glowFactor),
                ),
                blurRadius: 26 + 6 * glowFactor,
                spreadRadius: 2,
                offset: const Offset(5, 4),
              ),
              // Bóng đổ chiều sâu tổng thể
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.1),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Họa tiết nền viền mờ tinh tế
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 1,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.cyanNeon.withValues(alpha: 0.6),
                        AppColors.coralNeon.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                ),
              ),
              // Vẽ X và O với chiều cao bằng nhau chính xác
              CustomPaint(
                size: Size(size * 0.76, size * 0.52),
                painter: _XOLogoPainter(isDark: isDark),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _XOLogoPainter extends CustomPainter {
  final bool isDark;

  _XOLogoPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    // Chiều cao bằng nhau tuyệt đối cho cả X và O:
    final symbolHeight = size.height; // Chiều cao = size.height
    final strokeW = symbolHeight * 0.17; // Độ dày nét đồng đều (khoảng 8.5px)

    // Chiều rộng của X và đường kính của O:
    final xWidth = symbolHeight * 0.92;
    final oDiameter =
        symbolHeight; // Hình tròn hoàn hảo có đường kính = symbolHeight

    // Tổng chiều rộng của cụm XO và khoảng cách bố cục
    final overlap =
        symbolHeight * 0.14; // Giao thoa nhẹ tạo cảm giác gắn kết logo
    final totalWidth = xWidth + oDiameter - overlap;
    final startX = (size.width - totalWidth) / 2;
    final startY = 0.0;

    final xRect = Rect.fromLTWH(startX, startY, xWidth, symbolHeight);
    final oRect = Rect.fromLTWH(
      startX + xWidth - overlap,
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
    final sparkCenter = Offset(
      startX + xWidth - overlap * 0.5,
      startY + symbolHeight * 0.5,
    );
    final sparkPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawCircle(sparkCenter, strokeW * 0.22, sparkPaint);
  }

  @override
  bool shouldRepaint(covariant _XOLogoPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
