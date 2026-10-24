import '../models/game_enums.dart';
import '../models/game_models.dart';

class GameEngine {
  /// Tạo bàn cờ rỗng kích thước [size] x [size]
  static List<List<PlayerType?>> createEmptyBoard(int size) {
    return List.generate(
      size,
      (_) => List<PlayerType?>.filled(size, null),
    );
  }

  /// Sao chép bàn cờ (deep copy)
  static List<List<PlayerType?>> cloneBoard(List<List<PlayerType?>> board) {
    return board.map((row) => List<PlayerType?>.from(row)).toList();
  }

  /// Kiểm tra nước đi hợp lệ
  static bool isValidMove(List<List<PlayerType?>> board, CellCoord coord) {
    final size = board.length;
    if (coord.row < 0 || coord.row >= size || coord.col < 0 || coord.col >= size) {
      return false;
    }
    return board[coord.row][coord.col] == null;
  }

  /// Kiểm tra bàn cờ đã đầy chưa (hòa cờ)
  static bool isBoardFull(List<List<PlayerType?>> board) {
    for (final row in board) {
      for (final cell in row) {
        if (cell == null) return false;
      }
    }
    return true;
  }

  /// Đếm tổng số nước đi đã đánh
  static int countMoves(List<List<PlayerType?>> board) {
    var count = 0;
    for (final row in board) {
      for (final cell in row) {
        if (cell != null) count++;
      }
    }
    return count;
  }

  /// Lấy danh sách tất cả ô còn trống
  static List<CellCoord> getAvailableMoves(List<List<PlayerType?>> board) {
    final moves = <CellCoord>[];
    final size = board.length;
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        if (board[r][c] == null) {
          moves.add(CellCoord(r, c));
        }
      }
    }
    return moves;
  }

  /// Kiểm tra chiến thắng dựa trên nước đi cuối cùng [lastMove]
  /// Hỗ trợ 4 hướng: Ngang, Dọc, Chéo chính, Chéo phụ
  static WinResult? checkWin({
    required List<List<PlayerType?>> board,
    required CellCoord lastMove,
    required int winLength,
    bool blockedEndsRule = false,
  }) {
    final size = board.length;
    final r = lastMove.row;
    final c = lastMove.col;

    if (r < 0 || r >= size || c < 0 || c >= size) return null;
    final player = board[r][c];
    if (player == null) return null;

    final directions = [
      (0, 1, WinDirection.horizontal),
      (1, 0, WinDirection.vertical),
      (1, 1, WinDirection.diagonalMain),
      (1, -1, WinDirection.diagonalAnti),
    ];

    for (final (dr, dc, dir) in directions) {
      final cells = <CellCoord>[lastMove];

      // Tìm về phía trước
      var step = 1;
      while (true) {
        final nr = r + dr * step;
        final nc = c + dc * step;
        if (nr < 0 || nr >= size || nc < 0 || nc >= size) break;
        if (board[nr][nc] == player) {
          cells.add(CellCoord(nr, nc));
          step++;
        } else {
          break;
        }
      }

      // Tìm về phía sau
      step = 1;
      while (true) {
        final nr = r - dr * step;
        final nc = c - dc * step;
        if (nr < 0 || nr >= size || nc < 0 || nc >= size) break;
        if (board[nr][nc] == player) {
          cells.insert(0, CellCoord(nr, nc));
          step++;
        } else {
          break;
        }
      }

      if (cells.length >= winLength &&
          (!_isBlockedAtBothEnds(
            board: board,
            cells: cells,
            dr: dr,
            dc: dc,
            player: player,
          ) ||
              !blockedEndsRule)) {
        return WinResult(
          winner: player,
          winningCells: cells,
          direction: dir,
        );
      }
    }

    return null;
  }

  static bool _isBlockedAtBothEnds({
    required List<List<PlayerType?>> board,
    required List<CellCoord> cells,
    required int dr,
    required int dc,
    required PlayerType player,
  }) {
    final size = board.length;
    final first = cells.first;
    final last = cells.last;
    final beforeRow = first.row - dr;
    final beforeCol = first.col - dc;
    final afterRow = last.row + dr;
    final afterCol = last.col + dc;

    bool isBlocked(int row, int col) =>
        row < 0 || row >= size || col < 0 || col >= size || board[row][col] == player.opponent;

    return isBlocked(beforeRow, beforeCol) && isBlocked(afterRow, afterCol);
  }

  /// Lấy danh sách ô ứng viên (vùng lân cận các ô đã đánh) cho AI bàn lớn
  static List<CellCoord> getCandidateMoves(
    List<List<PlayerType?>> board, {
    int radius = 1,
  }) {
    final size = board.length;
    final candidates = <CellCoord>{};
    var hasPieces = false;

    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        if (board[r][c] != null) {
          hasPieces = true;
          for (var dr = -radius; dr <= radius; dr++) {
            for (var dc = -radius; dc <= radius; dc++) {
              if (dr == 0 && dc == 0) continue;
              final nr = r + dr;
              final nc = c + dc;
              if (nr >= 0 && nr < size && nc >= 0 && nc < size) {
                if (board[nr][nc] == null) {
                  candidates.add(CellCoord(nr, nc));
                }
              }
            }
          }
        }
      }
    }

    if (!hasPieces) {
      // Bàn cờ rỗng -> đánh ngay giữa bàn cờ
      final mid = size ~/ 2;
      return [CellCoord(mid, mid)];
    }

    return candidates.toList();
  }
}
