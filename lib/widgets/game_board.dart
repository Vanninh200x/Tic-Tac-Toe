import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/game_config.dart';
import '../models/game_state.dart';

class GameBoard extends StatelessWidget {
  final GameState state;
  final double side;
  final bool inputEnabled;
  final ValueChanged<Position> onMove;

  const GameBoard({
    super.key,
    required this.state,
    required this.side,
    required this.inputEnabled,
    required this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: side,
      height: side,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: inputEnabled
            ? (details) {
                final cellSize = side / state.boardSize;
                final row = (details.localPosition.dy / cellSize).floor();
                final col = (details.localPosition.dx / cellSize).floor();
                if (row >= 0 &&
                    row < state.boardSize &&
                    col >= 0 &&
                    col < state.boardSize) {
                  onMove(Position(row, col));
                }
              }
            : null,
        child: CustomPaint(
          size: Size.square(side),
          painter: _BoardPainter(state),
        ),
      ),
    );
  }
}

class _BoardPainter extends CustomPainter {
  final GameState state;
  _BoardPainter(this.state);

  @override
  void paint(Canvas canvas, Size size) {
    final boardSize = state.boardSize;
    if (boardSize <= 0) return;
    final cell = size.width / boardSize;
    final boardRect = Offset.zero & size;
    final roundedBoard = RRect.fromRectAndRadius(
      boardRect,
      const Radius.circular(18),
    );

    canvas.save();
    canvas.clipRRect(roundedBoard);
    canvas.drawRRect(roundedBoard, Paint()..color = const Color(0xFF0B1030));

    final gridGlow = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.16)
      ..strokeWidth = boardSize <= 5 ? 7 : 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    final gridPaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.22)
      ..strokeWidth = boardSize <= 5 ? 2 : 1
      ..style = PaintingStyle.stroke;
    for (var i = 0; i <= boardSize; i++) {
      final offset = i * cell;
      canvas.drawLine(Offset(offset, 0), Offset(offset, size.height), gridGlow);
      canvas.drawLine(Offset(0, offset), Offset(size.width, offset), gridGlow);
      canvas.drawLine(
        Offset(offset, 0),
        Offset(offset, size.height),
        gridPaint,
      );
      canvas.drawLine(Offset(0, offset), Offset(size.width, offset), gridPaint);
    }

    final lastMove = state.lastMove;
    if (lastMove != null && !state.isFinished) {
      final center = Offset(
        (lastMove.col + 0.5) * cell,
        (lastMove.row + 0.5) * cell,
      );
      canvas.drawCircle(
        center,
        cell * 0.34,
        Paint()
          ..color = AppColors.accent.withValues(alpha: 0.11)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }

    for (var row = 0; row < boardSize; row++) {
      for (var col = 0; col < boardSize; col++) {
        final piece = state.board[row][col];
        if (piece == null) continue;
        final center = Offset((col + 0.5) * cell, (row + 0.5) * cell);
        final isWinningPiece =
            state.winningLine?.any((p) => p.row == row && p.col == col) ??
            false;
        if (isWinningPiece) {
          canvas.drawCircle(
            center,
            cell * 0.39,
            Paint()..color = AppColors.success.withValues(alpha: 0.16),
          );
        }
        if (piece == Player.x) {
          final glow = Paint()
            ..color = AppColors.accent.withValues(alpha: 0.7)
            ..strokeWidth = (cell * 0.15).clamp(4.2, 10).toDouble()
            ..strokeCap = StrokeCap.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
            ..style = PaintingStyle.stroke;
          final p = Paint()
            ..color = AppColors.accent
            ..strokeWidth = (cell * 0.095).clamp(2.2, 5.5).toDouble()
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke;
          final inset = cell * 0.27;
          canvas.drawLine(
            Offset(center.dx - inset, center.dy - inset),
            Offset(center.dx + inset, center.dy + inset),
            glow,
          );
          canvas.drawLine(
            Offset(center.dx + inset, center.dy - inset),
            Offset(center.dx - inset, center.dy + inset),
            glow,
          );
          canvas.drawLine(
            Offset(center.dx - inset, center.dy - inset),
            Offset(center.dx + inset, center.dy + inset),
            p,
          );
          canvas.drawLine(
            Offset(center.dx + inset, center.dy - inset),
            Offset(center.dx - inset, center.dy + inset),
            p,
          );
        } else {
          final glow = Paint()
            ..color = AppColors.coral.withValues(alpha: 0.65)
            ..strokeWidth = (cell * 0.15).clamp(4.2, 10).toDouble()
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
            ..style = PaintingStyle.stroke;
          final p = Paint()
            ..color = AppColors.coral
            ..strokeWidth = (cell * 0.09).clamp(2.2, 5.0).toDouble()
            ..style = PaintingStyle.stroke;
          canvas.drawCircle(center, cell * 0.27, glow);
          canvas.drawCircle(center, cell * 0.27, p);
        }
      }
    }

    final winningLine = state.winningLine;
    if (winningLine != null && winningLine.length >= 2) {
      final first = winningLine.first;
      final last = winningLine.last;
      final glow = Paint()
        ..color = AppColors.success.withValues(alpha: 0.72)
        ..strokeWidth = (cell * 0.13).clamp(4.0, 9.0).toDouble()
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
      final p = Paint()
        ..color = AppColors.success
        ..strokeWidth = (cell * 0.075).clamp(2.0, 4.2).toDouble()
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset((first.col + 0.5) * cell, (first.row + 0.5) * cell),
        Offset((last.col + 0.5) * cell, (last.row + 0.5) * cell),
        glow,
      );
      canvas.drawLine(
        Offset((first.col + 0.5) * cell, (first.row + 0.5) * cell),
        Offset((last.col + 0.5) * cell, (last.row + 0.5) * cell),
        p,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BoardPainter oldDelegate) =>
      oldDelegate.state != state;
}
