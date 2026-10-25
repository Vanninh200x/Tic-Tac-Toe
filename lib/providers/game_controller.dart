import 'dart:async';
import 'package:flutter/material.dart';
import '../core/utils/sound_haptics.dart';
import '../engine/ai_engine.dart';
import '../engine/game_engine.dart';
import '../models/game_enums.dart';
import '../models/game_models.dart';
import '../services/storage_service.dart';

class GameController extends ChangeNotifier {
  final StorageService storageService;

  GameConfig _config;
  late List<List<PlayerType?>> _board;
  PlayerType _currentTurn = PlayerType.x;
  GameStatus _status = GameStatus.playing;
  WinResult? _winResult;

  final List<MoveRecord> _moveHistory = [];
  CellCoord? _lastMove;
  CellCoord? _hintMove;
  bool _isAiThinking = false;

  int _sessionP1Wins = 0;
  int _sessionP2Wins = 0;
  int _sessionDraws = 0;

  Timer? _turnTimer;
  int _remainingTurnSeconds = 0;

  Timer? _matchTimer;
  int _matchDurationSeconds = 0;
  int _aiRequestId = 0;
  int _hintRequestId = 0;

  GameController({
    required this.storageService,
    GameConfig? initialConfig,
  }) : _config = initialConfig ?? const GameConfig() {
    _startNewMatch();
  }

  // Getters
  GameConfig get config => _config;
  List<List<PlayerType?>> get board => _board;
  PlayerType get currentTurn => _currentTurn;
  GameStatus get status => _status;
  WinResult? get winResult => _winResult;
  List<MoveRecord> get moveHistory => List.unmodifiable(_moveHistory);
  CellCoord? get lastMove => _lastMove;
  CellCoord? get hintMove => _hintMove;
  bool get isAiThinking => _isAiThinking;
  int get sessionP1Wins => _sessionP1Wins;
  int get sessionP2Wins => _sessionP2Wins;
  int get sessionDraws => _sessionDraws;
  int get remainingTurnSeconds => _remainingTurnSeconds;
  int get matchDurationSeconds => _matchDurationSeconds;

  bool get isHumanTurn {
    if (_status != GameStatus.playing || _isAiThinking) return false;
    if (_config.mode == GameMode.vsAI) {
      return _currentTurn == _config.humanPlayer;
    }
    return true;
  }

  void updateConfig(GameConfig newConfig) {
    _config = newConfig;
    _startNewMatch();
    notifyListeners();
  }

  void restartMatch() {
    _startNewMatch();
    notifyListeners();
  }

  void _startNewMatch() {
    _aiRequestId++;
    _hintRequestId++;
    _turnTimer?.cancel();
    _matchTimer?.cancel();

    _board = GameEngine.createEmptyBoard(_config.boardSize);
    _currentTurn = _config.firstPlayer;
    _status = GameStatus.playing;
    _winResult = null;
    _lastMove = null;
    _hintMove = null;
    _moveHistory.clear();
    _isAiThinking = false;
    _matchDurationSeconds = 0;

    _startMatchTimer();
    _resetTurnTimer();

    // Nếu ván mới máy đi trước
    if (_config.mode == GameMode.vsAI && _currentTurn != _config.humanPlayer) {
      _triggerAiMove();
    }
  }

