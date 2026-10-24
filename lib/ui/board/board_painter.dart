import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/game_enums.dart';
import '../../models/game_models.dart';

class BoardPainter extends CustomPainter {
  final List<List<PlayerType?>> board;
  final WinResult? winResult;
  final CellCoord? lastMove;
  final CellCoord? hintMove;
  final ThemeConfig themeConfig;
  final bool showCoordinates;
  final double cellSize;
  final double coordinateOffset;

  BoardPainter({
    required this.board,
    required this.winResult,
    required this.lastMove,
    required this.hintMove,
    required this.themeConfig,
    required this.showCoordinates,
    required this.cellSize,
    required this.coordinateOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final boardSize = board.length;
    final totalGridWidth = boardSize * cellSize;
    final totalGridHeight = boardSize * cellSize;

    final gridRect = Rect.fromLTWH(
      coordinateOffset,
      coordinateOffset,
      totalGridWidth,
      totalGridHeight,
    );

    // 1. Nền bàn cờ đổ bóng nổi 3D
    final rrect = RRect.fromRectAndRadius(gridRect, const Radius.circular(20));

    // Đổ bóng sâu
    final shadowPaint = Paint()
      ..color = themeConfig.isDark
          ? Colors.black.withValues(alpha: 0.5)
          : const Color(0xFF64748B).withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawRRect(rrect.shift(const Offset(0, 8)), shadowPaint);

    // Nền bàn cờ
    final boardBgPaint = Paint()
      ..color = themeConfig.boardBackgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, boardBgPaint);

    // Viền bàn cờ
    final borderPaint = Paint()
      ..color = themeConfig.isDark
          ? Colors.white.withValues(alpha: 0.2)
          : const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(rrect, borderPaint);

    // 2. Vẽ lưới ô vuông đậm nét, rõ ràng
    final gridPaint = Paint()
      ..color = themeConfig.gridLineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    for (var i = 1; i < boardSize; i++) {
      // Đường ngang
      final y = coordinateOffset + i * cellSize;
      canvas.drawLine(
        Offset(coordinateOffset, y),
        Offset(coordinateOffset + totalGridWidth, y),
        gridPaint,
      );

      // Đường dọc
      final x = coordinateOffset + i * cellSize;
      canvas.drawLine(
        Offset(x, coordinateOffset),
        Offset(x, coordinateOffset + totalGridHeight),
        gridPaint,
      );
    }

    // 3. Tọa độ ô (A..Z và 1..N) to rõ
    if (showCoordinates) {
      _drawCoordinates(canvas, boardSize);
    }

    // 4. Highlight ô gợi ý (Hint)
    if (hintMove != null && _isValidCoord(hintMove!, boardSize)) {
      final cellRect = Rect.fromLTWH(
        coordinateOffset + hintMove!.col * cellSize + 5,
        coordinateOffset + hintMove!.row * cellSize + 5,
        cellSize - 10,
        cellSize - 10,
      );

      final hintPaint = Paint()
        ..color = AppColors.gold.withValues(alpha: 0.35)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(cellRect, const Radius.circular(10)),
        hintPaint,
      );

      final hintBorder = Paint()
        ..color = AppColors.gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawRRect(
        RRect.fromRectAndRadius(cellRect, const Radius.circular(10)),
        hintBorder,
      );
    }

    // 5. Highlight ô vừa đánh gần nhất (Last Move)
    if (lastMove != null && _isValidCoord(lastMove!, boardSize)) {
      final cellRect = Rect.fromLTWH(
        coordinateOffset + lastMove!.col * cellSize + 4,
        coordinateOffset + lastMove!.row * cellSize + 4,
        cellSize - 8,
        cellSize - 8,
      );

      final isX = board[lastMove!.row][lastMove!.col] == PlayerType.x;
      final highlightColor = isX ? AppColors.cyanNeon : AppColors.coralNeon;

      final lastMoveFill = Paint()
        ..color = highlightColor.withValues(alpha: 0.18)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(cellRect, const Radius.circular(10)),
        lastMoveFill,
      );

