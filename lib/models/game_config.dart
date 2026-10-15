enum GameMode { twoPlayers, vsAI, bluetooth }

enum Player { x, o }

enum AiDifficulty { easy, medium, hard }

extension PlayerDetails on Player {
  String get symbol => this == Player.x ? 'X' : 'O';
  String get displayName => this == Player.x ? 'Người chơi X' : 'Người chơi O';
  Player get opponent => this == Player.x ? Player.o : Player.x;
}

extension GameModeDetails on GameMode {
  String get title => switch (this) {
    GameMode.vsAI => 'Đấu với AI',
    GameMode.twoPlayers => 'Hai người chơi',
    GameMode.bluetooth => 'Bluetooth',
  };

  String get shortTitle => switch (this) {
    GameMode.vsAI => 'VS AI',
    GameMode.twoPlayers => '2 PLAYERS',
    GameMode.bluetooth => 'BLUETOOTH',
  };
}

extension AiDifficultyDetails on AiDifficulty {
  String get title {
    switch (this) {
      case AiDifficulty.easy:
        return 'Dễ';
      case AiDifficulty.medium:
        return 'Trung bình';
      case AiDifficulty.hard:
        return 'Khó';
    }
  }

  String get description {
    switch (this) {
      case AiDifficulty.easy:
        return 'Thư giãn, làm quen với trò chơi';
      case AiDifficulty.medium:
        return 'Biết tạo cơ hội và phòng thủ';
      case AiDifficulty.hard:
        return 'Tìm kiếm sâu hơn, phòng thủ chặt chẽ';
    }
  }
}

class GameConfig {
  final int boardSize;
  final int winLength;
  final GameMode mode;
  final AiDifficulty difficulty;

  const GameConfig({
    required this.boardSize,
    required this.winLength,
    required this.mode,
    this.difficulty = AiDifficulty.medium,
  });

  GameConfig copyWith({
    int? boardSize,
    int? winLength,
    GameMode? mode,
    AiDifficulty? difficulty,
  }) {
    return GameConfig(
      boardSize: boardSize ?? this.boardSize,
      winLength: winLength ?? this.winLength,
      mode: mode ?? this.mode,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}

int defaultWinLength(int boardSize) {
  if (boardSize <= 3) return 3;
  if (boardSize == 5) return 4;
  return boardSize < 5 ? boardSize : 5;
}
