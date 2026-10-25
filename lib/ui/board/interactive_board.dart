import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/game_models.dart';
import '../../providers/game_controller.dart';
import '../../providers/settings_controller.dart';
import 'board_painter.dart';

class InteractiveBoard extends StatefulWidget {
  final GameController gameController;
  final SettingsController settingsController;
  final TransformationController? transformationController;

  const InteractiveBoard({
    super.key,
    required this.gameController,
    required this.settingsController,
    this.transformationController,
  });

  @override
  State<InteractiveBoard> createState() => _InteractiveBoardState();
}

class _InteractiveBoardState extends State<InteractiveBoard> {
  late TransformationController _transformController;

  @override
  void initState() {
    super.initState();
    _transformController = widget.transformationController ?? TransformationController();
  }

  @override
  void dispose() {
    if (widget.transformationController == null) {
      _transformController.dispose();
    }
    super.dispose();
  }

  double _calculateCellSize(int boardSize, double availableWidth) {
    // Fit the complete board in the viewport initially. InteractiveViewer
    // still lets the player zoom in for larger boards.
    final coordinateOffset = widget.settingsController.showCoordinates ? 24.0 : 8.0;
    final gridWidth = (availableWidth - coordinateOffset * 2).clamp(0.0, double.infinity);
    final fitCellSize = gridWidth / boardSize;

    // Keep small boards comfortable to tap while ensuring 20x20 starts with
    // all rows and columns visible instead of clipping the right/bottom edge.
    final preferredCellSize = switch (boardSize) {
      <= 3 => 96.0,
      <= 5 => 64.0,
      <= 10 => 52.0,
      <= 15 => 46.0,
      _ => 42.0,
    };
    return fitCellSize.clamp(1.0, preferredCellSize);
  }

  void _handleTapUp(TapUpDetails details, double cellSize, double coordOffset, int boardSize) {
    if (!widget.gameController.isHumanTurn) return;

    final localPos = details.localPosition;
    final adjustedX = localPos.dx - coordOffset;
    final adjustedY = localPos.dy - coordOffset;

    if (adjustedX < 0 || adjustedY < 0) return;

    final col = (adjustedX / cellSize).floor();
    final row = (adjustedY / cellSize).floor();

    if (row >= 0 && row < boardSize && col >= 0 && col < boardSize) {
      widget.gameController.makeMove(CellCoord(row, col));
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = widget.gameController.config.boardSize;
        final showCoords = widget.settingsController.showCoordinates;
        final coordOffset = showCoords ? 24.0 : 8.0;

        final availableWidth = constraints.maxWidth;
        final cellSize = _calculateCellSize(boardSize, availableWidth);

        final totalWidth = boardSize * cellSize + coordOffset * 2;
        final totalHeight = boardSize * cellSize + coordOffset * 2;

        final themeConfig = AppTheme.getConfig(widget.settingsController.themeMode);

        return ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: InteractiveViewer(
            transformationController: _transformController,
            boundaryMargin: const EdgeInsets.all(60),
            minScale: 0.35,
            maxScale: 3.5,
            panEnabled: true,
            scaleEnabled: true,
            child: Center(
              child: GestureDetector(
                onTapUp: (details) => _handleTapUp(
                  details,
                  cellSize,
                  coordOffset,
                  boardSize,
                ),
                child: CustomPaint(
                  size: Size(totalWidth, totalHeight),
                  painter: BoardPainter(
                    board: widget.gameController.board,
                    winResult: widget.gameController.winResult,
                    lastMove: widget.gameController.lastMove,
                    hintMove: widget.gameController.hintMove,
                    themeConfig: themeConfig,
                    showCoordinates: showCoords,
                    cellSize: cellSize,
                    coordinateOffset: coordOffset,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
