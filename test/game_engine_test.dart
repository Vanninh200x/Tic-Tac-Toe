import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/engine/ai_heuristic.dart';
import 'package:tic_tac_toe/engine/game_engine.dart';
import 'package:tic_tac_toe/models/game_enums.dart';
import 'package:tic_tac_toe/models/game_models.dart';
import 'package:tic_tac_toe/models/game_stats.dart';

void main() {
  group('Advanced Game Engine & Caro Rules', () {
    test('15x15 board diagonal win detection', () {
      final board = GameEngine.createEmptyBoard(15);
      // Main diagonal: (5,5), (6,6), (7,7), (8,8), (9,9)
      for (var i = 0; i < 5; i++) {
        board[5 + i][5 + i] = PlayerType.x;
      }

      final win = GameEngine.checkWin(
        board: board,
        lastMove: const CellCoord(9, 9),
        winLength: 5,
      );

      expect(win, isNotNull);
      expect(win!.winner, PlayerType.x);
      expect(win.winningCells.length, 5);
      expect(win.direction, WinDirection.diagonalMain);
    });

    test('Anti-diagonal win detection', () {
      final board = GameEngine.createEmptyBoard(10);
      for (var i = 0; i < 5; i++) {
        board[2 + i][8 - i] = PlayerType.o;
      }

      final win = GameEngine.checkWin(
        board: board,
        lastMove: const CellCoord(4, 6),
        winLength: 5,
      );

      expect(win, isNotNull);
      expect(win!.winner, PlayerType.o);
      expect(win.direction, WinDirection.diagonalAnti);
    });

    test('AI Heuristic immediately blocks 4 in a row', () {
      final board = GameEngine.createEmptyBoard(15);
      // Human (X) has 4 in a row: (7, 3), (7, 4), (7, 5), (7, 6)
      for (var c = 3; c <= 6; c++) {
        board[7][c] = PlayerType.x;
      }

      final bestMove = AIHeuristicEngine.getBestMoveLargeBoard(
        board: board,
        aiPlayer: PlayerType.o,
        difficulty: AIDifficulty.master,
        winLength: 5,
      );

      expect(bestMove, isNotNull);
      // AI must block at either (7, 2) or (7, 7)
      final isBlockingEnd =
          (bestMove!.row == 7 && bestMove.col == 2) || (bestMove.row == 7 && bestMove.col == 7);
      expect(isBlockingEnd, isTrue);
    });

    test('GameStats serialization to and from JSON', () {
      const stats = GameStats(
        totalGames: 10,
        xWins: 6,
        oWins: 3,
        draws: 1,
        vsAiWins: 4,
        vsAiLosses: 2,
      );

      final jsonStr = stats.toJson();
      final restored = GameStats.fromJson(jsonStr);

      expect(restored.totalGames, 10);
      expect(restored.xWins, 6);
      expect(restored.oWins, 3);
      expect(restored.draws, 1);
      expect(restored.vsAiWins, 4);
      expect(restored.vsAiLosses, 2);
      expect(restored.winRatePercent, 60.0);
    });
  });
}
