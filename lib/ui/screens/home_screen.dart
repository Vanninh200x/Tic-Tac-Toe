import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../models/game_enums.dart';
import '../../providers/settings_controller.dart';
import '../../core/utils/sound_haptics.dart';
import '../widgets/glass_card.dart';
import '../widgets/neon_badge.dart';
import '../widgets/xo_logo.dart';
import 'bluetooth_screen.dart';
import 'game_setup_screen.dart';
import 'rules_screen.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatelessWidget {
  final SettingsController settingsController;

  const HomeScreen({super.key, required this.settingsController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settingsController,
      builder: (context, _) {
        final themeCfg = AppTheme.getConfig(settingsController.themeMode);
        final stats = settingsController.stats;
        final isDark = themeCfg.isDark;

        return Scaffold(
          backgroundColor: themeCfg.backgroundColor,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [const Color(0xFF0F1A36), themeCfg.backgroundColor]
                    : [
                        const Color(0xFFE0E7FF),
                        themeCfg.backgroundColor,
                        const Color(0xFFF1F5F9),
                      ],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.paddingLarge,
                  vertical: AppDimens.paddingMedium,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),

                    // Top Header Brand & 3D Glowing Logo
                    _buildHeroLogo(isDark),
                    const SizedBox(height: 18),

                    Text(
                      'TIC-TAC-TOE & CARO',
                      textAlign: TextAlign.center,
                      style: AppStyles.headingLarge(
                        color: themeCfg.primaryTextColor,
                      ).copyWith(letterSpacing: 1.2, fontSize: 28),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Đa Kích Thước Bàn Cờ • AI Minimax & Heuristic',
                      textAlign: TextAlign.center,
                      style: AppStyles.bodyMedium(
                        color: themeCfg.secondaryTextColor,
                      ).copyWith(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    const SizedBox(height: 16),

                    // Quick Stats Pill
                    if (stats.totalGames > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark
                                ? Colors.white12
                                : const Color(0xFFCBD5E1),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.2 : 0.05,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          'Đã chơi: ${stats.totalGames} trận  •  Tỉ lệ thắng: ${stats.winRatePercent.toStringAsFixed(0)}%',
                          style: AppStyles.bodyMedium(
                            color: isDark
                                ? const Color(0xFF8FC4E8)
                                : const Color(0xFF47779F),
                          ).copyWith(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                      ),

                    const SizedBox(height: 28),

                    // 1. Chế độ Chơi với AI (Vs Computer)
                    _modeCard(
                      context: context,
                      title: 'CHƠI VỚI MÁY (AI)',
                      subtitle: 'Thử thách trí tuệ AI Minimax & Heuristic nhiều cấp độ',
                      icon: Icons.smart_toy_rounded,
                      gradient: AppColors.xGradient,
                      glowColor: AppColors.cyanNeon,
                      badgeText: 'Đề xuất',
                      isDark: isDark,
                      primaryTextColor: themeCfg.primaryTextColor,
                      secondaryTextColor: themeCfg.secondaryTextColor,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => GameSetupScreen(
                              initialMode: GameMode.vsAI,
                              settingsController: settingsController,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 18),

                    // 2. Chế độ Hai người (Pass & Play)
                    _modeCard(
                      context: context,
                      title: 'HAI NGƯỜI CHƠI (1 MÁY)',
                      subtitle: 'So tài chiến thuật với bạn bè trên cùng một màn hình',
                      icon: Icons.people_alt_rounded,
                      gradient: AppColors.oGradient,
                      glowColor: AppColors.coralNeon,
                      badgeText: 'Kinh điển',
                      isDark: isDark,
                      primaryTextColor: themeCfg.primaryTextColor,
                      secondaryTextColor: themeCfg.secondaryTextColor,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => GameSetupScreen(
                              initialMode: GameMode.passAndPlay,
                              settingsController: settingsController,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 18),

                    // 3. Chế độ Bluetooth / Đấu mạng Demo (theo README)
                    _modeCard(
                      context: context,
                      title: 'BLUETOOTH / ĐẤU MẠNG',
                      subtitle: 'Giao diện quét và ghép thiết bị demo tầm gần',
                      icon: Icons.bluetooth_searching_rounded,
                      gradient: const [Color(0xFF8B5CF6), Color(0xFFD946EF)],
                      glowColor: const Color(0xFFD946EF),
                      badgeText: '',
                      isDark: isDark,
                      primaryTextColor: themeCfg.primaryTextColor,
                      secondaryTextColor: themeCfg.secondaryTextColor,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BluetoothScreen(
                              settingsController: settingsController,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 28),

                    // Secondary Menu Grid
                    Row(
                      children: [
                        Expanded(
                          child: _menuItem(
                            context: context,
                            icon: Icons.bar_chart_rounded,
                            label: 'Thống Kê',
                            color: AppColors.gold,
                            textColor: themeCfg.primaryTextColor,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => StatisticsScreen(
                                    settingsController: settingsController,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _menuItem(
                            context: context,
                            icon: Icons.menu_book_rounded,
                            label: 'Luật Chơi',
                            color: AppColors.cyanNeon,
                            textColor: themeCfg.primaryTextColor,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => RulesScreen(
                                    settingsController: settingsController,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _menuItem(
                            context: context,
                            icon: Icons.settings_rounded,
                            label: 'Cài Đặt',
                            color: AppColors.coralNeon,
                            textColor: themeCfg.primaryTextColor,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => SettingsScreen(
                                    settingsController: settingsController,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroLogo(bool isDark) {
    return XOLogoWidget(isDark: isDark, size: 126);
  }

  Widget _modeCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required Color glowColor,
    required String badgeText,
    required bool isDark,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        SoundHapticsHelper.playButtonFeedback();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(AppDimens.paddingMedium),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
          color: isDark ? const Color(0xFF1E294B) : Colors.white,
          border: Border.all(
            color: glowColor.withValues(alpha: isDark ? 0.4 : 0.3),
            width: 1.8,
          ),
          boxShadow: [
            BoxShadow(
              color: glowColor.withValues(alpha: isDark ? 0.25 : 0.15),
              blurRadius: 20,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Mode Icon with Gradient Glow
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppStyles.headingSmall(
                            color: primaryTextColor,
                        ).copyWith(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 0.15),
                        ),
                      ),
                      if (badgeText.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: NeonBadge(text: badgeText, color: glowColor),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: AppStyles.bodyMedium(color: secondaryTextColor)
                        .copyWith(fontSize: 16, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: AppStyles.bodyMedium(color: textColor)
                .copyWith(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
