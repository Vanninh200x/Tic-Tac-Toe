import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';

class GameTimerWidget extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;

  const GameTimerWidget({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
  });

  @override
  Widget build(BuildContext context) {
    if (totalSeconds <= 0) return const SizedBox.shrink();

    final isUrgent = remainingSeconds <= 5;
    final progress = totalSeconds > 0 ? remainingSeconds / totalSeconds : 1.0;
    final timerColor = isUrgent ? AppColors.danger : AppColors.amberNeon;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF131A2E).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: timerColor.withValues(alpha: 0.5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: timerColor.withValues(alpha: isUrgent ? 0.4 : 0.2),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 2.5,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(timerColor),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${remainingSeconds}s',
            style: AppStyles.bodySmall().copyWith(
              color: timerColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
