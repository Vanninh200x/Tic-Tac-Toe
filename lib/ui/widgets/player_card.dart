import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_styles.dart';
import '../../models/game_enums.dart';

class PlayerCard extends StatelessWidget {
  final PlayerType player;
  final String name;
  final int score;
  final bool isCurrentTurn;
  final bool isAi;

  const PlayerCard({
    super.key,
    required this.player,
    required this.name,
    required this.score,
    required this.isCurrentTurn,
    this.isAi = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isX = player == PlayerType.x;
    final primaryColor = isX ? AppColors.cyanNeon : AppColors.coralNeon;
    final gradient = isX ? AppColors.xGradient : AppColors.oGradient;

    final bgColor = isDark
        ? (isCurrentTurn ? const Color(0xFF1E294B) : const Color(0xFF131A2D))
        : (isCurrentTurn ? Colors.white : const Color(0xFFF8FAFC));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
        border: Border.all(
          color: isCurrentTurn ? primaryColor : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
          width: isCurrentTurn ? 2.5 : 1.2,
        ),
        boxShadow: isCurrentTurn
            ? [
                BoxShadow(
                  color: primaryColor.withValues(alpha: isDark ? 0.45 : 0.25),
                  blurRadius: 18,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar Icon with Badge
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: isAi
                  ? const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 26)
                  : Text(
                      isX ? 'X' : 'O',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // Name and Score
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyles.headingSmall(
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ).copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (isCurrentTurn) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor,
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Thắng: $score',
                  style: AppStyles.bodyMedium(
                    color: isDark ? Colors.white70 : const Color(0xFF475569),
                  ).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
