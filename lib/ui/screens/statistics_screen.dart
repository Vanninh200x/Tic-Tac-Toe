import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../models/game_enums.dart';
import '../../models/game_stats.dart';
import '../../providers/settings_controller.dart';
import '../widgets/glass_card.dart';
import '../widgets/neon_badge.dart';

class StatisticsScreen extends StatelessWidget {
  final SettingsController settingsController;

  const StatisticsScreen({
    super.key,
    required this.settingsController,
  });

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m}p ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settingsController,
      builder: (context, _) {
        final stats = settingsController.stats;
        final themeCfg = AppTheme.getConfig(settingsController.themeMode);
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
              'Thống Kê Ván Đấu',
              style: AppStyles.headingMedium(color: themeCfg.primaryTextColor).copyWith(fontSize: 22),
            ),
            centerTitle: true,
            actions: [
              if (stats.totalGames > 0)
                IconButton(
                  tooltip: 'Xóa thống kê',
                  icon: Icon(Icons.delete_sweep_rounded, color: themeCfg.secondaryTextColor),
                  onPressed: () => _showResetDialog(context, themeCfg),
                ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Tỉ lệ thắng & Tổng quan
                  GlassCard(
                    padding: const EdgeInsets.all(AppDimens.paddingLarge),
                    child: Column(
                      children: [
                        Text(
                          'TỔNG SỐ TRẬN ĐÃ CHƠI',
                          style: AppStyles.bodyMedium(color: themeCfg.secondaryTextColor).copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${stats.totalGames}',
                          style: AppStyles.headingLarge(color: AppColors.cyanNeon).copyWith(
                            fontSize: 54,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _miniStat('Quân X Thắng', '${stats.xWins}', AppColors.cyanNeon, themeCfg),
                            _divider(isDark),
                            _miniStat('Quân O Thắng', '${stats.oWins}', AppColors.coralNeon, themeCfg),
                            _divider(isDark),
                            _miniStat('Hòa Cờ', '${stats.draws}', AppColors.gold, themeCfg),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 2. Thống kê với AI
                  GlassCard(
                    padding: const EdgeInsets.all(AppDimens.paddingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.smart_toy_rounded, color: AppColors.cyanNeon, size: 24),
                            const SizedBox(width: 10),
                            Text(
                              'ĐẤU VỚI MÁY (AI)',
                              style: AppStyles.headingSmall(color: themeCfg.primaryTextColor).copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _progressCard(
                                title: 'Thắng AI',
                                count: stats.vsAiWins,
                                color: AppColors.success,
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _progressCard(
                                title: 'Thua AI',
                                count: stats.vsAiLosses,
                                color: AppColors.danger,
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 3. Lịch sử các ván đấu gần đây
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'LỊCH SỬ GẦN ĐÂY',
                        style: AppStyles.headingSmall(color: themeCfg.primaryTextColor).copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${stats.history.length} ván gần nhất',
                        style: AppStyles.bodyMedium(color: themeCfg.secondaryTextColor).copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  if (stats.history.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.history_toggle_off_rounded,
                              size: 64,
                              color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Chưa có dữ liệu ván đấu nào',
                              style: AppStyles.bodyLarge(color: themeCfg.secondaryTextColor),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: stats.history.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = stats.history[index];
                        return _historyItemCard(item, themeCfg);
                      },
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _miniStat(String label, String value, Color color, ThemeConfig themeCfg) {
    return Column(
      children: [
        Text(
          value,
          style: AppStyles.headingLarge(color: color).copyWith(fontSize: 26),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppStyles.bodyMedium(color: themeCfg.secondaryTextColor).copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _divider(bool isDark) {
    return Container(
      width: 1.2,
      height: 44,
      color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
    );
  }

  Widget _progressCard({
    required String title,
    required int count,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppStyles.bodyMedium(color: color).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$count',
            style: AppStyles.headingLarge(color: color).copyWith(fontSize: 28),
          ),
        ],
      ),
    );
  }

  Widget _historyItemCard(GameHistoryEntry item, ThemeConfig themeCfg) {
    final isDraw = item.winner == null;
    final isX = item.winner == PlayerType.x;
    final resultColor = isDraw
        ? AppColors.gold
        : (isX ? AppColors.cyanNeon : AppColors.coralNeon);
    final resultText = isDraw ? 'Hòa' : (isX ? 'X Thắng' : 'O Thắng');

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          // Result Icon Badge
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: resultColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: resultColor.withValues(alpha: 0.4), width: 1.5),
            ),
            child: Center(
              child: isDraw
                  ? Icon(Icons.handshake_rounded, color: resultColor, size: 26)
                  : Text(
                      item.winner!.symbol,
                      style: TextStyle(
                        color: resultColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      resultText,
                      style: AppStyles.headingSmall(color: themeCfg.primaryTextColor).copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      _formatDate(item.playedAt),
                      style: AppStyles.bodySmall(color: themeCfg.secondaryTextColor).copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    NeonBadge(
                      text: '${item.boardSize}x${item.boardSize}',
                      color: const Color(0xFF8B5CF6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${item.totalMoves} nước • ${_formatDuration(item.durationSeconds)}',
                      style: AppStyles.bodyMedium(color: themeCfg.secondaryTextColor).copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, ThemeConfig themeCfg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: themeCfg.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          'Xóa toàn bộ thống kê?',
          style: AppStyles.headingSmall(color: themeCfg.primaryTextColor),
        ),
        content: Text(
          'Dữ liệu số trận thắng, thua và lịch sử ván cờ sẽ được đặt lại về 0.',
          style: AppStyles.bodyMedium(color: themeCfg.secondaryTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Hủy',
              style: TextStyle(color: themeCfg.secondaryTextColor, fontWeight: FontWeight.w700),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
            onPressed: () {
              settingsController.resetStats();
              Navigator.pop(ctx);
            },
            child: const Text('Xác nhận xóa', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
