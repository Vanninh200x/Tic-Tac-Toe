import 'dart:math';
import '../models/game_enums.dart';
import '../models/game_models.dart';
import 'game_engine.dart';

class AIHeuristicEngine {
  static const int scoreWin = 1000000;
  static const int scoreOpenFour = 100000;
  static const int scoreClosedFour = 15000;
  static const int scoreOpenThree = 8000;
  static const int scoreClosedThree = 1000;
  static const int scoreOpenTwo = 300;
  static const int scoreClosedTwo = 50;

  /// Đánh giá nước đi tốt nhất cho bàn cờ lớn (5x5, 10x10, 15x15, 20x20)
  static CellCoord? getBestMoveLargeBoard({
    required List<List<PlayerType?>> board,
    required PlayerType aiPlayer,
    required AIDifficulty difficulty,
    required int winLength,
    bool blockedEndsRule = false,
  }) {
    final opponent = aiPlayer.opponent;
    final candidates = GameEngine.getCandidateMoves(board, radius: 1);
    if (candidates.isEmpty) return null;

    final random = Random();

    // 1. Cấp độ DỄ: Có 60% tỉ lệ chọn ngẫu nhiên
    if (difficulty == AIDifficulty.easy && random.nextDouble() < 0.60) {
      return candidates[random.nextInt(candidates.length)];
    }

    // 2. Kiểm tra nếu AI có thể THẮNG NGAY LẬP TỨC
    for (final move in candidates) {
      board[move.row][move.col] = aiPlayer;
      final win = GameEngine.checkWin(
        board: board,
        lastMove: move,
        winLength: winLength,
        blockedEndsRule: blockedEndsRule,
      );
      board[move.row][move.col] = null;
      if (win != null) return move;
    }

    // 3. Kiểm tra nếu ĐỐI THỦ có thể THẮNG NGAY LẬP TỨC -> BẮT BUỘC PHẢI CHẶN
    for (final move in candidates) {
      board[move.row][move.col] = opponent;
      final win = GameEngine.checkWin(
        board: board,
        lastMove: move,
        winLength: winLength,
        blockedEndsRule: blockedEndsRule,
      );
      board[move.row][move.col] = null;
      if (win != null) return move;
    }

    // 4. Nếu cấp độ Trung Bình và tỉ lệ ngẫu nhiên
    if (difficulty == AIDifficulty.medium && random.nextDouble() < 0.35) {
      return candidates[random.nextInt(candidates.length)];
    }

    // 5. Chấm điểm Heuristic toàn diện cho tất cả các nước ứng viên
    CellCoord? bestMove;
    var maxScore = -1;

    for (final move in candidates) {
      // Điểm tấn công của AI khi đặt vào ô này
      final attackScore = evaluateMoveScore(
        board: board,
        move: move,
        player: aiPlayer,
        winLength: winLength,
      );

      // Điểm phòng thủ (sức mạnh của đối thủ nếu đối thủ đánh vào ô này)
      final defenseScore = evaluateMoveScore(
        board: board,
        move: move,
        player: opponent,
        winLength: winLength,
      );

      // Trọng số tổng hợp: Phòng thủ được ưu tiên khi đối thủ có thế cờ nguy hiểm
      var totalScore = attackScore + (defenseScore * 1.2).toInt();

      // Thêm điểm ưu tiên các ô gần tâm bàn cờ
      final size = board.length;
      final mid = size / 2.0;
      final distFromCenter = sqrt(pow(move.row - mid, 2) + pow(move.col - mid, 2));
      totalScore += max(0, (size - distFromCenter).toInt() * 5);

      if (totalScore > maxScore) {
        maxScore = totalScore;
        bestMove = move;
      }
    }

    return bestMove ?? candidates[random.nextInt(candidates.length)];
  }

  /// Đánh giá điểm chiến lược khi [player] đánh vào [move]
  static int evaluateMoveScore({
    required List<List<PlayerType?>> board,
    required CellCoord move,
    required PlayerType player,
    required int winLength,
  }) {
    final size = board.length;
    final r = move.row;
    final c = move.col;

    final directions = [
      (0, 1),  // Ngang
      (1, 0),  // Dọc
      (1, 1),  // Chéo chính
      (1, -1), // Chéo phụ
    ];

    var totalScore = 0;

    for (final (dr, dc) in directions) {
      var count = 1; // Tính cả ô move
      var openEnds = 0;

      // Hướng xuôi
      var step = 1;
      while (true) {
        final nr = r + dr * step;
        final nc = c + dc * step;
        if (nr < 0 || nr >= size || nc < 0 || nc >= size) {
          break;
        }
        if (board[nr][nc] == player) {
          count++;
          step++;
        } else {
          if (board[nr][nc] == null) openEnds++;
          break;
        }
      }

      // Hướng ngược
      step = 1;
      while (true) {
        final nr = r - dr * step;
        final nc = c - dc * step;
        if (nr < 0 || nr >= size || nc < 0 || nc >= size) {
          break;
        }
        if (board[nr][nc] == player) {
          count++;
          step++;
        } else {
          if (board[nr][nc] == null) openEnds++;
          break;
        }
      }

      // Chấm điểm theo số quân liên tiếp và số đầu mở
      if (count >= winLength) {
        totalScore += scoreWin;
      } else if (count == winLength - 1) {
        if (openEnds == 2) {
          totalScore += scoreOpenFour;
        } else if (openEnds == 1) {
          totalScore += scoreClosedFour;
        }
      } else if (count == winLength - 2) {
        if (openEnds == 2) {
          totalScore += scoreOpenThree;
        } else if (openEnds == 1) {
          totalScore += scoreClosedThree;
        }
      } else if (count == winLength - 3) {
        if (openEnds == 2) {
          totalScore += scoreOpenTwo;
        } else if (openEnds == 1) {
          totalScore += scoreClosedTwo;
        }
      }
    }

    return totalScore;
  }
}
