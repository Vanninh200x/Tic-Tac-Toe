import 'package:flutter_board_game/models/game_config.dart';
import 'package:flutter_board_game/models/game_stats.dart';
import 'package:flutter_board_game/services/settings_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('loads default settings and clamps invalid persisted values', () async {
    SharedPreferences.setMockInitialValues({
      'settings.board_size': 1,
      'settings.win_length': 90,
      'settings.ai_difficulty': 'unknown',
    });

    final settings = await SettingsService.loadSettings();

    expect(settings.boardSize, 3);
    expect(settings.winLength, 3);
    expect(settings.difficulty, AiDifficulty.medium);
  });

  test('persists settings and validates board dimensions', () async {
    await SettingsService.saveSettings(
      boardSize: 15,
      winLength: 5,
      difficulty: AiDifficulty.hard,
    );

    final settings = await SettingsService.loadSettings();
    expect(settings.boardSize, 15);
    expect(settings.winLength, 5);
    expect(settings.difficulty, AiDifficulty.hard);

    await expectLater(
      SettingsService.saveSettings(
        boardSize: 2,
        winLength: 3,
        difficulty: AiDifficulty.easy,
      ),
      throwsArgumentError,
    );
    await expectLater(
      SettingsService.saveSettings(
        boardSize: 5,
        winLength: 6,
        difficulty: AiDifficulty.easy,
      ),
      throwsArgumentError,
    );
  });

  test(
    'records results separately by game mode and can clear the totals',
    () async {
      await SettingsService.recordFinishedGame(
        mode: GameMode.vsAI,
        winner: Player.x,
        isDraw: false,
      );
      await SettingsService.recordFinishedGame(
        mode: GameMode.vsAI,
        winner: Player.o,
        isDraw: false,
      );
      await SettingsService.recordFinishedGame(
        mode: GameMode.twoPlayers,
        winner: null,
        isDraw: true,
      );

      final stats = await SettingsService.loadStats();
      expect(stats.aiWins, 1);
      expect(stats.aiLosses, 1);
      expect(stats.twoPlayerDraws, 1);
      expect(stats.totalGames, 3);

      await SettingsService.clearStats();
      final clearedStats = await SettingsService.loadStats();
      expect(clearedStats, isA<GameStats>());
      expect(clearedStats.totalGames, 0);
    },
  );
}
