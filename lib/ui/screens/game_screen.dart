import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../models/game_enums.dart';
import '../../providers/game_controller.dart';
import '../../providers/settings_controller.dart';
import '../board/interactive_board.dart';
import '../widgets/game_timer_widget.dart';
import '../widgets/neon_badge.dart';
import '../widgets/player_card.dart';
import 'game_over_dialog.dart';

class GameScreen extends StatefulWidget {
  final GameController gameController;
  final SettingsController settingsController;

  const GameScreen({
    super.key,
    required this.gameController,
    required this.settingsController,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final TransformationController _transformController = TransformationController();
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    widget.gameController.addListener(_onGameStateChanged);
  }

  @override
  void dispose() {
    widget.gameController.removeListener(_onGameStateChanged);
    _transformController.dispose();
    super.dispose();
  }

  void _onGameStateChanged() {
    final status = widget.gameController.status;
    if ((status == GameStatus.won || status == GameStatus.draw) && !_dialogShown) {
      _dialogShown = true;
      // Trì hoãn một chút để người chơi chiêm ngưỡng đường gạch thắng
      Future.delayed(const Duration(milliseconds: 650), () {
        if (mounted) {
          _showGameOverDialog();
        }
      });
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => GameOverDialog(
        winResult: widget.gameController.winResult,
        config: widget.gameController.config,
        totalMoves: widget.gameController.moveHistory.length,
        durationSeconds: widget.gameController.matchDurationSeconds,
        onPlayAgain: () {
          Navigator.of(ctx).pop();
          _dialogShown = false;
          _resetZoom();
          widget.gameController.restartMatch();
        },
        onReviewBoard: () {
          Navigator.of(ctx).pop();
        },
        onHome: () {
          Navigator.of(ctx).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _resetZoom() {
    _transformController.value = Matrix4.identity();
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([widget.gameController, widget.settingsController]),
      builder: (context, _) {
        final config = widget.gameController.config;
        final isVsAi = config.mode == GameMode.vsAI;
        final themeCfg = AppTheme.getConfig(widget.settingsController.themeMode);
        final isDark = themeCfg.isDark;

        final p1Name = isVsAi
            ? (config.humanPlayer == PlayerType.x ? 'Bạn' : 'Máy AI')
            : 'Người chơi 1';
        final p2Name = isVsAi
            ? (config.humanPlayer == PlayerType.o ? 'Bạn' : 'Máy AI')
            : 'Người chơi 2';

        final isP1Ai = isVsAi && config.humanPlayer != PlayerType.x;
        final isP2Ai = isVsAi && config.humanPlayer != PlayerType.o;

        return Scaffold(
          backgroundColor: themeCfg.backgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: themeCfg.primaryTextColor,
                size: 22,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    NeonBadge(
                      text: '${config.boardSize}x${config.boardSize}',
                      color: AppColors.cyanNeon,
                    ),
                    const SizedBox(width: 8),
                    NeonBadge(
                      text: 'Thắng ${config.winLength} quân',
                      color: AppColors.coralNeon,
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  _formatDuration(widget.gameController.matchDurationSeconds),
                  style: AppStyles.bodyMedium(color: themeCfg.secondaryTextColor).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            centerTitle: true,
            actions: [
              IconButton(
                tooltip: 'Căn giữa bàn cờ',
                icon: Icon(Icons.center_focus_strong_rounded, color: themeCfg.primaryTextColor),
                onPressed: _resetZoom,
              ),
              IconButton(
                tooltip: 'Cài đặt nhanh',
                icon: Icon(Icons.tune_rounded, color: themeCfg.primaryTextColor),
                onPressed: () => _showQuickSettings(context, themeCfg),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 6),

                // Top Scoreboard
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMedium),
                  child: Row(
                    children: [
                      // Player 1 (X)
                      Expanded(
                        child: PlayerCard(
                          player: PlayerType.x,
                          name: p1Name,
                          score: widget.gameController.sessionP1Wins,
                          isCurrentTurn: widget.gameController.currentTurn == PlayerType.x &&
                              widget.gameController.status == GameStatus.playing,
                          isAi: isP1Ai,
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Center Timer or VS Badge
                      Column(
                        children: [
                          if (config.timeLimitSeconds > 0)
                            GameTimerWidget(
                              remainingSeconds: widget.gameController.remainingTurnSeconds,
                              totalSeconds: config.timeLimitSeconds,
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                'VS',
                                style: AppStyles.scoreNumber().copyWith(
                                  fontSize: 16,
                                  color: themeCfg.primaryTextColor,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            'Hòa: ${widget.gameController.sessionDraws}',
                            style: AppStyles.bodyMedium(color: themeCfg.secondaryTextColor).copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),

                      // Player 2 (O)
                      Expanded(
                        child: PlayerCard(
                          player: PlayerType.o,
                          name: p2Name,
                          score: widget.gameController.sessionP2Wins,
                          isCurrentTurn: widget.gameController.currentTurn == PlayerType.o &&
                              widget.gameController.status == GameStatus.playing,
                          isAi: isP2Ai,
                        ),
                      ),
                    ],
                  ),
                ),

                // AI Thinking indicator
                if (widget.gameController.isAiThinking)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.cyanNeon),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'AI đang tính toán nước đi...',
                          style: AppStyles.bodyMedium(color: AppColors.cyanNeon).copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Center Interactive Board
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimens.paddingSmall),
                    child: InteractiveBoard(
                      gameController: widget.gameController,
                      settingsController: widget.settingsController,
                      transformationController: _transformController,
                    ),
                  ),
                ),

                // Bottom Action Bar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.paddingMedium,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF162038) : Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.08),
                        blurRadius: 18,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _actionButton(
                        icon: Icons.undo_rounded,
                        label: 'Đi lại',
                        color: AppColors.gold,
                        isDark: isDark,
                        enabled: widget.gameController.moveHistory.isNotEmpty &&
                            widget.gameController.status == GameStatus.playing,
                        onTap: widget.gameController.undoMove,
                      ),
                      _actionButton(
                        icon: Icons.lightbulb_outline_rounded,
                        label: 'Gợi ý',
                        color: AppColors.cyanNeon,
                        isDark: isDark,
                        enabled: widget.gameController.status == GameStatus.playing &&
                            widget.gameController.isHumanTurn,
                        onTap: widget.gameController.requestHint,
                      ),
                      _actionButton(
                        icon: Icons.filter_center_focus_rounded,
                        label: 'Căn giữa',
                        color: const Color(0xFF8B5CF6),
                        isDark: isDark,
                        enabled: true,
                        onTap: _resetZoom,
                      ),
                      _actionButton(
                        icon: Icons.restart_alt_rounded,
                        label: 'Ván mới',
                        color: AppColors.coralNeon,
                        isDark: isDark,
                        enabled: true,
                        onTap: () {
                          _dialogShown = false;
                          _resetZoom();
                          widget.gameController.restartMatch();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool enabled,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: enabled
                  ? color.withValues(alpha: isDark ? 0.2 : 0.12)
                  : (isDark ? Colors.white10 : const Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: enabled
                    ? color.withValues(alpha: 0.4)
                    : (isDark ? Colors.white10 : const Color(0xFFCBD5E1)),
                width: 1.5,
              ),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: isDark ? 0.25 : 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
          ),
          child: Icon(
            icon,
            color: enabled ? color : (isDark ? Colors.white24 : const Color(0xFF94A3B8)),
            size: 26,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppStyles.bodyMedium().copyWith(
            color: enabled
                ? (isDark ? Colors.white : const Color(0xFF0F172A))
                : (isDark ? Colors.white38 : const Color(0xFF94A3B8)),
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
  }

  void _showQuickSettings(BuildContext context, ThemeConfig themeCfg) {
    showModalBottomSheet(
      context: context,
      backgroundColor: themeCfg.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(AppDimens.paddingLarge),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cài Đặt Nhanh',
                      style: AppStyles.headingMedium(color: themeCfg.primaryTextColor),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: themeCfg.primaryTextColor),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rung phản hồi (Haptic)',
                      style: AppStyles.bodyLarge(color: themeCfg.primaryTextColor),
                    ),
                    Switch(
                      value: widget.settingsController.hapticEnabled,
                      activeThumbColor: AppColors.cyanNeon,
                      onChanged: (val) {
                        widget.settingsController.toggleHaptic(val);
                        setModalState(() {});
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hiện tọa độ (A..Z, 1..N)',
                      style: AppStyles.bodyLarge(color: themeCfg.primaryTextColor),
                    ),
                    Switch(
                      value: widget.settingsController.showCoordinates,
                      activeThumbColor: AppColors.cyanNeon,
                      onChanged: (val) {
                        widget.settingsController.toggleShowCoordinates(val);
                        setModalState(() {});
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
