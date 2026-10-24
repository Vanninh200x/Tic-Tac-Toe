import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/engine/ai_engine.dart';
import 'package:tic_tac_toe/engine/game_engine.dart';
import 'package:tic_tac_toe/models/game_enums.dart';
import 'package:tic_tac_toe/models/game_models.dart';

void main() {
  group('game rules', () {
    test('detects horizontal, vertical, and diagonal wins', () {
      final horizontal = GameEngine.createEmptyBoard(5);
      for (var c = 0; c < 4; c++) {
        horizontal[2][c] = PlayerType.x;
      }
      expect(
        GameEngine.checkWin(
          board: horizontal,
          lastMove: const CellCoord(2, 3),
          winLength: 4,
        ),
        isNotNull,
      );
      final vertical = GameEngine.createEmptyBoard(5);
      for (var r = 0; r < 4; r++) {
        vertical[r][1] = PlayerType.o;
      }
      expect(
        GameEngine.checkWin(
          board: vertical,
          lastMove: const CellCoord(3, 1),
          winLength: 4,
        ),
        isNotNull,
      );
      final diagonal = GameEngine.createEmptyBoard(5);
      for (var i = 0; i < 4; i++) {
        diagonal[i][i] = PlayerType.x;
      }
      expect(
        GameEngine.checkWin(
          board: diagonal,
          lastMove: const CellCoord(3, 3),
          winLength: 4,
        ),
        isNotNull,
      );
    });

    test('blocked-ends rule rejects a run blocked at both ends', () {
      final board = GameEngine.createEmptyBoard(7);
      board[3][0] = PlayerType.o;
      board[3][1] = PlayerType.x;
      board[3][2] = PlayerType.x;
      board[3][3] = PlayerType.x;
      board[3][4] = PlayerType.x;
      board[3][5] = PlayerType.x;
      board[3][6] = PlayerType.o;
      expect(
        GameEngine.checkWin(
          board: board,
          lastMove: const CellCoord(3, 4),
          winLength: 5,
          blockedEndsRule: true,
        ),
        isNull,
      );
      expect(
        GameEngine.checkWin(
          board: board,
          lastMove: const CellCoord(3, 4),
          winLength: 5,
        ),
        isNotNull,
      );
    });

    test('blocked-ends rule still accepts a run with one open end', () {
      final board = GameEngine.createEmptyBoard(7);
      board[3][0] = PlayerType.o;
      for (var col = 1; col <= 5; col++) {
        board[3][col] = PlayerType.x;
      }

      expect(
        GameEngine.checkWin(
          board: board,
          lastMove: const CellCoord(3, 3),
          winLength: 5,
          blockedEndsRule: true,
        ),
        isNotNull,
      );
    });

    test('AI takes an immediate win and blocks an immediate loss', () {
      final board = GameEngine.createEmptyBoard(3);
      board[0][0] = PlayerType.o;
      board[0][1] = PlayerType.o;
      board[1][0] = PlayerType.x;
      board[1][1] = PlayerType.x;
      expect(
        AIEngine.getMinimax3x3(board, PlayerType.o, AIDifficulty.master),
        const CellCoord(0, 2),
      );
      expect(
        AIEngine.getMinimax3x3(board, PlayerType.x, AIDifficulty.master),
        const CellCoord(1, 2),
      );
    });
  });
}
