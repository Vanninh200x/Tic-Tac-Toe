import '../models/game_config.dart';
import '../models/game_state.dart';

class WinChecker {
  static const List<List<int>> _directions = <List<int>>[
    <int>[0, 1],
    <int>[1, 0],
    <int>[1, 1],
    <int>[1, -1],
  ];

  static List<Position>? findWinningLine({
    required List<List<Player?>> board,
    required Position lastMove,
    required Player player,
    required int winLength,
  }) {
    final size = board.length;
    if (size < 3 ||
        board.any((line) => line.length != size) ||
        winLength < 3 ||
        winLength > size ||
        lastMove.row < 0 ||
        lastMove.col < 0 ||
        lastMove.row >= size ||
        lastMove.col >= size ||
        board[lastMove.row][lastMove.col] != player) {
      return null;
    }

    for (final direction in _directions) {
      final line = <Position>[lastMove];
      for (final sign in <int>[-1, 1]) {
        var row = lastMove.row + direction[0] * sign;
        var col = lastMove.col + direction[1] * sign;
        while (row >= 0 &&
            row < size &&
            col >= 0 &&
            col < size &&
            board[row][col] == player) {
          if (sign < 0) {
            line.insert(0, Position(row, col));
          } else {
            line.add(Position(row, col));
          }
          row += direction[0] * sign;
          col += direction[1] * sign;
        }
      }
      if (line.length >= winLength) return line;
    }
    return null;
  }
}
