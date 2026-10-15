import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../models/game_config.dart';
import '../models/game_state.dart';

/// Tìm nước đi trên isolate riêng để việc tính toán không khóa giao diện.
class AiEngine {
  const AiEngine._();

  static Future<Position?> chooseMove({
    required GameState state,
    required int winLength,
    required AiDifficulty difficulty,
  }) async {
    if (state.isFinished) return null;
    final board = state.board
        .map((row) => row.map((piece) => piece == null ? 0 : piece == Player.x ? 1 : 2).toList())
        .toList();
    final result = await compute<Map<String, Object>, List<int>?>(
      _chooseMoveWorker,
      <String, Object>{
        'board': board,
        'winLength': winLength,
        'aiPlayer': state.currentPlayer == Player.x ? 1 : 2,
        'difficulty': difficulty.name,
      },
    );
    if (result == null || result.length != 2) return null;
    return Position(result[0], result[1]);
  }
}

List<int>? _chooseMoveWorker(Map<String, Object> input) {
  final rawBoard = input['board'] as List;
  final board = rawBoard
      .map((row) => (row as List).map((cell) => (cell as num).toInt()).toList())
      .toList();
  final search = _SearchCore(
    board: board,
    winLength: input['winLength'] as int,
    aiPlayer: input['aiPlayer'] as int,
    difficulty: input['difficulty'] as String,
  );
  final move = search.findBestMove();
  return move == null ? null : <int>[move.row, move.col];
}

class _SearchMove {
  final int row;
  final int col;
  const _SearchMove(this.row, this.col);
}

class _SearchCore {
  final List<List<int>> board;
  final int winLength;
  final int aiPlayer;
  final String difficulty;
  late final int size = board.length;
  late final int opponent = aiPlayer == 1 ? 2 : 1;
  late final DateTime deadline;
  bool _timedOut = false;
  int _nodes = 0;

  _SearchCore({
    required this.board,
    required this.winLength,
    required this.aiPlayer,
    required this.difficulty,
  }) {
    final timeLimit = difficulty == 'hard' ? 950 : difficulty == 'medium' ? 650 : 400;
    deadline = DateTime.now().add(Duration(milliseconds: timeLimit));
  }

