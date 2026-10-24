import 'package:flutter/material.dart';
import '../core/utils/sound_haptics.dart';
import '../models/game_enums.dart';
import '../models/game_stats.dart';
import '../services/storage_service.dart';

class SettingsController extends ChangeNotifier {
  final StorageService storageService;

  late AppThemeMode _themeMode;
  late bool _soundEnabled;
  late bool _hapticEnabled;
  late bool _showCoordinates;
  GameStats _stats = const GameStats();

  SettingsController({required this.storageService}) {
    _themeMode = storageService.loadTheme();
    _soundEnabled = storageService.loadSound();
    _hapticEnabled = storageService.loadHaptic();
    _showCoordinates = storageService.loadShowCoordinates();

    SoundHapticsHelper.soundEnabled = _soundEnabled;
    SoundHapticsHelper.hapticEnabled = _hapticEnabled;

    loadStats();
  }

  AppThemeMode get themeMode => _themeMode;
  bool get soundEnabled => _soundEnabled;
  bool get hapticEnabled => _hapticEnabled;
  bool get showCoordinates => _showCoordinates;
  GameStats get stats => _stats;

  Future<void> loadStats() async {
    _stats = await storageService.loadStats();
    notifyListeners();
  }

  Future<void> setTheme(AppThemeMode mode) async {
    _themeMode = mode;
    await storageService.saveTheme(mode);
    notifyListeners();
  }

  Future<void> toggleSound(bool value) async {
    _soundEnabled = value;
    SoundHapticsHelper.soundEnabled = value;
    await storageService.saveSound(value);
    if (value) {
      SoundHapticsHelper.playToggleSound();
    }
    notifyListeners();
  }

  Future<void> toggleHaptic(bool value) async {
    _hapticEnabled = value;
    SoundHapticsHelper.hapticEnabled = value;
    await storageService.saveHaptic(value);
    notifyListeners();
  }

  Future<void> toggleShowCoordinates(bool value) async {
    _showCoordinates = value;
    await storageService.saveShowCoordinates(value);
    notifyListeners();
  }

  Future<void> resetStats() async {
    await storageService.clearStats();
    _stats = const GameStats();
    notifyListeners();
  }
}
