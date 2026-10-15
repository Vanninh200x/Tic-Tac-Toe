import 'package:flutter_board_game/engine/ai_engine.dart';
import 'package:flutter_board_game/models/game_config.dart';
import 'package:flutter_board_game/models/game_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AiEngine.chooseMove', () {
    test('takes an immediate win on a configurable board', () async {
      final state = _state(
        size: 5,
        currentPlayer: Player.o,
        pieces: const {
          (2, 0): Player.o,
          (2, 1): Player.o,
          (2, 2): Player.o,
          (0, 0): Player.x,
        },
      );

      final move = await AiEngine.chooseMove(
        state: state,
        winLength: 4,
        difficulty: AiDifficulty.easy,
      );

      expect(move, isNotNull);
      expect(state.board[move!.row][move.col], isNull);
      expect(move.row, 2);
      expect(move.col, 3);
    });

    test('blocks an opponent immediate win', () async {
      final state = _state(
        size: 5,
        currentPlayer: Player.o,
        pieces: const {
          (2, 0): Player.x,
          (2, 1): Player.x,
          (2, 2): Player.x,
          (0, 0): Player.o,
        },
      );

      final move = await AiEngine.chooseMove(
        state: state,
        winLength: 4,
        difficulty: AiDifficulty.medium,
      );

      expect(move, isNotNull);
      expect(move!.row, 2);
      expect(move.col, 3);
    });

    test('chooses the center on an empty board', () async {
      final move = await AiEngine.chooseMove(
        state: GameState.initial(5),
        winLength: 4,
        difficulty: AiDifficulty.easy,
      );

      expect(move?.row, 2);
      expect(move?.col, 2);
    });

    test('returns null after the game has finished', () async {
      final state = GameState(
        board: List<List<Player?>>.generate(
          3,
          (_) => List<Player?>.filled(3, Player.x),
        ),
        currentPlayer: Player.x,
        isFinished: true,
        moveCount: 9,
      );

      expect(
        await AiEngine.chooseMove(
          state: state,
          winLength: 3,
          difficulty: AiDifficulty.hard,
        ),
        isNull,
      );
    });
  });
}

GameState _state({
  required int size,
  required Player currentPlayer,
  required Map<(int, int), Player> pieces,
}) {
  final board = List<List<Player?>>.generate(
    size,
    (_) => List<Player?>.filled(size, null),
  );
  for (final entry in pieces.entries) {
    board[entry.key.$1][entry.key.$2] = entry.value;
  }
  return GameState(
    board: board,
    currentPlayer: currentPlayer,
    moveCount: pieces.length,
  );
}