  void _startMatchTimer() {
    _matchTimer?.cancel();
    _matchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_status == GameStatus.playing) {
        _matchDurationSeconds++;
        notifyListeners();
      }
    });
  }

  void _resetTurnTimer() {
    _turnTimer?.cancel();
    if (_config.timeLimitSeconds > 0) {
      _remainingTurnSeconds = _config.timeLimitSeconds;
      _turnTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_status != GameStatus.playing) {
          timer.cancel();
          return;
        }
        if (_remainingTurnSeconds > 0) {
          _remainingTurnSeconds--;
          notifyListeners();
        } else {
          // Hết giờ lượt đi -> Tự động chuyển lượt hoặc chọn ngẫu nhiên
          _handleTurnTimeout();
        }
      });
    }
  }

  void _handleTurnTimeout() {
    if (_status != GameStatus.playing) return;
    final available = GameEngine.getAvailableMoves(_board);
    if (available.isNotEmpty) {
      // Đánh 1 ô ngẫu nhiên khi hết giờ
      makeMove(available.first);
    }
  }

  /// Thực hiện nước đi của người chơi hoặc AI
  Future<bool> makeMove(CellCoord coord) async {
    if (_status != GameStatus.playing) return false;
    if (!GameEngine.isValidMove(_board, coord)) return false;

    _hintRequestId++;

    // Đặt quân cờ
    _board[coord.row][coord.col] = _currentTurn;
    _lastMove = coord;
    _hintMove = null;

    final record = MoveRecord(
      coord: coord,
      player: _currentTurn,
      timestamp: DateTime.now(),
      moveNumber: _moveHistory.length + 1,
    );
    _moveHistory.add(record);

    SoundHapticsHelper.playMoveFeedback();

    // Kiểm tra chiến thắng
    final win = GameEngine.checkWin(
      board: _board,
      lastMove: coord,
      winLength: _config.winLength,
      blockedEndsRule: _config.blockedEndsRule,
    );

    if (win != null) {
      _status = GameStatus.won;
      _winResult = win;
      _turnTimer?.cancel();
      _matchTimer?.cancel();

      if (win.winner == PlayerType.x) {
        _sessionP1Wins++;
      } else {
        _sessionP2Wins++;
      }

      SoundHapticsHelper.playWinFeedback();
      await _saveHistoryRecord(win.winner);
      notifyListeners();
      return true;
    }

    // Kiểm tra hòa cờ
    if (GameEngine.isBoardFull(_board)) {
      _status = GameStatus.draw;
      _turnTimer?.cancel();
      _matchTimer?.cancel();
      _sessionDraws++;

      SoundHapticsHelper.playDrawFeedback();
      await _saveHistoryRecord(null);
      notifyListeners();
      return true;
    }

    // Chuyển lượt
    _currentTurn = _currentTurn.opponent;
    _resetTurnTimer();
    notifyListeners();

    // Kích hoạt AI nếu đến lượt máy
    if (_config.mode == GameMode.vsAI && _currentTurn != _config.humanPlayer) {
      _triggerAiMove();
    }

    return true;
  }

  /// Xử lý AI tính toán và đánh cờ
  Future<void> _triggerAiMove() async {
    if (_status != GameStatus.playing) return;
    final boardAtStart = GameEngine.cloneBoard(_board);
    final turnAtStart = _currentTurn;
    final requestId = ++_aiRequestId;
    _isAiThinking = true;
    notifyListeners();

    final aiMove = await AIEngine.getBestMove(
      board: boardAtStart,
      aiPlayer: _currentTurn,
      difficulty: _config.aiDifficulty,
      winLength: _config.winLength,
      blockedEndsRule: _config.blockedEndsRule,
    );

    // Ignore a result computed for a previous match or turn.
    if (requestId != _aiRequestId) return;
    if (_status != GameStatus.playing || turnAtStart != _currentTurn) {
      _isAiThinking = false;
      notifyListeners();
      return;
    }
    // Board changes while the request is in flight mean the result is stale.
    for (var row = 0; row < _board.length; row++) {
      for (var col = 0; col < _board[row].length; col++) {
        if (boardAtStart[row][col] != _board[row][col]) {
          _isAiThinking = false;
          notifyListeners();
          return;
        }
      }
    }

    _isAiThinking = false;

    if (aiMove != null && _status == GameStatus.playing) {
      await makeMove(aiMove);
    }
  }

  /// Gợi ý nước đi tốt nhất cho người chơi
  Future<void> requestHint() async {
    if (_status != GameStatus.playing || _isAiThinking) return;
    final requestId = ++_hintRequestId;
    final boardAtRequest = GameEngine.cloneBoard(_board);
    final turnAtRequest = _currentTurn;

    final hint = await AIEngine.getBestMove(
      board: boardAtRequest,
      aiPlayer: _currentTurn,
      difficulty: AIDifficulty.master,
      winLength: _config.winLength,
      blockedEndsRule: _config.blockedEndsRule,
    );

    if (requestId == _hintRequestId &&
        _status == GameStatus.playing &&
        _currentTurn == turnAtRequest &&
        hint != null) {
      _hintMove = hint;
      SoundHapticsHelper.playButtonFeedback();
      notifyListeners();

      // Tự động tắt gợi ý sau 4 giây
      Future.delayed(const Duration(seconds: 4), () {
        if (_hintRequestId == requestId && _hintMove == hint) {
          _hintMove = null;
          notifyListeners();
        }
      });
    }
  }

  /// Đi lại (Undo nước đi)
  void undoMove() {
    if (_moveHistory.isEmpty || _status == GameStatus.won) return;

    // Invalidate any AI/hint result calculated for the board before undo.
    _aiRequestId++;
    _hintRequestId++;
    _isAiThinking = false;

    if (_config.mode == GameMode.vsAI) {
      // Khi đấu với máy: Rút lại 2 nước (nước của máy + nước của người)
      if (_moveHistory.length >= 2) {
        final m1 = _moveHistory.removeLast();
        final m2 = _moveHistory.removeLast();
        _board[m1.coord.row][m1.coord.col] = null;
        _board[m2.coord.row][m2.coord.col] = null;
      } else {
        final m = _moveHistory.removeLast();
        _board[m.coord.row][m.coord.col] = null;
      }
      _currentTurn = _config.humanPlayer;
    } else {
      // Đấu 2 người: Rút lại 1 nước
      final m = _moveHistory.removeLast();
      _board[m.coord.row][m.coord.col] = null;
      _currentTurn = m.player;
    }

    _lastMove = _moveHistory.isNotEmpty ? _moveHistory.last.coord : null;
    _hintMove = null;
    _status = GameStatus.playing;
    _winResult = null;
    _resetTurnTimer();

    SoundHapticsHelper.playButtonFeedback();
    notifyListeners();
  }

  Future<void> _saveHistoryRecord(PlayerType? winner) {
    return storageService.recordGameResult(
      mode: _config.mode,
      boardSize: _config.boardSize,
      winLength: _config.winLength,
      winner: winner,
      totalMoves: _moveHistory.length,
      durationSeconds: _matchDurationSeconds,
    );
  }

  @override
  void dispose() {
    _aiRequestId++;
    _hintRequestId++;
    _turnTimer?.cancel();
    _matchTimer?.cancel();
    super.dispose();
  }
}
