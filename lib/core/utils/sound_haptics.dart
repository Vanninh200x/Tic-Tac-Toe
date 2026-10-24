import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class SoundHapticsHelper {
  static bool hapticEnabled = true;
  static bool soundEnabled = true;

  static AudioPlayer? _sfxPlayer;
  static AudioPlayer? _chimePlayer;

  static AudioPlayer _getSfxPlayer() {
    return _sfxPlayer ??= AudioPlayer();
  }

  static AudioPlayer _getChimePlayer() {
    return _chimePlayer ??= AudioPlayer();
  }

  static void _playSfx(String path) {
    if (!soundEnabled) return;
    try {
      final player = _getSfxPlayer();
      player.stop().then((_) {
        player.play(AssetSource(path));
      }).catchError((_) {});
    } catch (_) {}
  }

  static void _playChime(String path) {
    if (!soundEnabled) return;
    try {
      final player = _getChimePlayer();
      player.stop().then((_) {
        player.play(AssetSource(path));
      }).catchError((_) {});
    } catch (_) {}
  }

  /// Phát âm thanh và phản hồi rung khi đặt quân cờ
  static void playMoveFeedback() {
    if (soundEnabled) {
      _playSfx('sounds/move.wav');
      try {
        SystemSound.play(SystemSoundType.click);
      } catch (_) {}
    }
    if (hapticEnabled) {
      try {
        HapticFeedback.lightImpact();
      } catch (_) {}
    }
  }

  /// Phát âm thanh khải hoàn khi chiến thắng
  static void playWinFeedback() {
    if (soundEnabled) {
      _playChime('sounds/win.wav');
    }
    if (hapticEnabled) {
      try {
        HapticFeedback.heavyImpact();
      } catch (_) {}
    }
  }

  /// Phản hồi khi hòa cờ
  static void playDrawFeedback() {
    if (soundEnabled) {
      _playChime('sounds/draw.wav');
    }
    if (hapticEnabled) {
      try {
        HapticFeedback.mediumImpact();
      } catch (_) {}
    }
  }

  /// Phản hồi khi bấm nút UI, chip hoặc lựa chọn
  static void playButtonFeedback() {
    if (soundEnabled) {
      _playSfx('sounds/click.wav');
      try {
        SystemSound.play(SystemSoundType.click);
      } catch (_) {}
    }
    if (hapticEnabled) {
      try {
        HapticFeedback.selectionClick();
      } catch (_) {}
    }
  }

  /// Phát âm thanh chuông khi bật cài đặt âm thanh
  static void playToggleSound() {
    if (soundEnabled) {
      _playChime('sounds/toggle.wav');
      try {
        SystemSound.play(SystemSoundType.click);
      } catch (_) {}
    }
    if (hapticEnabled) {
      try {
        HapticFeedback.mediumImpact();
      } catch (_) {}
    }
  }
}
