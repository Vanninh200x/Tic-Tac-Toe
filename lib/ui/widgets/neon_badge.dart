import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';

class NeonBadge extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color color;

  const NeonBadge({
    super.key,
    required this.text,
    this.icon,
    this.color = AppColors.cyanNeon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 7),
          ],
          Text(
            text,
            style: AppStyles.bodySmall().copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 15,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
