import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

Uint8List createWav(List<double> samples, {int sampleRate = 44100}) {
  final byteData = ByteData(44 + samples.length * 2);
  // "RIFF"
  byteData.setUint8(0, 0x52);
  byteData.setUint8(1, 0x49);
  byteData.setUint8(2, 0x46);
  byteData.setUint8(3, 0x46);
  // Total size - 8
  byteData.setUint32(4, 36 + samples.length * 2, Endian.little);
  // "WAVE"
  byteData.setUint8(8, 0x57);
  byteData.setUint8(9, 0x41);
  byteData.setUint8(10, 0x56);
  byteData.setUint8(11, 0x45);
  // "fmt "
  byteData.setUint8(12, 0x66);
  byteData.setUint8(13, 0x6D);
  byteData.setUint8(14, 0x74);
  byteData.setUint8(15, 0x20);
  // Subchunk1Size (16)
  byteData.setUint32(16, 16, Endian.little);
  // AudioFormat (1 = PCM)
  byteData.setUint16(20, 1, Endian.little);
  // Channels (1 = Mono)
  byteData.setUint16(22, 1, Endian.little);
  // SampleRate
  byteData.setUint32(24, sampleRate, Endian.little);
  // ByteRate
  byteData.setUint32(28, sampleRate * 2, Endian.little);
  // BlockAlign
  byteData.setUint16(32, 2, Endian.little);
  // BitsPerSample
  byteData.setUint16(34, 16, Endian.little);
  // "data"
  byteData.setUint8(36, 0x64);
  byteData.setUint8(37, 0x61);
  byteData.setUint8(38, 0x74);
  byteData.setUint8(39, 0x61);
  // Data size
  byteData.setUint32(40, samples.length * 2, Endian.little);

  int offset = 44;
  for (final s in samples) {
    final clamped = s.clamp(-1.0, 1.0);
    final intSample = (clamped * 32767).toInt();
    byteData.setInt16(offset, intSample, Endian.little);
    offset += 2;
  }
  return byteData.buffer.asUint8List();
}

List<double> generateMoveSound({int sampleRate = 44100}) {
  // 90ms punchy wooden stone tap with low resonant thump
  final numSamples = (sampleRate * 0.09).toInt();
  final samples = <double>[];
  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final progress = i / numSamples;
    // frequency slides down from 540 to 180 Hz
    final freq = 540.0 * (1.0 - progress * 0.65);
    final env = exp(-progress * 9.0);
    final s1 = sin(2 * pi * freq * t);
    final s2 = 0.35 * sin(2 * pi * (freq * 2.1) * t);
    samples.add((s1 + s2) * env * 0.85);
  }
  return samples;
}

List<double> generateClickSound({int sampleRate = 44100}) {
  // 40ms light tactile tick
  final numSamples = (sampleRate * 0.04).toInt();
  final samples = <double>[];
  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final progress = i / numSamples;
    final freq = 900.0 * (1.0 - progress * 0.5);
    final env = exp(-progress * 14.0);
    samples.add(sin(2 * pi * freq * t) * env * 0.7);
  }
  return samples;
}

List<double> generateToggleSound({int sampleRate = 44100}) {
  // 220ms bright two-note ascending chime (E5 -> B5)
  final numSamples = (sampleRate * 0.22).toInt();
  final half = numSamples ~/ 2;
  final samples = <double>[];
  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    if (i < half) {
      final prog = i / half;
      final env = exp(-prog * 4.5);
      final s = sin(2 * pi * 659.25 * t) + 0.25 * sin(2 * pi * 1318.5 * t);
      samples.add(s * env * 0.65);
    } else {
      final prog = (i - half) / (numSamples - half);
      final env = exp(-prog * 3.5);
      final s = sin(2 * pi * 987.77 * t) + 0.3 * sin(2 * pi * 1975.5 * t);
      samples.add(s * env * 0.75);
    }
  }
  return samples;
}

List<double> generateWinSound({int sampleRate = 44100}) {
  // 520ms triumphant 4-note arpeggio (C5 -> E5 -> G5 -> C6 chime)
  final numSamples = (sampleRate * 0.52).toInt();
  final part = numSamples ~/ 4;
  final freqs = [523.25, 659.25, 783.99, 1046.50];
  final samples = <double>[];
  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final noteIndex = min(i ~/ part, 3);
    final freq = freqs[noteIndex];
    final noteProgress = (i % part) / part;
    final env = noteIndex == 3
        ? exp(-((i - 3 * part) / part) * 2.0)
        : exp(-noteProgress * 4.0);
    final s = sin(2 * pi * freq * t) + 0.25 * sin(2 * pi * (freq * 2) * t);
    samples.add(s * env * 0.75);
  }
  return samples;
}

List<double> generateDrawSound({int sampleRate = 44100}) {
  // 300ms gentle descending two-tone
  final numSamples = (sampleRate * 0.30).toInt();
  final half = numSamples ~/ 2;
  final samples = <double>[];
  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    if (i < half) {
      final prog = i / half;
      final env = exp(-prog * 3.5);
      samples.add(sin(2 * pi * 440.0 * t) * env * 0.6);
    } else {
      final prog = (i - half) / (numSamples - half);
      final env = exp(-prog * 2.5);
      samples.add(sin(2 * pi * 329.63 * t) * env * 0.6);
    }
  }
  return samples;
}

void main() {
  final outDir = Directory('assets/sounds');
  if (!outDir.existsSync()) {
    outDir.createSync(recursive: true);
  }

  File('assets/sounds/move.wav').writeAsBytesSync(createWav(generateMoveSound()));
  File('assets/sounds/click.wav').writeAsBytesSync(createWav(generateClickSound()));
  File('assets/sounds/toggle.wav').writeAsBytesSync(createWav(generateToggleSound()));
  File('assets/sounds/win.wav').writeAsBytesSync(createWav(generateWinSound()));
  File('assets/sounds/draw.wav').writeAsBytesSync(createWav(generateDrawSound()));

  print('Generated 5 wav sound files successfully in assets/sounds/');
}
