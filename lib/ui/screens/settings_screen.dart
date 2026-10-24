import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../models/game_enums.dart';
import '../../providers/settings_controller.dart';
import '../widgets/glass_card.dart';

class SettingsScreen extends StatelessWidget {
  final SettingsController settingsController;

  const SettingsScreen({
    super.key,
    required this.settingsController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settingsController,
      builder: (context, _) {
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
              'Cài Đặt Ứng Dụng',
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
                  // 1. Chọn Giao diện / Chủ đề (Themes)
                  _sectionHeader('CHỦ ĐỀ GIAO DIỆN', Icons.palette_rounded, themeCfg),
                  const SizedBox(height: 14),
                  ...AppThemeMode.values.map((mode) {
                    final isSelected = settingsController.themeMode == mode;
                    final previewCfg = AppTheme.getConfig(mode);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: GlassCard(
                        padding: const EdgeInsets.all(16),
                        borderColor: isSelected
                            ? AppColors.cyanNeon
                            : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                        onTap: () => settingsController.setTheme(mode),
                        child: Row(
                          children: [
                            // Theme Color Palette Preview Dots
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: previewCfg.boardBackgroundColor,
                                border: Border.all(
                                  color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                                  width: 2.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: previewCfg.xPrimaryColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                mode.titleVi,
                                style: AppStyles.headingSmall(
                                  color: isSelected
                                      ? AppColors.cyanNeon
                                      : themeCfg.primaryTextColor,
                                ).copyWith(
                                  fontSize: 17,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle_rounded, color: AppColors.cyanNeon, size: 26),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),

                  // 2. Âm thanh & Rung
                  _sectionHeader('ÂM THANH & PHẢN HỒI', Icons.volume_up_rounded, themeCfg),
                  const SizedBox(height: 14),
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _switchRow(
                          title: 'Âm thanh trò chơi',
                          subtitle: 'Hiệu ứng âm thanh khi đặt quân và chiến thắng',
                          value: settingsController.soundEnabled,
                          themeCfg: themeCfg,
                          onChanged: settingsController.toggleSound,
                        ),
                        Divider(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                        _switchRow(
                          title: 'Rung phản hồi (Haptic)',
                          subtitle: 'Rung nhẹ khi chạm chọn ô trên bàn cờ',
                          value: settingsController.hapticEnabled,
                          themeCfg: themeCfg,
                          onChanged: settingsController.toggleHaptic,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. Hiển thị bàn cờ
                  _sectionHeader('HIỂN THỊ BÀN CỜ', Icons.grid_on_rounded, themeCfg),
                  const SizedBox(height: 14),
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: _switchRow(
                      title: 'Hiển thị tọa độ ô',
                      subtitle: 'Hiện nhãn chữ cái A..Z và số hàng 1..N quanh viền bàn cờ',
                      value: settingsController.showCoordinates,
                      themeCfg: themeCfg,
                      onChanged: settingsController.toggleShowCoordinates,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4. Thông tin ứng dụng
                  _sectionHeader('THÔNG TIN', Icons.info_outline_rounded, themeCfg),
                  const SizedBox(height: 14),
                  GlassCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: AppColors.xGradient,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.cyanNeon.withValues(alpha: 0.35),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(Icons.videogame_asset_rounded, color: Colors.white, size: 28),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tic-Tac-Toe & Caro Pro',
                                  style: AppStyles.headingSmall(color: themeCfg.primaryTextColor).copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Phiên bản 1.0.0 (Pure Dart Engine)',
                                  style: AppStyles.bodyMedium(color: themeCfg.secondaryTextColor).copyWith(
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Divider(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                        const SizedBox(height: 10),
                        Text(
                          'Thuật toán: Minimax tối ưu cho 3x3, Heuristic Pattern Evaluation & Alpha-Beta Pruning cho bàn cờ lớn (5x5, 10x10, 15x15, 20x20).',
                          style: AppStyles.bodyMedium(color: themeCfg.secondaryTextColor).copyWith(
                            height: 1.5,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _sectionHeader(String title, IconData icon, ThemeConfig themeCfg) {
    return Row(
      children: [
        Icon(icon, size: 22, color: AppColors.cyanNeon),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppStyles.headingSmall(color: themeCfg.primaryTextColor).copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            fontSize: 17,
          ),
        ),
      ],
    );
  }

  Widget _switchRow({
    required String title,
    required String subtitle,
    required bool value,
    required ThemeConfig themeCfg,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppStyles.headingSmall(color: themeCfg.primaryTextColor).copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: AppStyles.bodyMedium(color: themeCfg.secondaryTextColor).copyWith(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            activeThumbColor: AppColors.cyanNeon,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
