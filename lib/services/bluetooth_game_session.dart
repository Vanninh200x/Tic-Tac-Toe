import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_classic_bluetooth/flutter_classic_bluetooth.dart';

import '../models/game_config.dart';
import '../models/game_state.dart';

class BluetoothGameSession {
  static const serviceName = 'Boardly Game';
  static const serviceUuid = 'c7416f52-8bb7-4b80-9ddc-5778187d9a41';

  final BtcConnection connection;
  final Player localPlayer;
  final List<Map<String, dynamic>> _queuedPackets = [];
  final List<Object> _queuedErrors = [];
  late final StreamController<Map<String, dynamic>> _packets =
      StreamController<Map<String, dynamic>>.broadcast(
        onListen: _flushQueuedPackets,
      );
  late final StreamController<Object> _errors =
      StreamController<Object>.broadcast(onListen: _flushQueuedErrors);
  final Completer<Map<String, dynamic>> _startPacket = Completer();
  late final StreamSubscription<String> _inputSubscription;
  late final StreamSubscription<BtcConnectionState> _stateSubscription;
  bool _disconnected = false;
  bool _disposed = false;
  bool _startWaitRequested = false;

  BluetoothGameSession({required this.connection, required this.localPlayer}) {
    _inputSubscription = connection.input
        .lines(maxLineLength: 4096)
        .listen(_handleLine, onError: _handleError, onDone: _handleDisconnect);
    _stateSubscription = connection.stateStream.listen((state) {
      if (state == BtcConnectionState.disconnected) _handleDisconnect();
    }, onError: _handleError);
  }

  Stream<Map<String, dynamic>> get packets => _packets.stream;
  Stream<Object> get errors => _errors.stream;
  bool get isConnected =>
      !_disposed && !_disconnected && connection.isConnected;

  Future<Map<String, dynamic>> waitForStart({
    Duration timeout = const Duration(seconds: 20),
  }) {
    _startWaitRequested = true;
    return _startPacket.future.timeout(timeout);
  }

  Future<void> sendStart(GameConfig config) => _send({
    'type': 'start',
    'boardSize': config.boardSize,
    'winLength': config.winLength,
  });

  Future<void> sendMove(Position position, int moveCount) => _send({
    'type': 'move',
    'row': position.row,
    'col': position.col,
    'moveCount': moveCount,
  });

  Future<void> sendReset() => _send({'type': 'reset'});

  Future<void> _send(Map<String, Object> packet) async {
    if (!isConnected) {
      throw StateError('Bluetooth connection is not active.');
    }
    await connection.output.writeLine(jsonEncode(packet));
  }

  void _handleLine(String line) {
    try {
      final decoded = jsonDecode(line);
      if (decoded is! Map) {
        throw const FormatException('Bluetooth packet must be a JSON object.');
      }
      final packet = Map<String, dynamic>.from(decoded);
      final type = packet['type'];
      if (type is! String || !const {'start', 'move', 'reset'}.contains(type)) {
        throw const FormatException('Unknown Bluetooth packet type.');
      }
      if (type == 'start' && !_startPacket.isCompleted) {
        _startPacket.complete(packet);
      }
      if (_packets.hasListener) {
        _packets.add(packet);
      } else {
        _queuedPackets.add(packet);
      }
    } catch (error, stackTrace) {
      _handleError(
        FormatException('Invalid Bluetooth game data: $error'),
        stackTrace,
      );
    }
  }

  void _handleError(Object error, [StackTrace? stackTrace]) {
    debugPrint('Bluetooth game transport error: $error');
    if (stackTrace != null) debugPrintStack(stackTrace: stackTrace);
    if (_errors.isClosed) return;
    if (_errors.hasListener) {
      _errors.add(error);
    } else {
      _queuedErrors.add(error);
    }
  }

  void _handleDisconnect() {
    if (_disconnected) return;
    _disconnected = true;
    if (_startWaitRequested && !_startPacket.isCompleted) {
      _startPacket.completeError(
        StateError('Bluetooth connection closed before the game started.'),
      );
    }
    _handleError(StateError('Bluetooth connection was lost.'));
  }

  void _flushQueuedPackets() {
    for (final packet in _queuedPackets) {
      _packets.add(packet);
    }
    _queuedPackets.clear();
  }

  void _flushQueuedErrors() {
    for (final error in _queuedErrors) {
      _errors.add(error);
    }
    _queuedErrors.clear();
  }

  Future<void> close() async {
    if (_disposed) return;
    _disposed = true;
    _disconnected = true;
    await _inputSubscription.cancel();
    await _stateSubscription.cancel();
    try {
      if (connection.isConnected) {
        try {
          await connection.finish();
        } catch (error, stackTrace) {
          debugPrint('Could not gracefully close Bluetooth connection: $error');
          debugPrintStack(stackTrace: stackTrace);
          await connection.close();
        }
      }
    } finally {
      connection.dispose();
      await _packets.close();
      await _errors.close();
    }
  }
}
