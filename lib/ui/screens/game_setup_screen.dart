import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../models/game_enums.dart';
import '../../models/game_models.dart';
import '../../providers/game_controller.dart';
import '../../providers/settings_controller.dart';
import '../widgets/glass_card.dart';
import '../widgets/glossy_button.dart';
import 'game_screen.dart';

class GameSetupScreen extends StatefulWidget {
  final GameMode initialMode;
  final SettingsController settingsController;

  const GameSetupScreen({
    super.key,
    required this.initialMode,
    required this.settingsController,
  });

  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  late GameMode _mode;
  int _boardSize = 3;
  int _winLength = 3;
  AIDifficulty _aiDifficulty = AIDifficulty.master;
  PlayerType _humanPlayer = PlayerType.x;
  PlayerType _firstPlayer = PlayerType.x;
  bool _blockedEndsRule = false;
  int _timeLimit = 0; // 0 = unlimited

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  void _startGame() {
    var startingPlayer = _firstPlayer;
    if (_firstPlayer == PlayerType.x && _mode == GameMode.vsAI) {
      startingPlayer = _humanPlayer;
    }

    final config = GameConfig(
      boardSize: _boardSize,
      winLength: _winLength,
      mode: _mode,
      aiDifficulty: _aiDifficulty,
      humanPlayer: _humanPlayer,
      firstPlayer: startingPlayer,
      blockedEndsRule: _blockedEndsRule,
      timeLimitSeconds: _timeLimit,
    );

    final gameController = GameController(
      storageService: widget.settingsController.storageService,
      initialConfig: config,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(
          gameController: gameController,
          settingsController: widget.settingsController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeCfg = AppTheme.getConfig(widget.settingsController.themeMode);
    final isVsAi = _mode == GameMode.vsAI;
    final isDark = themeCfg.isDark;

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
        title: Text(
          isVsAi ? 'Đấu Với Máy (AI)' : 'Chơi 2 Người (1 Máy)',
          style: AppStyles.headingMedium(color: themeCfg.primaryTextColor).copyWith(fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Chọn Kích thước bàn cờ
              _sectionHeader('KÍCH THƯỚC BÀN CỜ', Icons.grid_view_rounded, themeCfg),
              const SizedBox(height: 4),
              Text(
                'Chọn mọi kích thước từ 3×3 đến 20×20',
                style: AppStyles.bodySmall(color: themeCfg.secondaryTextColor)
                    .copyWith(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),

              // Slider tùy chỉnh kích thước bàn cờ
              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CỠ BÀN CỜ',
                                style: AppStyles.bodySmall(
                                  color: themeCfg.secondaryTextColor,
                                ).copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _boardSizeDescription(_boardSize),
                                style: AppStyles.bodyMedium(
                                  color: themeCfg.primaryTextColor,
                                ).copyWith(fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '$_boardSize × $_boardSize',
                          style: AppStyles.headingMedium(
                            color: const Color(0xFF111827),
                          ).copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 8,
                        activeTrackColor: const Color(0xFF638FB6),
                        inactiveTrackColor: isDark
                            ? Colors.white.withValues(alpha: 0.14)
                            : const Color(0xFFDCE5F0),
                        activeTickMarkColor: Colors.white.withValues(alpha: 0.8),
                        inactiveTickMarkColor: isDark
                            ? Colors.white.withValues(alpha: 0.42)
                            : const Color(0xFF94A3B8),
                        thumbColor: Colors.white,
                        overlayColor: const Color(0xFF638FB6).withValues(alpha: 0.12),
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 13,
                          elevation: 4,
                        ),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 23),
                        tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 2.2),
                      ),
                      child: Slider(
                        value: _boardSize.toDouble(),
                        min: 3,
                        max: 20,
                        divisions: 17,
                        semanticFormatterCallback: (value) =>
                            '${value.round()} × ${value.round()}',
                        onChanged: (val) {
                          setState(() {
                            _boardSize = val.round();
                            if (_boardSize == 3) {
                              _winLength = 3;
                            } else if (_boardSize < 6) {
                              _winLength = min(_winLength, 4);
                            } else {
                              _winLength = 5;
                            }
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _sliderEndLabel('3 × 3', isDark),
                          _sliderEndLabel('20 × 20', isDark),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2. Điều kiện thắng (Số quân liên tiếp)
              _sectionHeader('ĐIỀU KIỆN CHIẾN THẮNG', Icons.emoji_events_rounded, themeCfg),
              const SizedBox(height: 12),
              Row(
                children: [
                  _winLengthButton(3, enabled: _boardSize >= 3, isDark: isDark),
                  const SizedBox(width: 10),
                  _winLengthButton(4, enabled: _boardSize >= 4, isDark: isDark),
                  const SizedBox(width: 10),
                  _winLengthButton(5, enabled: _boardSize >= 5, isDark: isDark),
                ],
              ),
              const SizedBox(height: 24),

              // 3. Nếu đấu với AI: Cài đặt độ khó & phe
              if (isVsAi) ...[
                _sectionHeader('CẤP ĐỘ TRÍ TUỆ NHÂN TẠO (AI)', Icons.psychology_rounded, themeCfg),
                const SizedBox(height: 12),
                Column(
                  children: AIDifficulty.values.map((diff) {
                    final isSelected = _aiDifficulty == diff;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: GlassCard(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        borderColor: isSelected
                            ? AppColors.cyanNeon
                            : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                        onTap: () => setState(() => _aiDifficulty = diff),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: isSelected
                                  ? AppColors.cyanNeon
                                  : (isDark ? Colors.white38 : const Color(0xFF94A3B8)),
                              size: 24,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    diff.titleVi,
                                    style: AppStyles.headingSmall(
                                      color: isSelected
                                          ? AppColors.cyanNeon
                                          : themeCfg.primaryTextColor,
                                    ).copyWith(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    diff.descriptionVi,
                                    style: AppStyles.bodyMedium(color: themeCfg.secondaryTextColor)
                                        .copyWith(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Chọn phe (Quân X hay Quân O)
                _sectionHeader('CHỌN QUÂN CỦA BẠN', Icons.person_rounded, themeCfg),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _sideSelectionCard(
                        player: PlayerType.x,
                        title: 'Quân X (Đi trước)',
                        isSelected: _humanPlayer == PlayerType.x,
                        isDark: isDark,
                        textColor: themeCfg.primaryTextColor,
                        onTap: () => setState(() {
                          _humanPlayer = PlayerType.x;
                          _firstPlayer = PlayerType.x;
                        }),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _sideSelectionCard(
                        player: PlayerType.o,
                        title: 'Quân O (Đi sau)',
                        isSelected: _humanPlayer == PlayerType.o,
                        isDark: isDark,
                        textColor: themeCfg.primaryTextColor,
                        onTap: () => setState(() {
                          _humanPlayer = PlayerType.o;
                          _firstPlayer = PlayerType.x; // Máy đi trước
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // 4. Giới hạn thời gian mỗi lượt
              _sectionHeader('THỜI GIAN MỖI LƯỢT', Icons.timer_rounded, themeCfg),
              const SizedBox(height: 12),
              Row(
                children: [
                  _timerOption(0, 'Vô hạn', isDark),
                  const SizedBox(width: 10),
                  _timerOption(15, '15 giây', isDark),
                  const SizedBox(width: 10),
                  _timerOption(30, '30 giây', isDark),
                  const SizedBox(width: 10),
                  _timerOption(60, '60 giây', isDark),
                ],
              ),
              const SizedBox(height: 24),

              // 5. Luật chặn 2 đầu (Caro VN)
              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Luật chặn 2 đầu (Caro Việt Nam)',
                            style: AppStyles.headingSmall(color: themeCfg.primaryTextColor).copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Nếu đủ 5 quân nhưng bị chặn cả 2 đầu bởi quân đối phương sẽ không tính thắng',
                            style: AppStyles.bodyMedium(color: themeCfg.secondaryTextColor).copyWith(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Switch(
                      value: _blockedEndsRule,
                      activeThumbColor: AppColors.cyanNeon,
                      onChanged: (val) => setState(() => _blockedEndsRule = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Nút Bắt đầu trận đấu
              GlossyButton(
                text: 'BẮT ĐẦU VÁN ĐẤU',
                icon: Icons.play_arrow_rounded,
                gradient: AppColors.xGradient,
                glowColor: AppColors.cyanNeon,
                height: 62,
                onPressed: _startGame,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon, ThemeConfig themeCfg) {
    return Row(
      children: [
        Icon(icon, size: 23, color: const Color(0xFF5685AE)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.headingSmall(color: themeCfg.primaryTextColor).copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.35,
            ),
          ),
        ),
      ],
    );
  }

  String _boardSizeDescription(int size) => switch (size) {
    3 => 'Tic-Tac-Toe cổ điển',
    4 => 'Caro 4 × 4',
    5 => 'Caro mini',
    <= 10 => 'Caro tiêu chuẩn',
    <= 15 => 'Gomoku',
    _ => 'Bàn cờ rộng',
  };

  Widget _sliderEndLabel(String label, bool isDark) {
    return Text(
      label,
      style: AppStyles.bodySmall(
        color: isDark ? Colors.white60 : const Color(0xFF64748B),
      ).copyWith(fontSize: 13, fontWeight: FontWeight.w700),
    );
  }

  Widget _winLengthButton(int length, {required bool enabled, required bool isDark}) {
    final isSelected = _winLength == length;
    return Expanded(
      child: GestureDetector(
        onTap: enabled ? () => setState(() => _winLength = length) : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.coralNeon.withValues(alpha: isDark ? 0.25 : 0.12)
                : (isDark ? const Color(0xFF1E294B) : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.coralNeon
                  : (enabled
                      ? (isDark ? Colors.white12 : const Color(0xFFE2E8F0))
                      : Colors.transparent),
              width: isSelected ? 2.0 : 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.coralNeon.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Column(
            children: [
              Text(
                '$length',
                style: AppStyles.headingLarge(
                  color: enabled
                      ? (isSelected ? AppColors.coralNeon : (isDark ? Colors.white : const Color(0xFF0F172A)))
                      : Colors.grey.shade400,
                ).copyWith(fontSize: 32, height: 1.0, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                'QUÂN',
                style: AppStyles.bodyMedium(
                  color: enabled
                      ? (isDark ? Colors.white70 : const Color(0xFF64748B))
                      : Colors.grey.shade400,
                ).copyWith(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sideSelectionCard({
    required PlayerType player,
    required String title,
    required bool isSelected,
    required bool isDark,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    final isX = player == PlayerType.x;
    final color = isX ? AppColors.cyanNeon : AppColors.coralNeon;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: isDark ? 0.2 : 0.1)
              : (isDark ? const Color(0xFF1E294B) : Colors.white),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? color : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
            width: isSelected ? 2.5 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          children: [
            Text(
              isX ? 'X' : 'O',
              style: TextStyle(
                color: color,
                fontSize: 38,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppStyles.bodyMedium(color: textColor).copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timerOption(int seconds, String label, bool isDark) {
    final isSelected = _timeLimit == seconds;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _timeLimit = seconds),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.amberNeon.withValues(alpha: isDark ? 0.25 : 0.15)
                : (isDark ? const Color(0xFF1E294B) : Colors.white),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? AppColors.amberNeon
                  : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
              width: isSelected ? 2.0 : 1.2,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppStyles.bodyMedium().copyWith(
                color: isSelected
                    ? AppColors.gold
                    : (isDark ? Colors.white70 : const Color(0xFF475569)),
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
