enum PlayerType {
  x,
  o;

  PlayerType get opponent => this == PlayerType.x ? PlayerType.o : PlayerType.x;
  String get symbol => this == PlayerType.x ? 'X' : 'O';
  String get nameVi => this == PlayerType.x ? 'Quân X' : 'Quân O';
}

enum GameMode {
  vsAI,
  passAndPlay,
  bluetooth;

  String get titleVi {
    switch (this) {
      case GameMode.vsAI:
        return 'Chơi với Máy (AI)';
      case GameMode.passAndPlay:
        return 'Hai người (1 Thiết bị)';
      case GameMode.bluetooth:
        return 'Bluetooth (Đấu mạng)';
    }
  }

  String get descriptionVi {
    switch (this) {
      case GameMode.vsAI:
        return 'Thử thách trí tuệ nhân tạo từ Dễ đến Kiện tướng';
      case GameMode.passAndPlay:
        return 'Cùng so tài với bạn bè trên cùng một màn hình';
      case GameMode.bluetooth:
        return 'Kết nối thiết bị gần không dây (Bản Demo)';
    }
  }
}

enum AIDifficulty {
  easy,
  medium,
  hard,
  master;

  String get titleVi {
    switch (this) {
      case AIDifficulty.easy:
        return 'Dễ (Tập sự)';
      case AIDifficulty.medium:
        return 'Trung bình';
      case AIDifficulty.hard:
        return 'Khó';
      case AIDifficulty.master:
        return 'Kiện tướng (Minimax)';
    }
  }

  String get descriptionVi {
    switch (this) {
      case AIDifficulty.easy:
        return 'Nước đi ngẫu nhiên, phù hợp người mới làm quen';
      case AIDifficulty.medium:
        return 'Biết chặn nước thắng và tạo thế cờ cơ bản';
      case AIDifficulty.hard:
        return 'Chiến thuật phòng thủ và tấn công chiều sâu';
      case AIDifficulty.master:
        return 'Không thể đánh bại trên bàn 3x3, cực mạnh bàn lớn';
    }
  }
}

enum BoardPreset {
  size3x3(3, 3, '3 × 3 (Tic Tac Toe)'),
  size5x5(5, 4, '5 × 5 (Caro mini)'),
  size10x10(10, 5, '10 × 10 (Caro chuẩn vừa)'),
  size15x15(15, 5, '15 × 15 (Caro quốc tế Gomoku)'),
  size20x20(20, 5, '20 × 20 (Caro bàn rộng)'),
  custom(0, 0, 'Tùy chỉnh kích thước');

  final int size;
  final int defaultWinLength;
  final String label;

  const BoardPreset(this.size, this.defaultWinLength, this.label);
}

enum GameStatus {
  playing,
  won,
  draw,
  paused,
}

enum WinDirection {
  horizontal,
  vertical,
  diagonalMain,
  diagonalAnti,
}

enum AppThemeMode {
  cyberpunkNeon,
  classicWood,
  midnightObsidian,
  modernLight;

  String get titleVi {
    switch (this) {
      case AppThemeMode.cyberpunkNeon:
        return 'Cyberpunk Neon';
      case AppThemeMode.classicWood:
        return 'Bàn Gỗ Cổ Điển';
      case AppThemeMode.midnightObsidian:
        return 'Đá Đen Huyền Bí';
      case AppThemeMode.modernLight:
        return 'Tối Giản Thanh Lịch';
    }
  }
}
