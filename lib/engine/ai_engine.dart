import 'dart:math';
import '../models/game_enums.dart';
import '../models/game_models.dart';
import 'ai_heuristic.dart';
import 'game_engine.dart';

class AIEngine {
  /// Thuật toán Minimax chuẩn cho bàn 3x3 (Tic Tac Toe)
  /// Đảm bảo AI ở cấp độ Master không bao giờ thua
  static CellCoord? getMinimax3x3(
    List<List<PlayerType?>> board,
    PlayerType player,
    AIDifficulty difficulty,
  ) {
    final availableMoves = GameEngine.getAvailableMoves(board);
    if (availableMoves.isEmpty) return null;

    final opponent = player.opponent;

    // 1. Nếu có nước THẮNG NGAY LẬP TỨC -> Đánh ngay!
    for (final move in availableMoves) {
      board[move.row][move.col] = player;
      final win = GameEngine.checkWin(
        board: board,
        lastMove: move,
        winLength: 3,
      );
      board[move.row][move.col] = null;
      if (win != null) return move;
    }

    // 2. Nếu đối thủ có nước THẮNG NGAY LẬP TỨC -> BẮT BUỘC CHẶN NGAY!
    for (final move in availableMoves) {
      board[move.row][move.col] = opponent;
      final win = GameEngine.checkWin(
        board: board,
        lastMove: move,
        winLength: 3,
      );
      board[move.row][move.col] = null;
      if (win != null) return move;
    }

    // 3. Nếu độ khó DỄ: Chọn ngẫu nhiên nước đi
    final random = Random();
    if (difficulty == AIDifficulty.easy) {
      return availableMoves[random.nextInt(availableMoves.length)];
    }

    // 4. Nếu độ khó TRUNG BÌNH: Có 40% sai lầm
    if (difficulty == AIDifficulty.medium && random.nextDouble() < 0.40) {
      return availableMoves[random.nextInt(availableMoves.length)];
    }

    // 5. Minimax hoàn hảo cho HARD và MASTER
    CellCoord? bestMove;
    var bestScore = -999999;

    for (final move in availableMoves) {
      board[move.row][move.col] = player;
      final score = _minimax(
        board: board,
        depth: 0,
        isMaximizing: false,
        aiPlayer: player,
        opponent: opponent,
        alpha: -999999,
        beta: 999999,
        lastMove: move,
      );
      board[move.row][move.col] = null;

      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }

    return bestMove ?? availableMoves.first;
  }

  static int _minimax({
    required List<List<PlayerType?>> board,
    required int depth,
    required bool isMaximizing,
    required PlayerType aiPlayer,
    required PlayerType opponent,
    required int alpha,
    required int beta,
    required CellCoord lastMove,
  }) {
    final win = GameEngine.checkWin(
      board: board,
      lastMove: lastMove,
      winLength: 3,
    );

    if (win != null) {
      return win.winner == aiPlayer ? (10 - depth) : (depth - 10);
    }

    if (GameEngine.isBoardFull(board) || depth >= 9) {
      return 0; // Hòa
    }

    final availableMoves = GameEngine.getAvailableMoves(board);

    if (isMaximizing) {
      var maxEval = -999999;
      for (final move in availableMoves) {
        board[move.row][move.col] = aiPlayer;
        final evaluation = _minimax(
          board: board,
          depth: depth + 1,
          isMaximizing: false,
          aiPlayer: aiPlayer,
          opponent: opponent,
          alpha: alpha,
          beta: beta,
          lastMove: move,
        );
        board[move.row][move.col] = null;

        maxEval = max(maxEval, evaluation);
        alpha = max(alpha, evaluation);
        if (beta <= alpha) break;
      }
      return maxEval;
    } else {
      var minEval = 999999;
      for (final move in availableMoves) {
        board[move.row][move.col] = opponent;
        final evaluation = _minimax(
          board: board,
          depth: depth + 1,
          isMaximizing: true,
          aiPlayer: aiPlayer,
          opponent: opponent,
          alpha: alpha,
          beta: beta,
          lastMove: move,
        );
        board[move.row][move.col] = null;

        minEval = min(minEval, evaluation);
        beta = min(beta, evaluation);
        if (beta <= alpha) break;
      }
      return minEval;
    }
  }

  /// Bộ điều phối nước đi AI cho mọi kích thước bàn cờ
  static Future<CellCoord?> getBestMove({
    required List<List<PlayerType?>> board,
    required PlayerType aiPlayer,
    required AIDifficulty difficulty,
    required int winLength,
    bool blockedEndsRule = false,
  }) async {
    // Độ trễ nhẹ tạo cảm giác máy đang "suy nghĩ" tự nhiên
    await Future.delayed(const Duration(milliseconds: 250));

    if (board.length == 3 && winLength == 3) {
      return getMinimax3x3(board, aiPlayer, difficulty);
    }

    return AIHeuristicEngine.getBestMoveLargeBoard(
      board: board,
      aiPlayer: aiPlayer,
      difficulty: difficulty,
      winLength: winLength,
      blockedEndsRule: blockedEndsRule,
    );
  }
}
