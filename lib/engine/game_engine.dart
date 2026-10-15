import '../models/game_config.dart';
import '../models/game_state.dart';
import 'win_checker.dart';

class GameEngine {
  const GameEngine._();

  /// Trả về null nếu nước đi không hợp lệ; nếu hợp lệ sẽ trả trạng thái mới.
  static GameState? playMove({
    required GameState state,
    required int row,
    required int col,
    required int winLength,
  }) {
    final size = state.boardSize;
    if (size < 3 ||
        state.board.any((line) => line.length != size) ||
        winLength < 3 ||
        winLength > size ||
        state.isFinished ||
        row < 0 ||
        col < 0 ||
        row >= size ||
        col >= size ||
        state.board[row][col] != null) {
      return null;
    }

    final board = state.board.map((line) => List<Player?>.from(line)).toList();
    final player = state.currentPlayer;
    board[row][col] = player;
    final moveCount = state.moveCount + 1;
    final lastMove = Position(row, col);
    final winningLine = WinChecker.findWinningLine(
      board: board,
      lastMove: lastMove,
      player: player,
      winLength: winLength,
    );
    final winner = winningLine == null ? null : player;
    final isDraw = winner == null && moveCount >= size * size;
    final isFinished = winner != null || isDraw;

    return GameState(
      board: board,
      currentPlayer: isFinished ? player : player.opponent,
      winner: winner,
      isDraw: isDraw,
      isFinished: isFinished,
      moveCount: moveCount,
      lastMove: lastMove,
      winningLine: winningLine,
    );
  }
}
