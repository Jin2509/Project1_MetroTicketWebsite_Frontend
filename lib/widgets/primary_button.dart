import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../theme/app_theme.dart';

/// Primary call-to-action button for MetroGo:
/// Solid blue, soft rounded corners, optional icons, and loading/disabled states.
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final PhosphorIconData? leadingIcon;
  final PhosphorIconData? trailingIcon;
  final double height;
  final double? width;
  final Color? backgroundColor;
  final Color? textColor;
  final double borderRadius;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.leadingIcon,
    this.trailingIcon,
    this.height = 54.0,
    this.width,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = AppRadius.md,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null && !isLoading;
    final effectiveBgColor = backgroundColor ?? AppColors.primary;
    final effectiveTextColor = textColor ?? AppColors.textOnPrimary;

    Widget content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingIcon != null && !isLoading) ...[
          PhosphorIcon(
            leadingIcon!,
            size: 20,
            color: effectiveTextColor,
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
        if (isLoading)
          SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
            ),
          )
        else
          Text(
            text,
            style: AppTypography.textTheme.labelLarge?.copyWith(
              color: effectiveTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        if (trailingIcon != null && !isLoading) ...[
          const SizedBox(width: AppSpacing.xs),
          PhosphorIcon(
            trailingIcon!,
            size: 20,
            color: effectiveTextColor,
          ),
        ],
      ],
    );

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: isEnabled ? 1.0 : 0.55,
      child: Container(
        height: height,
        width: isFullWidth ? double.infinity : width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: isEnabled ? AppShadows.buttonPrimary : const [],
        ),
        child: Material(
          color: effectiveBgColor,
          borderRadius: BorderRadius.circular(borderRadius),
          child: InkWell(
            onTap: isEnabled ? onPressed : null,
            borderRadius: BorderRadius.circular(borderRadius),
            splashColor: Colors.white.withValues(alpha: 0.18),
            highlightColor: Colors.white.withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
