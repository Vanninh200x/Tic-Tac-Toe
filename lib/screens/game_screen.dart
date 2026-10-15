import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../engine/ai_engine.dart';
import '../engine/game_engine.dart';
import '../models/game_config.dart';
import '../models/game_state.dart';
import '../services/bluetooth_game_session.dart';
import '../services/settings_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/game_board.dart';

class GameScreen extends StatefulWidget {
  final GameConfig config;
  final BluetoothGameSession? bluetoothSession;

  const GameScreen({super.key, required this.config, this.bluetoothSession});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameState _state;
  bool _thinking = false;
  bool _recordedResult = false;
  bool _resultDialogShowing = false;
  bool _leaving = false;
  bool _connectionLost = false;
  StreamSubscription<Map<String, dynamic>>? _packetSubscription;
  StreamSubscription<Object>? _errorSubscription;

  @override
  void initState() {
    super.initState();
    _state = GameState.initial(widget.config.boardSize);
    final session = widget.bluetoothSession;
    if (session != null) {
      _connectionLost = !session.isConnected;
      _packetSubscription = session.packets.listen(_handleBluetoothPacket);
      _errorSubscription = session.errors.listen(_handleBluetoothError);
    }
  }

  void _onBoardMove(Position position) {
    if (_thinking ||
        _state.isFinished ||
        _leaving ||
        _connectionLost ||
        !_isLocalTurn) {
      return;
    }
    if (widget.config.mode == GameMode.vsAI &&
        _state.currentPlayer == Player.o) {
      return;
    }
    _applyMove(position.row, position.col);
  }

  void _applyMove(int row, int col, {bool fromRemote = false}) {
    if (_state.isFinished || _thinking || !mounted) return;
    final next = GameEngine.playMove(
      state: _state,
      row: row,
      col: col,
      winLength: widget.config.winLength,
    );
    if (next == null) return;
    setState(() => _state = next);
    if (!fromRemote && widget.bluetoothSession != null) {
      unawaited(_sendBluetoothMove(Position(row, col), next.moveCount));
    }
    if (next.isFinished) {
      unawaited(_handleFinishedGame(next));
    } else if (widget.config.mode == GameMode.vsAI &&
        next.currentPlayer == Player.o) {
      unawaited(_playAiTurn());
    }
  }

  bool get _isLocalTurn {
    final localPlayer = widget.bluetoothSession?.localPlayer;
    return localPlayer == null || _state.currentPlayer == localPlayer;
  }

  String _playerTitle(Player player) {
    final localPlayer = widget.bluetoothSession?.localPlayer;
    if (localPlayer == null) {
      return player == Player.x ? 'Người chơi 1' : 'Người chơi 2';
    }
    return player == localPlayer ? 'Bạn' : 'Đối thủ';
  }

  Future<void> _sendBluetoothMove(Position position, int moveCount) async {
    try {
      await widget.bluetoothSession!.sendMove(position, moveCount);
    } catch (error, stackTrace) {
      debugPrint('Could not send Bluetooth move: $error\n$stackTrace');
      _handleBluetoothError(error);
    }
  }

  void _handleBluetoothPacket(Map<String, dynamic> packet) {
    if (!mounted || _connectionLost) return;
    switch (packet['type']) {
      case 'move':
        final row = packet['row'];
        final col = packet['col'];
        final moveCount = packet['moveCount'];
        if (row is! int ||
            col is! int ||
            moveCount is! int ||
            moveCount != _state.moveCount + 1 ||
            _state.currentPlayer == widget.bluetoothSession?.localPlayer) {
          _handleBluetoothError(
            const FormatException('Nước đi Bluetooth không đúng lượt.'),
          );
          return;
        }
        final next = GameEngine.playMove(
          state: _state,
          row: row,
          col: col,
          winLength: widget.config.winLength,
        );
        if (next == null || next.moveCount != moveCount) {
          _handleBluetoothError(
            const FormatException('Nước đi Bluetooth không hợp lệ.'),
          );
          return;
        }
        _applyMove(row, col, fromRemote: true);
        break;
      case 'reset':
        if (_resultDialogShowing) {
          Navigator.of(context, rootNavigator: true).pop();
        }
        setState(() {
          _state = GameState.initial(widget.config.boardSize);
          _thinking = false;
          _recordedResult = false;
          _resultDialogShowing = false;
        });
        break;
      case 'start':
        break;
    }
  }

