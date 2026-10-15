import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class SpaceBackdrop extends StatelessWidget {
  const SpaceBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExcludeSemantics(
      child: CustomPaint(painter: _SpacePainter(), child: SizedBox.expand()),
    );
  }
}

class _SpacePainter extends CustomPainter {
  const _SpacePainter();

  static const _stars = <Offset>[
    Offset(0.08, 0.11),
    Offset(0.23, 0.19),
    Offset(0.88, 0.12),
    Offset(0.76, 0.25),
    Offset(0.13, 0.38),
    Offset(0.94, 0.43),
    Offset(0.68, 0.54),
    Offset(0.18, 0.66),
    Offset(0.89, 0.72),
    Offset(0.34, 0.81),
    Offset(0.77, 0.91),
    Offset(0.07, 0.87),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF090923), Color(0xFF11103A), Color(0xFF080B21)],
          stops: [0, 0.52, 1],
        ).createShader(rect),
    );

    _drawNebula(
      canvas,
      Offset(size.width * 0.82, size.height * 0.15),
      size.width * 0.74,
      const Color(0xFF182C94),
    );
    _drawNebula(
      canvas,
      Offset(size.width * 0.02, size.height * 0.78),
      size.width * 0.72,
      const Color(0xFF591C8D),
    );

    final orbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.accent.withValues(alpha: 0.055);
    final orbitCenter = Offset(size.width * 0.35, size.height * 0.82);
    for (var index = 0; index < 8; index++) {
      final inset = index * 25.0;
      final orbitRect = Rect.fromCenter(
        center: orbitCenter,
        width: size.width * 1.85 - inset,
        height: size.width * 1.12 - inset,
      );
      canvas.drawArc(orbitRect, 3.38, 2.9, false, orbitPaint);
    }

    for (var index = 0; index < _stars.length; index++) {
      final star = _stars[index];
      final center = Offset(size.width * star.dx, size.height * star.dy);
      final radius = index.isEven ? 1.5 : 1.0;
      canvas.drawCircle(
        center,
        radius,
        Paint()..color = AppColors.text.withValues(alpha: 0.38),
      );
    }
  }

  void _drawNebula(Canvas canvas, Offset center, double radius, Color color) {
    final bounds = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: 0.32),
            color.withValues(alpha: 0.12),
            color.withValues(alpha: 0),
          ],
          stops: const [0, 0.55, 1],
        ).createShader(bounds),
    );
  }

  @override
  bool shouldRepaint(covariant _SpacePainter oldDelegate) => false;
}
