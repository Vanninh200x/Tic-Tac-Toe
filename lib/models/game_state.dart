import 'game_config.dart';

class Position {
  final int row;
  final int col;

  const Position(this.row, this.col);
}

class GameState {
  final List<List<Player?>> board;
  final Player currentPlayer;
  final Player? winner;
  final bool isDraw;
  final bool isFinished;
  final int moveCount;
  final Position? lastMove;
  final List<Position>? winningLine;

  const GameState({
    required this.board,
    required this.currentPlayer,
    this.winner,
    this.isDraw = false,
    this.isFinished = false,
    this.moveCount = 0,
    this.lastMove,
    this.winningLine,
  });

  factory GameState.initial(int size) {
    return GameState(
      board: List.generate(size, (_) => List<Player?>.filled(size, null)),
      currentPlayer: Player.x,
    );
  }

  int get boardSize => board.length;
}
