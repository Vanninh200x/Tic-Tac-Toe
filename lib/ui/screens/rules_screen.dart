import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/settings_controller.dart';
import '../widgets/glass_card.dart';

class RulesScreen extends StatelessWidget {
  final SettingsController settingsController;

  const RulesScreen({
    super.key,
    required this.settingsController,
  });

  @override
  Widget build(BuildContext context) {
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
          'Luật Chơi & Chiến Thuật',
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
              // 1. Cờ Tic-Tac-Toe (3x3)
              _ruleCard(
                title: '1. Tic-Tac-Toe Kinh Điển (3×3)',
                icon: Icons.grid_3x3_rounded,
                color: AppColors.cyanNeon,
                themeCfg: themeCfg,
                isDark: isDark,
                content:
                    '• Hai người chơi luân phiên đánh dấu vào ô trống trên bàn cờ 3×3 bằng quân X hoặc O.\n\n'
                    '• Người chơi nào tạo được một đường thẳng gồm 3 quân liên tiếp (ngang, dọc hoặc chéo) trước sẽ chiến thắng ngay lập tức.\n\n'
                    '• Nếu cả 9 ô đều kín mà không ai tạo được hàng 3 quân thì ván cờ kết thúc Hòa.',
              ),
              const SizedBox(height: 18),

              // 2. Cờ Caro / Gomoku (Bàn lớn)
              _ruleCard(
                title: '2. Cờ Caro Quốc Tế (Gomoku)',
                icon: Icons.border_all_rounded,
                color: AppColors.coralNeon,
                themeCfg: themeCfg,
                isDark: isDark,
                content:
                    '• Bàn cờ thường có kích thước 15×15 (chuẩn quốc tế) hoặc 20×20 (bàn mở rộng).\n\n'
                    '• Mục tiêu: Xếp được 5 quân liên tiếp trên cùng một hàng ngang, cột dọc hoặc đường chéo.\n\n'
                    '• Người chơi đánh trước thường cầm quân X, người sau cầm quân O.',
              ),
              const SizedBox(height: 18),

              // 3. Luật Chặn 2 Đầu (Caro Việt Nam)
              _ruleCard(
                title: '3. Luật Chặn 2 Đầu (Việt Nam)',
                icon: Icons.block_rounded,
                color: AppColors.gold,
                themeCfg: themeCfg,
                isDark: isDark,
                content:
                    '• Trong luật Caro truyền thống tại Việt Nam: nếu người chơi tạo được chuỗi 5 quân liên tiếp nhưng cả 2 đầu của chuỗi này đều bị quân đối thủ chặn thì CHƯA ĐƯỢC TÍNH THẮNG.\n\n'
                    '• Nếu chỉ bị chặn 1 đầu và đầu còn lại còn trống, chuỗi 5 quân vẫn giành chiến thắng tuyệt đối.\n\n'
                    '• Bạn có thể BẬT hoặc TẮT tùy chọn này trong mục Cài đặt ván đấu trước khi chơi.',
              ),
              const SizedBox(height: 18),

              // 4. Mẹo Chiến Thuật Cao Cấp
              _ruleCard(
                title: '4. Mẹo Chiến Thuật Thắng Nhanh',
                icon: Icons.tips_and_updates_rounded,
                color: const Color(0xFF8B5CF6),
                themeCfg: themeCfg,
                isDark: isDark,
                content:
                    '• Thế Cờ "4 Mở 2 Đầu" (Open 4): Khi bạn có 4 quân liên tiếp và 2 đầu đều trống, đối thủ chỉ có thể chặn 1 đầu, đầu kia bạn sẽ thắng.\n\n'
                    '• Bẫy 3-3 Đôi: Tạo ra cùng lúc 2 chuỗi 3 quân mở. Đối thủ chỉ có thể chặn 1 chuỗi, bạn sẽ phát triển chuỗi còn lại lên 4 quân.\n\n'
                    '• Chiếm Vùng Tâm: Luôn ưu tiên đánh gần tâm bàn cờ để có nhiều hướng phát triển và kiểm soát thế cờ hơn đối thủ.',
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ruleCard({
    required String title,
    required IconData icon,
    required Color color,
    required String content,
    required ThemeConfig themeCfg,
    required bool isDark,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(AppDimens.paddingLarge),
      borderColor: color.withValues(alpha: isDark ? 0.35 : 0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: AppStyles.headingSmall(color: themeCfg.primaryTextColor).copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            content,
            style: AppStyles.bodyLarge(color: themeCfg.secondaryTextColor).copyWith(
              height: 1.6,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
