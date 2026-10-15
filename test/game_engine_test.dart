import 'package:flutter_board_game/engine/game_engine.dart';
import 'package:flutter_board_game/engine/win_checker.dart';
import 'package:flutter_board_game/models/game_config.dart';
import 'package:flutter_board_game/models/game_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameEngine.playMove', () {
    test('places a mark and alternates the active player', () {
      final initial = GameState.initial(3);
      final next = GameEngine.playMove(
        state: initial,
        row: 1,
        col: 2,
        winLength: 3,
      );

      expect(next, isNotNull);
      expect(next!.board[1][2], Player.x);
      expect(next.currentPlayer, Player.o);
      expect(next.moveCount, 1);
      expect(initial.board[1][2], isNull);
    });

    test(
      'rejects occupied, out-of-bounds, finished, and invalid-rule moves',
      () {
        final firstMove = GameEngine.playMove(
          state: GameState.initial(3),
          row: 0,
          col: 0,
          winLength: 3,
        )!;
        final finished = GameState(
          board: firstMove.board,
          currentPlayer: Player.o,
          isFinished: true,
          moveCount: 1,
        );

        expect(
          GameEngine.playMove(state: firstMove, row: 0, col: 0, winLength: 3),
          isNull,
        );
        expect(
          GameEngine.playMove(state: firstMove, row: -1, col: 0, winLength: 3),
          isNull,
        );
        expect(
          GameEngine.playMove(state: firstMove, row: 1, col: 1, winLength: 2),
          isNull,
        );
        expect(
          GameEngine.playMove(state: finished, row: 1, col: 1, winLength: 3),
          isNull,
        );
      },
    );

    test('detects horizontal, vertical, and diagonal wins', () {
      final cases = <List<Position>>[
        const [Position(0, 0), Position(0, 1), Position(0, 2)],
        const [Position(0, 0), Position(1, 0), Position(2, 0)],
        const [Position(0, 0), Position(1, 1), Position(2, 2)],
        const [Position(0, 2), Position(1, 1), Position(2, 0)],
      ];

      for (final moves in cases) {
        var state = GameState.initial(3);
        for (final move in moves) {
          state = GameEngine.playMove(
            state: state,
            row: move.row,
            col: move.col,
            winLength: 3,
          )!;
          if (state.moveCount < 3) {
            state = GameState(
              board: state.board,
              currentPlayer: Player.x,
              moveCount: state.moveCount,
            );
          }
        }
        expect(state.winner, Player.x);
        expect(state.isFinished, isTrue);
        expect(state.winningLine, hasLength(3));
      }
    });

    test('detects a draw on a full board without a winning line', () {
      const moves = <Position>[
        Position(0, 0),
        Position(0, 1),
        Position(0, 2),
        Position(1, 1),
        Position(1, 0),
        Position(1, 2),
        Position(2, 1),
        Position(2, 0),
        Position(2, 2),
      ];
      var state = GameState.initial(3);

      for (final move in moves) {
        state = GameEngine.playMove(
          state: state,
          row: move.row,
          col: move.col,
          winLength: 3,
        )!;
      }

      expect(state.isDraw, isTrue);
      expect(state.isFinished, isTrue);
      expect(state.winner, isNull);
      expect(state.moveCount, 9);
    });

    test(
      'does not report a win when the last move is not in a winning run',
      () {
        var state = GameState.initial(5);
        for (final move in const [
          Position(2, 0),
          Position(0, 0),
          Position(2, 1),
          Position(0, 1),
          Position(2, 2),
          Position(1, 0),
        ]) {
          state = GameEngine.playMove(
            state: state,
            row: move.row,
            col: move.col,
            winLength: 4,
          )!;
        }

        expect(state.isFinished, isFalse);
        expect(state.winner, isNull);
      },
    );
  });

  group('WinChecker', () {
    test('returns the complete overline, not only the minimum win length', () {
      final board = List<List<Player?>>.generate(
        5,
        (_) => List<Player?>.filled(5, null),
      );
      for (var col = 0; col < 5; col++) {
        board[2][col] = Player.x;
      }

      final line = WinChecker.findWinningLine(
        board: board,
        lastMove: const Position(2, 2),
        player: Player.x,
        winLength: 4,
      );

      expect(line, hasLength(5));
    });

    test(
      'rejects invalid board shapes and a last move belonging to another player',
      () {
        expect(
          WinChecker.findWinningLine(
            board: [
              [Player.x, null],
              [null],
            ],
            lastMove: const Position(0, 0),
            player: Player.x,
            winLength: 3,
          ),
          isNull,
        );
        expect(
          WinChecker.findWinningLine(
            board: List<List<Player?>>.generate(
              3,
              (_) => List<Player?>.filled(3, null),
            ),
            lastMove: const Position(0, 0),
            player: Player.x,
            winLength: 3,
          ),
          isNull,
        );
      },
    );
  });
}
