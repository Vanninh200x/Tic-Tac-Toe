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
    if (boardSize <= 3) {
      return (availableWidth - 40) / 3;
    } else if (boardSize <= 5) {
      return (availableWidth - 40) / 5;
    } else if (boardSize <= 10) {
      return 52.0;
    } else if (boardSize <= 15) {
      return 46.0;
    } else {
      return 42.0;
    }
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