  _SearchMove? findBestMove() {
    final empty = <_SearchMove>[];
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        if (board[r][c] == 0) empty.add(_SearchMove(r, c));
      }
    }
    if (empty.isEmpty) return null;

    // Trên bàn 3x3, Minimax đầy đủ cho kết quả tối ưu.
    if (size == 3 && winLength == 3) return _findMinimaxMove(empty);

    final limit = difficulty == 'hard' ? 18 : difficulty == 'medium' ? 13 : 9;
    final candidates = _orderedCandidates(limit);
    if (candidates.isEmpty) return empty.first;

    // Có sẵn nước thắng? Chọn ngay; nếu đối thủ sắp thắng thì ưu tiên chặn.
    for (final move in candidates) {
      board[move.row][move.col] = aiPlayer;
      final wins = _hasWinAt(move.row, move.col, aiPlayer);
      board[move.row][move.col] = 0;
      if (wins) return move;
    }
    for (final move in candidates) {
      board[move.row][move.col] = opponent;
      final opponentWins = _hasWinAt(move.row, move.col, opponent);
      board[move.row][move.col] = 0;
      if (opponentWins) return move;
    }

    final maximumDepth = difficulty == 'hard' ? 4 : difficulty == 'medium' ? 2 : 1;
    _SearchMove? bestCompletedMove = candidates.first;

    // Iterative deepening: nếu chạm thời hạn, giữ kết quả tốt nhất của độ sâu đã xong.
    for (var depth = 1; depth <= maximumDepth; depth++) {
      if (_expired()) break;
      _timedOut = false;
      var iterationCompleted = true;
      var iterationBestScore = -_infinity;
      _SearchMove? iterationBestMove;
      var alpha = -_infinity;
      final beta = _infinity;

      for (final move in candidates) {
        if (_expired()) {
          iterationCompleted = false;
          break;
        }
        board[move.row][move.col] = aiPlayer;
        final score = _alphaBeta(
          currentPlayer: opponent,
          remainingDepth: depth - 1,
          alpha: alpha,
          beta: beta,
          lastRow: move.row,
          lastCol: move.col,
          lastPlayer: aiPlayer,
          ply: 1,
        );
        board[move.row][move.col] = 0;
        if (_timedOut) {
          iterationCompleted = false;
          break;
        }
        if (score > iterationBestScore) {
          iterationBestScore = score;
          iterationBestMove = move;
        }
        alpha = math.max(alpha, iterationBestScore).toInt();
      }

      if (iterationCompleted && iterationBestMove != null) {
        bestCompletedMove = iterationBestMove;
      } else {
        break;
      }
      if (iterationBestScore.abs() >= 900000) break;
    }
    return bestCompletedMove;
  }

  static const int _infinity = 2000000000;

  _SearchMove _findMinimaxMove(List<_SearchMove> moves) {
    var bestScore = -_infinity;
    var bestMove = moves.first;
    // Ưu tiên ô trung tâm trước để thứ tự kết quả ổn định.
    moves.sort((a, b) => _centerDistance(a).compareTo(_centerDistance(b)));
    for (final move in moves) {
      board[move.row][move.col] = aiPlayer;
      final score = _minimax(
        player: opponent,
        lastRow: move.row,
        lastCol: move.col,
        lastPlayer: aiPlayer,
        ply: 1,
      );
      board[move.row][move.col] = 0;
      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }
    return bestMove;
  }

  int _minimax({
    required int player,
    required int lastRow,
    required int lastCol,
    required int lastPlayer,
    required int ply,
  }) {
    if (_hasWinAt(lastRow, lastCol, lastPlayer)) {
      return lastPlayer == aiPlayer ? 1000 - ply : -1000 + ply;
    }
    if (_isFull()) return 0;

    var best = player == aiPlayer ? -_infinity : _infinity;
    final moves = <_SearchMove>[];
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        if (board[r][c] == 0) moves.add(_SearchMove(r, c));
      }
    }
    moves.sort((a, b) => _centerDistance(a).compareTo(_centerDistance(b)));
    for (final move in moves) {
      board[move.row][move.col] = player;
      final score = _minimax(
        player: player == aiPlayer ? opponent : aiPlayer,
        lastRow: move.row,
        lastCol: move.col,
        lastPlayer: player,
        ply: ply + 1,
      );
      board[move.row][move.col] = 0;
      if (player == aiPlayer) {
        best = math.max(best, score).toInt();
      } else {
        best = math.min(best, score).toInt();
      }
    }
    return best;
  }

  int _centerDistance(_SearchMove move) {
    final center = (size - 1) / 2;
    return ((move.row - center).abs() + (move.col - center).abs() * 1.01).round();
  }

  bool _expired() {
    if (DateTime.now().isAfter(deadline)) {
      _timedOut = true;
      return true;
    }
    return false;
  }

  List<_SearchMove> _orderedCandidates(int limit) {
    final occupied = <_SearchMove>[];
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        if (board[r][c] != 0) occupied.add(_SearchMove(r, c));
      }
    }
    if (occupied.isEmpty) {
      return <_SearchMove>[_SearchMove(size ~/ 2, size ~/ 2)];
    }

    final indexes = <int>{};
    for (final token in occupied) {
      for (var dr = -2; dr <= 2; dr++) {
        for (var dc = -2; dc <= 2; dc++) {
          final r = token.row + dr;
          final c = token.col + dc;
          if (r >= 0 && r < size && c >= 0 && c < size && board[r][c] == 0) {
            indexes.add(r * size + c);
          }
        }
      }
    }
    final result = indexes.map((i) => _SearchMove(i ~/ size, i % size)).toList();
    result.sort((a, b) => _candidatePriority(b).compareTo(_candidatePriority(a)));
    if (result.length > limit) return result.take(limit).toList();
    return result;
  }

  double _candidatePriority(_SearchMove move) {
    final own = _localPotential(move.row, move.col, aiPlayer);
    final defence = _localPotential(move.row, move.col, opponent);
    final centerBonus = size - _centerDistance(move);
    return own + defence * 0.96 + centerBonus * 0.01;
  }

  double _localPotential(int row, int col, int player) {
    const dirs = <List<int>>[[0, 1], [1, 0], [1, 1], [1, -1]];
    var score = 0.0;
    for (final d in dirs) {
      var count = 1;
      var openEnds = 0;
      for (final sign in <int>[-1, 1]) {
        var r = row + d[0] * sign;
        var c = col + d[1] * sign;
        while (r >= 0 && r < size && c >= 0 && c < size && board[r][c] == player) {
          count++;
          r += d[0] * sign;
          c += d[1] * sign;
        }
        if (r >= 0 && r < size && c >= 0 && c < size && board[r][c] == 0) openEnds++;
      }
      if (count >= winLength) {
        score += 100000;
      } else {
        score += math.pow(5, count).toDouble() * (openEnds == 2 ? 1.5 : openEnds == 1 ? 1.0 : 0.15);
      }
    }
    return score;
  }

  int _alphaBeta({
    required int currentPlayer,
    required int remainingDepth,
    required int alpha,
    required int beta,
    required int lastRow,
    required int lastCol,
    required int lastPlayer,
    required int ply,
  }) {
    _nodes++;
    if ((_nodes & 63) == 0 && _expired()) return _evaluateBoard();
    if (_hasWinAt(lastRow, lastCol, lastPlayer)) {
      return lastPlayer == aiPlayer ? 1000000 - ply : -1000000 + ply;
    }
    if (_isFull()) return 0;
    if (remainingDepth <= 0) return _evaluateBoard();

    final candidates = _orderedCandidates(difficulty == 'hard' ? 11 : 9);
    if (candidates.isEmpty) return _evaluateBoard();
    var a = alpha;
    var b = beta;
    if (currentPlayer == aiPlayer) {
      var value = -_infinity;
      for (final move in candidates) {
        if (_timedOut) break;
        board[move.row][move.col] = currentPlayer;
        final score = _alphaBeta(
          currentPlayer: opponent,
          remainingDepth: remainingDepth - 1,
          alpha: a,
          beta: b,
          lastRow: move.row,
          lastCol: move.col,
          lastPlayer: currentPlayer,
          ply: ply + 1,
        );
        board[move.row][move.col] = 0;
        value = math.max(value, score).toInt();
        a = math.max(a, value).toInt();
        if (b <= a) break;
      }
      return value;
    } else {
      var value = _infinity;
      for (final move in candidates) {
        if (_timedOut) break;
        board[move.row][move.col] = currentPlayer;
        final score = _alphaBeta(
          currentPlayer: aiPlayer,
          remainingDepth: remainingDepth - 1,
          alpha: a,
          beta: b,
          lastRow: move.row,
          lastCol: move.col,
          lastPlayer: currentPlayer,
          ply: ply + 1,
        );
        board[move.row][move.col] = 0;
        value = math.min(value, score).toInt();
        b = math.min(b, value).toInt();
        if (b <= a) break;
      }
      return value;
    }
  }

  int _evaluateBoard() {
    const dirs = <List<int>>[[0, 1], [1, 0], [1, 1], [1, -1]];
    var score = 0;
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        for (final d in dirs) {
          final endR = r + (winLength - 1) * d[0];
          final endC = c + (winLength - 1) * d[1];
          if (endR < 0 || endR >= size || endC < 0 || endC >= size) continue;
          var aiCount = 0;
          var opponentCount = 0;
          for (var k = 0; k < winLength; k++) {
            final value = board[r + k * d[0]][c + k * d[1]];
            if (value == aiPlayer) aiCount++;
            if (value == opponent) opponentCount++;
          }
          if (aiCount > 0 && opponentCount > 0) continue;
          if (aiCount > 0) score += _patternWeight(aiCount);
          if (opponentCount > 0) score -= (_patternWeight(opponentCount) * 1.08).round();
        }
      }
    }
    return score;
  }

  int _patternWeight(int count) {
    if (count >= winLength) return 1000000;
    if (count <= 0) return 0;
    return math.min(80000, math.pow(5, count).round()).toInt();
  }

  bool _hasWinAt(int row, int col, int player) {
    if (row < 0 || row >= size || col < 0 || col >= size) return false;
    const dirs = <List<int>>[[0, 1], [1, 0], [1, 1], [1, -1]];
    for (final d in dirs) {
      var count = 1;
      for (final sign in <int>[-1, 1]) {
        var r = row + d[0] * sign;
        var c = col + d[1] * sign;
        while (r >= 0 && r < size && c >= 0 && c < size && board[r][c] == player) {
          count++;
          r += d[0] * sign;
          c += d[1] * sign;
        }
      }
      if (count >= winLength) return true;
    }
    return false;
  }

  bool _isFull() {
    for (final row in board) {
      if (row.contains(0)) return false;
    }
    return true;
  }
}
