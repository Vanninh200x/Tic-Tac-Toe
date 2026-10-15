import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_config.dart';
import '../models/game_stats.dart';

class SettingsSnapshot {
  final int boardSize;
  final int winLength;
  final AiDifficulty difficulty;

  const SettingsSnapshot({
    required this.boardSize,
    required this.winLength,
    required this.difficulty,
  });
}

class SettingsService {
  const SettingsService._();

  static const _boardSizeKey = 'settings.board_size';
  static const _winLengthKey = 'settings.win_length';
  static const _difficultyKey = 'settings.ai_difficulty';

  static const _aiWins = 'stats.ai_wins';
  static const _aiLosses = 'stats.ai_losses';
  static const _aiDraws = 'stats.ai_draws';
  static const _xWins = 'stats.two_player_x_wins';
  static const _oWins = 'stats.two_player_o_wins';
  static const _twoPlayerDraws = 'stats.two_player_draws';

  static Future<SettingsSnapshot> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final size = (prefs.getInt(_boardSizeKey) ?? 5).clamp(3, 30).toInt();
    final storedWinLength =
        prefs.getInt(_winLengthKey) ?? defaultWinLength(size);
    final safeWinLength = storedWinLength.clamp(3, size).toInt();
    final difficultyName =
        prefs.getString(_difficultyKey) ?? AiDifficulty.medium.name;
    final difficulty = AiDifficulty.values.firstWhere(
      (item) => item.name == difficultyName,
      orElse: () => AiDifficulty.medium,
    );
    return SettingsSnapshot(
      boardSize: size,
      winLength: safeWinLength,
      difficulty: difficulty,
    );
  }

  static Future<void> saveSettings({
    required int boardSize,
    required int winLength,
    required AiDifficulty difficulty,
  }) async {
    if (boardSize < 3 || boardSize > 30) {
      throw ArgumentError.value(
        boardSize,
        'boardSize',
        'Must be from 3 to 30.',
      );
    }
    if (winLength < 3 || winLength > boardSize) {
      throw ArgumentError.value(
        winLength,
        'winLength',
        'Must be from 3 to boardSize.',
      );
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_boardSizeKey, boardSize);
    await prefs.setInt(_winLengthKey, winLength);
    await prefs.setString(_difficultyKey, difficulty.name);
  }

  static Future<GameStats> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    return GameStats(
      aiWins: prefs.getInt(_aiWins) ?? 0,
      aiLosses: prefs.getInt(_aiLosses) ?? 0,
      aiDraws: prefs.getInt(_aiDraws) ?? 0,
      playerXWins: prefs.getInt(_xWins) ?? 0,
      playerOWins: prefs.getInt(_oWins) ?? 0,
      twoPlayerDraws: prefs.getInt(_twoPlayerDraws) ?? 0,
    );
  }

  static Future<void> recordFinishedGame({
    required GameMode mode,
    required Player? winner,
    required bool isDraw,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (mode == GameMode.vsAI) {
      if (isDraw) {
        await prefs.setInt(_aiDraws, (prefs.getInt(_aiDraws) ?? 0) + 1);
      } else if (winner == Player.x) {
        await prefs.setInt(_aiWins, (prefs.getInt(_aiWins) ?? 0) + 1);
      } else {
        await prefs.setInt(_aiLosses, (prefs.getInt(_aiLosses) ?? 0) + 1);
      }
    } else {
      if (isDraw) {
        await prefs.setInt(
          _twoPlayerDraws,
          (prefs.getInt(_twoPlayerDraws) ?? 0) + 1,
        );
      } else if (winner == Player.x) {
        await prefs.setInt(_xWins, (prefs.getInt(_xWins) ?? 0) + 1);
      } else {
        await prefs.setInt(_oWins, (prefs.getInt(_oWins) ?? 0) + 1);
      }
    }
  }

  static Future<void> clearStats() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in <String>[
      _aiWins,
      _aiLosses,
      _aiDraws,
      _xWins,
      _oWins,
      _twoPlayerDraws,
    ]) {
      await prefs.remove(key);
    }
  }
}
