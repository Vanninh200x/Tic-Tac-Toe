import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_enums.dart';
import '../models/game_stats.dart';

class StorageService {
  static const String _keyStats = 'ttt_game_stats_v1';
  static const String _keyTheme = 'ttt_app_theme';
  static const String _keySound = 'ttt_sound_enabled';
  static const String _keyHaptic = 'ttt_haptic_enabled';
  static const String _keyCoordinates = 'ttt_show_coordinates';

  SharedPreferences? _prefs;
  final Map<String, dynamic> _fallbackMemory = {};

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (_) {
      _prefs = null;
    }
  }

  // --- STATS ---
  Future<GameStats> loadStats() async {
    try {
      final raw = _prefs?.getString(_keyStats) ?? _fallbackMemory[_keyStats] as String?;
      if (raw != null && raw.isNotEmpty) {
        return GameStats.fromJson(raw);
      }
    } catch (_) {}
    return const GameStats();
  }

  Future<void> saveStats(GameStats stats) async {
    final raw = stats.toJson();
    _fallbackMemory[_keyStats] = raw;
    try {
      await _prefs?.setString(_keyStats, raw);
    } catch (_) {}
  }

  Future<void> recordGameResult({
    required GameMode mode,
    required int boardSize,
    required int winLength,
    required PlayerType? winner,
    required int totalMoves,
    required int durationSeconds,
  }) async {
    final currentStats = await loadStats();
    final newHistory = List<GameHistoryEntry>.from(currentStats.history);

    newHistory.insert(
      0,
      GameHistoryEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        mode: mode,
        boardSize: boardSize,
        winLength: winLength,
        winner: winner,
        totalMoves: totalMoves,
        durationSeconds: durationSeconds,
        playedAt: DateTime.now(),
      ),
    );

    // Giữ tối đa 50 ván gần nhất
    if (newHistory.length > 50) {
      newHistory.removeRange(50, newHistory.length);
    }

    final isVsAi = mode == GameMode.vsAI;
    final updated = currentStats.copyWith(
      totalGames: currentStats.totalGames + 1,
      xWins: winner == PlayerType.x ? currentStats.xWins + 1 : currentStats.xWins,
      oWins: winner == PlayerType.o ? currentStats.oWins + 1 : currentStats.oWins,
      draws: winner == null ? currentStats.draws + 1 : currentStats.draws,
      vsAiWins: (isVsAi && winner == PlayerType.x)
          ? currentStats.vsAiWins + 1
          : currentStats.vsAiWins,
      vsAiLosses: (isVsAi && winner == PlayerType.o)
          ? currentStats.vsAiLosses + 1
          : currentStats.vsAiLosses,
      history: newHistory,
    );

    await saveStats(updated);
  }

  Future<void> clearStats() async {
    _fallbackMemory.remove(_keyStats);
    try {
      await _prefs?.remove(_keyStats);
    } catch (_) {}
  }

  // --- THEME ---
  AppThemeMode loadTheme() {
    try {
      final name = _prefs?.getString(_keyTheme) ?? _fallbackMemory[_keyTheme] as String?;
      if (name != null) {
        return AppThemeMode.values.byName(name);
      }
    } catch (_) {}
    return AppThemeMode.modernLight;
  }

  Future<void> saveTheme(AppThemeMode mode) async {
    _fallbackMemory[_keyTheme] = mode.name;
    try {
      await _prefs?.setString(_keyTheme, mode.name);
    } catch (_) {}
  }

  // --- SOUND & HAPTIC ---
  bool loadSound() {
    return _prefs?.getBool(_keySound) ?? _fallbackMemory[_keySound] as bool? ?? true;
  }

  Future<void> saveSound(bool val) async {
    _fallbackMemory[_keySound] = val;
    try {
      await _prefs?.setBool(_keySound, val);
    } catch (_) {}
  }

  bool loadHaptic() {
    return _prefs?.getBool(_keyHaptic) ?? _fallbackMemory[_keyHaptic] as bool? ?? true;
  }

  Future<void> saveHaptic(bool val) async {
    _fallbackMemory[_keyHaptic] = val;
    try {
      await _prefs?.setBool(_keyHaptic, val);
    } catch (_) {}
  }

  bool loadShowCoordinates() {
    return _prefs?.getBool(_keyCoordinates) ??
        _fallbackMemory[_keyCoordinates] as bool? ??
        true;
  }

  Future<void> saveShowCoordinates(bool val) async {
    _fallbackMemory[_keyCoordinates] = val;
    try {
      await _prefs?.setBool(_keyCoordinates, val);
    } catch (_) {}
  }
}
