import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_styles.dart';
import '../../core/utils/sound_haptics.dart';

class GlossyButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final List<Color>? gradient;
  final Color glowColor;
  final double height;
  final double? width;
  final bool isLoading;

  const GlossyButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.gradient,
    this.glowColor = AppColors.cyanNeon,
    this.height = AppDimens.buttonHeight,
    this.width,
    this.isLoading = false,
  });

  @override
  State<GlossyButton> createState() => _GlossyButtonState();
}

class _GlossyButtonState extends State<GlossyButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.isLoading;
    final defaultGradient = widget.gradient ?? AppColors.xGradient;

    return GestureDetector(
      onTapDown: enabled
          ? (_) {
              setState(() => _isPressed = true);
              SoundHapticsHelper.playButtonFeedback();
            }
          : null,
      onTapUp: enabled
          ? (_) {
              setState(() => _isPressed = false);
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: enabled ? () => setState(() => _isPressed = false) : null,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: enabled
                  ? defaultGradient
                  : [
                      Colors.grey.shade400,
                      Colors.grey.shade500,
                    ],
            ),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: widget.glowColor.withValues(alpha: _isPressed ? 0.25 : 0.45),
                      blurRadius: _isPressed ? 12 : 22,
                      spreadRadius: _isPressed ? 0 : 2,
                      offset: Offset(0, _isPressed ? 4 : 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
            border: Border.all(
              color: Colors.white.withValues(alpha: enabled ? 0.4 : 0.15),
              width: 1.8,
            ),
          ),
          child: Stack(
            children: [
              // Glossy reflection line at top
              Positioned(
                top: 0,
                left: 12,
                right: 12,
                height: widget.height * 0.46,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppDimens.radiusLarge),
                      topRight: Radius.circular(AppDimens.radiusLarge),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.35),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),

              // Button Content
              Center(
                child: widget.isLoading
                    ? const SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(
                          strokeWidth: 3.0,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              color: Colors.white,
                              size: 24,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            const SizedBox(width: 10),
                          ],
                          Text(
                            widget.text,
                            style: AppStyles.buttonText().copyWith(
                              fontSize: 18,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
