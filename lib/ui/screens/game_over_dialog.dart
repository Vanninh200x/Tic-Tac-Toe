import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_styles.dart';
import '../../models/game_enums.dart';
import '../../models/game_models.dart';
import '../widgets/glass_card.dart';
import '../widgets/glossy_button.dart';

class GameOverDialog extends StatelessWidget {
  final WinResult? winResult;
  final GameConfig config;
  final int totalMoves;
  final int durationSeconds;
  final VoidCallback onPlayAgain;
  final VoidCallback onReviewBoard;
  final VoidCallback onHome;

  const GameOverDialog({
    super.key,
    required this.winResult,
    required this.config,
    required this.totalMoves,
    required this.durationSeconds,
    required this.onPlayAgain,
    required this.onReviewBoard,
    required this.onHome,
  });

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDraw = winResult == null;
    final winner = winResult?.winner;

    final isVsAi = config.mode == GameMode.vsAI;
    final isHumanWinner = isVsAi && winner == config.humanPlayer;
    final isAiWinner = isVsAi && winner != null && winner != config.humanPlayer;

    String title;
    String subtitle;
    IconData icon;
    Color highlightColor;
    List<Color> gradient;

    if (isDraw) {
      title = 'HÒA CỜ KỊCH TÍNH!';
      subtitle = 'Cả hai bên đều thi đấu ngang tài ngang sức';
      icon = Icons.handshake_rounded;
      highlightColor = AppColors.gold;
      gradient = AppColors.goldGradient;
    } else if (isAiWinner) {
      title = 'AI ĐÃ CHIẾN THẮNG!';
      subtitle = 'Đừng nản lòng, hãy phục thù ở ván tiếp theo!';
      icon = Icons.smart_toy_rounded;
      highlightColor = AppColors.coralNeon;
      gradient = AppColors.oGradient;
    } else if (isHumanWinner) {
      title = 'BẠN ĐÃ CHIẾN THẮNG!';
      subtitle = 'Nước đi xuất sắc và chiến lược đỉnh cao!';
      icon = Icons.emoji_events_rounded;
      highlightColor = AppColors.gold;
      gradient = AppColors.goldGradient;
    } else {
      title = '${winner!.nameVi.toUpperCase()} CHIẾN THẮNG!';
      subtitle = 'Ván đấu mãn nhãn và căng thẳng đến phút cuối';
      icon = Icons.military_tech_rounded;
      highlightColor = winner == PlayerType.x ? AppColors.cyanNeon : AppColors.coralNeon;
      gradient = winner == PlayerType.x ? AppColors.xGradient : AppColors.oGradient;
    }

    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22),
      child: GlassCard(
        borderRadius: AppDimens.radiusExtraLarge,
        backgroundColor: isDark
            ? const Color(0xFF162038).withValues(alpha: 0.98)
            : Colors.white.withValues(alpha: 0.98),
        borderColor: highlightColor.withValues(alpha: 0.4),
        shadows: [
          BoxShadow(
            color: highlightColor.withValues(alpha: isDark ? 0.35 : 0.2),
            blurRadius: 32,
            spreadRadius: 3,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        padding: const EdgeInsets.all(AppDimens.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glowing Trophy / Icon Badge
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: highlightColor.withValues(alpha: 0.5),
                    blurRadius: 22,
                    spreadRadius: 3,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppStyles.headingMedium(color: textColor).copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppStyles.bodyMedium(
                color: isDark ? Colors.white70 : const Color(0xFF475569),
              ).copyWith(fontSize: 15),
            ),
            const SizedBox(height: 24),

            // Match Stats Card
            Container(
              padding: const EdgeInsets.all(AppDimens.paddingMedium),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
                border: Border.all(
                  color: isDark ? Colors.white12 : const Color(0xFFCBD5E1),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statItem('Bàn cờ', '${config.boardSize}x${config.boardSize}', textColor, isDark),
                  _divider(isDark),
                  _statItem('Nước đi', '$totalMoves', textColor, isDark),
                  _divider(isDark),
                  _statItem('Thời gian', _formatDuration(durationSeconds), textColor, isDark),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Action Buttons
            GlossyButton(
              text: 'CHƠI VÁN TIẾP THEO',
              icon: Icons.replay_rounded,
              gradient: gradient,
              glowColor: highlightColor,
              height: 58,
              onPressed: onPlayAgain,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textColor,
                      side: BorderSide(
                        color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.remove_red_eye_outlined, size: 20),
                    label: Text(
                      'Xem Lại',
                      style: AppStyles.bodyMedium(color: textColor).copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: onReviewBoard,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textColor,
                      side: BorderSide(
                        color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.home_outlined, size: 20),
                    label: Text(
                      'Menu',
                      style: AppStyles.bodyMedium(color: textColor).copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: onHome,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, Color textColor, bool isDark) {
    return Column(
      children: [
        Text(
          label,
          style: AppStyles.bodySmall(
            color: isDark ? Colors.white60 : const Color(0xFF64748B),
          ).copyWith(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: AppStyles.headingSmall(color: textColor).copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _divider(bool isDark) {
    return Container(
      width: 1.2,
      height: 38,
      color: isDark ? Colors.white12 : const Color(0xFFCBD5E1),
    );
  }
}