  void _handleBluetoothError(Object error) {
    if (!mounted || _connectionLost) return;
    debugPrint('Bluetooth game communication error: $error');
    setState(() => _connectionLost = true);
    final session = widget.bluetoothSession;
    if (session != null) unawaited(session.close());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kết nối Bluetooth đã ngắt. Ván đấu không thể tiếp tục.'),
      ),
    );
  }

  Future<void> _playAiTurn() async {
    if (_thinking || _state.isFinished || !mounted) return;
    setState(() => _thinking = true);
    Position? move;
    Object? aiError;
    try {
      move = await AiEngine.chooseMove(
        state: _state,
        winLength: widget.config.winLength,
        difficulty: widget.config.difficulty,
      );
    } catch (error, stackTrace) {
      aiError = error;
      debugPrint('AI failed to choose a move: $error\n$stackTrace');
    }
    if (!mounted || _state.isFinished) return;
    if (move == null ||
        move.row < 0 ||
        move.row >= _state.boardSize ||
        move.col < 0 ||
        move.col >= _state.boardSize ||
        _state.board[move.row][move.col] != null) {
      move = _firstEmptyPosition(_state.board);
    }
    setState(() => _thinking = false);
    if (aiError != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'AI gặp sự cố; ván đấu sẽ tiếp tục với một nước hợp lệ.',
          ),
        ),
      );
    }
    if (move != null) {
      _applyMove(move.row, move.col);
    }
  }

  Position? _firstEmptyPosition(List<List<Player?>> board) {
    for (var row = 0; row < board.length; row++) {
      for (var col = 0; col < board.length; col++) {
        if (board[row][col] == null) return Position(row, col);
      }
    }
    return null;
  }

  Future<void> _handleFinishedGame(GameState finished) async {
    if (_recordedResult) return;
    _recordedResult = true;
    try {
      await SettingsService.recordFinishedGame(
        mode: widget.config.mode,
        winner: finished.winner,
        isDraw: finished.isDraw,
      );
    } catch (error, stackTrace) {
      debugPrint('Could not save game result: $error\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể lưu kết quả ván đấu vào thống kê.'),
          ),
        );
      }
    }
    if (!mounted || _resultDialogShowing) return;
    _resultDialogShowing = true;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final title = finished.isDraw
            ? 'Một trận đấu cân tài!'
            : widget.config.mode == GameMode.vsAI
            ? (finished.winner == Player.x
                  ? 'Bạn đã chiến thắng!'
                  : 'AI giành chiến thắng')
            : '${finished.winner?.symbol ?? ''} là người chiến thắng!';
        final subtitle = finished.isDraw
            ? 'Không còn ô trống và chưa có người thắng.'
            : '${finished.winner?.symbol ?? ''} đã nối đủ ${widget.config.winLength} quân liên tiếp.';
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
            side: const BorderSide(color: AppColors.border),
          ),
          icon: Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: (finished.isDraw ? AppColors.gold : AppColors.success)
                  .withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(
              finished.isDraw
                  ? Icons.handshake_rounded
                  : Icons.emoji_events_rounded,
              color: finished.isDraw ? AppColors.gold : AppColors.success,
              size: 34,
            ),
          ),
          title: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 21,
              color: AppColors.text,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted, height: 1.4),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Số nước đã đi',
                      style: TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                    Text(
                      '${finished.moveCount}',
                      style: const TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  if (widget.bluetoothSession != null) {
                    unawaited(_sendBluetoothReset());
                  }
                  setState(() {
                    _state = GameState.initial(widget.config.boardSize);
                    _thinking = false;
                    _recordedResult = false;
                    _resultDialogShowing = false;
                  });
                },
                icon: const Icon(Icons.replay_rounded),
                label: const Text('Chơi lại'),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.home_rounded),
                label: const Text('Về trang chủ'),
              ),
            ),
          ],
        );
      },
    );
    _resultDialogShowing = false;
  }

  Future<void> _sendBluetoothReset() async {
    try {
      await widget.bluetoothSession?.sendReset();
    } catch (error, stackTrace) {
      debugPrint('Could not send Bluetooth reset: $error\n$stackTrace');
      _handleBluetoothError(error);
    }
  }

  @override
  void dispose() {
    unawaited(_packetSubscription?.cancel());
    unawaited(_errorSubscription?.cancel());
    final session = widget.bluetoothSession;
    if (session != null) unawaited(session.close());
    super.dispose();
  }

  Future<void> _confirmExit() async {
    if (_leaving) return;
    if (_state.moveCount == 0 || _state.isFinished) {
      Navigator.of(context).pop();
      return;
    }
    final leave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF101633),
        title: const Text('Rời ván chơi?'),
        content: const Text(
          'Ván chưa kết thúc sẽ không được tính vào thống kê.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Tiếp tục chơi'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Rời ván'),
          ),
        ],
      ),
    );
    if (leave == true && mounted) {
      _leaving = true;
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.config.boardSize;
    final isVsAi = widget.config.mode == GameMode.vsAI;
    final status = _connectionLost
        ? 'Kết nối Bluetooth đã ngắt'
        : _state.isFinished
        ? (_state.isDraw
              ? 'Ván đấu hòa'
              : '${_state.winner?.symbol} chiến thắng')
        : _thinking
        ? 'AI đang suy nghĩ...'
        : widget.bluetoothSession != null
        ? (_isLocalTurn ? 'Lượt của bạn' : 'Đối thủ đang suy nghĩ...')
        : 'Lượt ${_state.currentPlayer.symbol}';
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: _confirmExit,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ván đấu',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
            ),
            Text(
              '${widget.config.mode.title} · $size × $size',
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  '${_state.moveCount} nước',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
              child: Row(
                children: [
                  Expanded(
                    child: _PlayerIndicator(
                      symbol: 'X',
                      title: _playerTitle(Player.x),
                      color: AppColors.accent,
                      active:
                          !_state.isFinished &&
                          _state.currentPlayer == Player.x,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: _PlayerIndicator(
                      symbol: 'O',
                      title: isVsAi
                          ? 'AI · ${widget.config.difficulty.title}'
                          : _playerTitle(Player.o),
                      color: AppColors.coral,
                      active:
                          !_state.isFinished &&
                          _state.currentPlayer == Player.o,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: _thinking
                      ? AppColors.accent.withValues(alpha: 0.09)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _thinking
                        ? AppColors.accent.withValues(alpha: 0.35)
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    if (_thinking)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Icon(
                        _state.isFinished ? Icons.flag_rounded : Icons.circle,
                        size: 13,
                        color: _state.isFinished
                            ? AppColors.gold
                            : (_state.currentPlayer == Player.x
                                  ? AppColors.accent
                                  : AppColors.coral),
                      ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        status,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      'Thắng: ${widget.config.winLength} quân',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final minimumCell = size <= 5
                      ? 48.0
                      : size <= 15
                      ? 30.0
                      : 25.0;
                  final side = math
                      .max(constraints.maxWidth, size * minimumCell)
                      .toDouble();
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF090D29),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.82),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.19),
                          blurRadius: 20,
                          spreadRadius: 1,
                        ),
                        BoxShadow(
                          color: AppColors.violet.withValues(alpha: 0.08),
                          blurRadius: 30,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(21),
                      child: InteractiveViewer(
                        constrained: false,
                        panEnabled: true,
                        scaleEnabled: true,
                        minScale: 0.55,
                        maxScale: 3.5,
                        boundaryMargin: EdgeInsets.all(side * 0.3),
                        alignment: Alignment.center,
                        child: GameBoard(
                          state: _state,
                          side: side,
                          inputEnabled:
                              !_thinking &&
                              !_leaving &&
                              !_connectionLost &&
                              !_state.isFinished &&
                              _isLocalTurn &&
                              !(_state.currentPlayer == Player.o && isVsAi),
                          onMove: _onBoardMove,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
              child: Column(
                children: [
                  if (size > 5)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.pan_tool_alt_rounded,
                            size: 14,
                            color: AppColors.muted,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Kéo để di chuyển · Chụm/mở hai ngón để zoom',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryActionButton(
                          label: 'Chơi lại',
                          icon: Icons.replay_rounded,
                          onPressed: _thinking ? () {} : _askRestart,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: PrimaryActionButton(
                          label: 'Ván mới',
                          icon: Icons.add_rounded,
                          onPressed: _thinking ? () {} : _askRestart,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _askRestart() async {
    if (_state.moveCount == 0) {
      if (widget.bluetoothSession != null) {
        unawaited(_sendBluetoothReset());
      }
      setState(() => _state = GameState.initial(widget.config.boardSize));
      return;
    }
    final restart = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Bắt đầu ván mới?'),
        content: const Text(
          'Trạng thái bàn hiện tại sẽ được xóa. Ván chưa kết thúc không được tính vào thống kê.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Ván mới'),
          ),
        ],
      ),
    );
    if (restart == true && mounted) {
      if (widget.bluetoothSession != null) {
        unawaited(_sendBluetoothReset());
      }
      setState(() {
        _state = GameState.initial(widget.config.boardSize);
        _thinking = false;
        _recordedResult = false;
        _resultDialogShowing = false;
      });
    }
  }
}

class _PlayerIndicator extends StatelessWidget {
  final String symbol;
  final String title;
  final Color color;
  final bool active;

  const _PlayerIndicator({
    required this.symbol,
    required this.title,
    required this.color,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: active
            ? color.withValues(alpha: 0.1)
            : AppColors.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active
              ? color.withValues(alpha: 0.8)
              : AppColors.border.withValues(alpha: 0.8),
          width: active ? 1.3 : 1,
        ),
        boxShadow: active
            ? [BoxShadow(color: color.withValues(alpha: 0.16), blurRadius: 14)]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Text(
              symbol,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  active ? 'Đang đi' : 'Chờ lượt',
                  style: TextStyle(
                    color: active ? color : AppColors.muted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          if (active) Icon(Icons.circle, size: 7, color: color),
        ],
      ),
    );
  }
}