      final lastMoveBorder = Paint()
        ..color = highlightColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(cellRect, const Radius.circular(10)),
        lastMoveBorder,
      );
    }

    // 6. Highlight các ô chiến thắng
    if (winResult != null) {
      final winColor = winResult!.winner == PlayerType.x
          ? AppColors.cyanNeon
          : AppColors.coralNeon;

      for (final coord in winResult!.winningCells) {
        if (_isValidCoord(coord, boardSize)) {
          final cellRect = Rect.fromLTWH(
            coordinateOffset + coord.col * cellSize + 3,
            coordinateOffset + coord.row * cellSize + 3,
            cellSize - 6,
            cellSize - 6,
          );

          final winFill = Paint()
            ..color = winColor.withValues(alpha: 0.3)
            ..style = PaintingStyle.fill;
          canvas.drawRRect(
            RRect.fromRectAndRadius(cellRect, const Radius.circular(10)),
            winFill,
          );
        }
      }
    }

    // 7. Vẽ quân cờ X và O to, sắc nét, rực rỡ
    for (var r = 0; r < boardSize; r++) {
      for (var c = 0; c < boardSize; c++) {
        final player = board[r][c];
        if (player == null) continue;

        final center = Offset(
          coordinateOffset + c * cellSize + cellSize / 2,
          coordinateOffset + r * cellSize + cellSize / 2,
        );
        final radius = (cellSize / 2) * 0.72;

        if (player == PlayerType.x) {
          _drawX(canvas, center, radius);
        } else {
          _drawO(canvas, center, radius);
        }
      }
    }

    // 8. Vẽ đường gạch laser chiến thắng
    if (winResult != null && winResult!.winningCells.length >= 2) {
      _drawWinningLine(canvas, winResult!, boardSize);
    }
  }

  void _drawCoordinates(Canvas canvas, int boardSize) {
    final textColor = themeConfig.secondaryTextColor;
    final textStyle = TextStyle(
      color: textColor,
      fontSize: 13,
      fontWeight: FontWeight.w700,
    );

    // Cột: A, B, C...
    for (var c = 0; c < boardSize; c++) {
      final label = String.fromCharCode(65 + (c % 26));
      final textSpan = TextSpan(text: label, style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      final x = coordinateOffset + c * cellSize + (cellSize - textPainter.width) / 2;
      textPainter.paint(canvas, Offset(x, 4));
    }

    // Hàng: 1, 2, 3...
    for (var r = 0; r < boardSize; r++) {
      final label = '${r + 1}';
      final textSpan = TextSpan(text: label, style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      final y = coordinateOffset + r * cellSize + (cellSize - textPainter.height) / 2;
      textPainter.paint(canvas, Offset(4, y));
    }
  }

  void _drawX(Canvas canvas, Offset center, double radius) {
    final strokeWidth = max(4.0, radius * 0.32);
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Nét chính có Gradient sắc nét
    final mainPaint = Paint()
      ..shader = const LinearGradient(
        colors: AppColors.xGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect)
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Đổ bóng nhẹ phía dưới quân cờ
    final shadowPaint = Paint()
      ..color = AppColors.cyanNeon.withValues(alpha: 0.35)
      ..strokeWidth = strokeWidth + 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawLine(
      Offset(center.dx - radius, center.dy - radius),
      Offset(center.dx + radius, center.dy + radius),
      shadowPaint,
    );
    canvas.drawLine(
      Offset(center.dx + radius, center.dy - radius),
      Offset(center.dx - radius, center.dy + radius),
      shadowPaint,
    );

    canvas.drawLine(
      Offset(center.dx - radius, center.dy - radius),
      Offset(center.dx + radius, center.dy + radius),
      mainPaint,
    );
    canvas.drawLine(
      Offset(center.dx + radius, center.dy - radius),
      Offset(center.dx - radius, center.dy + radius),
      mainPaint,
    );
  }

  void _drawO(Canvas canvas, Offset center, double radius) {
    final strokeWidth = max(4.0, radius * 0.32);
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Đổ bóng nhẹ
    final shadowPaint = Paint()
      ..color = AppColors.coralNeon.withValues(alpha: 0.35)
      ..strokeWidth = strokeWidth + 2
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(center, radius, shadowPaint);

    // Vòng tròn gradient hoàng hôn
    final mainPaint = Paint()
      ..shader = const LinearGradient(
        colors: AppColors.oGradient,
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ).createShader(rect)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, mainPaint);
  }

  void _drawWinningLine(Canvas canvas, WinResult win, int boardSize) {
    final firstCoord = win.winningCells.first;
    final lastCoord = win.winningCells.last;

    final p1 = Offset(
      coordinateOffset + firstCoord.col * cellSize + cellSize / 2,
      coordinateOffset + firstCoord.row * cellSize + cellSize / 2,
    );
    final p2 = Offset(
      coordinateOffset + lastCoord.col * cellSize + cellSize / 2,
      coordinateOffset + lastCoord.row * cellSize + cellSize / 2,
    );

    final lineColor = win.winner == PlayerType.x ? AppColors.cyanNeon : AppColors.coralNeon;

    // Laser glow line
    final laserGlow = Paint()
      ..color = lineColor.withValues(alpha: 0.8)
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawLine(p1, p2, laserGlow);

    // Laser core line
    final laserCore = Paint()
      ..color = Colors.white
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(p1, p2, laserCore);
  }

  bool _isValidCoord(CellCoord coord, int size) {
    return coord.row >= 0 && coord.row < size && coord.col >= 0 && coord.col < size;
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) => true;
}
