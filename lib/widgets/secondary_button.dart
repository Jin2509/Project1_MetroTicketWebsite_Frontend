import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../theme/app_theme.dart';

/// Secondary button for MetroGo:
/// Clean outline style with primary blue border, white surface background,
/// rounded corners, and smooth tap feedback.
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final PhosphorIconData? leadingIcon;
  final PhosphorIconData? trailingIcon;
  final double height;
  final double? width;
  final Color? borderColor;
  final Color? textColor;
  final Color? backgroundColor;
  final double borderRadius;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.leadingIcon,
    this.trailingIcon,
    this.height = 54.0,
    this.width,
    this.borderColor,
    this.textColor,
    this.backgroundColor,
    this.borderRadius = AppRadius.md,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null && !isLoading;
    final effectiveBorderColor = borderColor ?? AppColors.primary;
    final effectiveTextColor = textColor ?? AppColors.primary;
    final effectiveBgColor = backgroundColor ?? AppColors.surface;

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
      opacity: isEnabled ? 1.0 : 0.5,
      child: Container(
        height: height,
        width: isFullWidth ? double.infinity : width,
        decoration: BoxDecoration(
          color: effectiveBgColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: effectiveBorderColor,
            width: 1.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          child: InkWell(
            onTap: isEnabled ? onPressed : null,
            borderRadius: BorderRadius.circular(borderRadius),
            splashColor: effectiveBorderColor.withValues(alpha: 0.08),
            highlightColor: effectiveBorderColor.withValues(alpha: 0.04),
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
