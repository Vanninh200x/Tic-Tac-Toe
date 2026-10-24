import 'package:flutter/material.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/utils/sound_haptics.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = AppDimens.radiusLarge,
    this.backgroundColor,
    this.borderColor,
    this.shadows,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultBg =
        backgroundColor ??
        (isDark
            ? const Color(0xFF162038).withValues(alpha: 0.9)
            : Colors.white.withValues(alpha: 0.95));

    final defaultBorder =
        borderColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.12)
            : const Color(0xFFE2E8F0));

    final defaultShadows =
        shadows ??
        (isDark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 18,
                  spreadRadius: 1,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.05),
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ]
            : [
                BoxShadow(
                  color: const Color(0xFF64748B).withValues(alpha: 0.12),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]);

    Widget cardContent = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: defaultBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: defaultBorder, width: 1.5),
        boxShadow: defaultShadows,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppDimens.paddingMedium),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: () {
          SoundHapticsHelper.playButtonFeedback();
          onTap!();
        },
        child: cardContent,
      );
    }

    return cardContent;
  }
}
