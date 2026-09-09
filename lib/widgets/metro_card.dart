import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// MetroCard:
/// White background, 16–20px rounded corners, very soft subtle elevation,
/// and optional gentle border for consistent card surfaces.
class MetroCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double borderRadius;
  final List<BoxShadow>? shadows;
  final Border? border;
  final double? width;
  final double? height;

  const MetroCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.borderRadius = AppRadius.lg,
    this.shadows,
    this.border,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ?? AppColors.surface;
    final effectiveBorder = border ??
        Border.all(
          color: AppColors.borderSubtle,
          width: 1.0,
        );
    final effectiveShadows = shadows ?? AppShadows.card;

    Widget cardContent = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: effectiveBorder,
        boxShadow: effectiveShadows,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Material(
          color: Colors.transparent,
          child: onTap != null
              ? InkWell(
                  onTap: onTap,
                  splashColor: AppColors.primary.withValues(alpha: 0.06),
                  highlightColor: AppColors.primary.withValues(alpha: 0.03),
                  child: Padding(
                    padding: padding,
                    child: child,
                  ),
                )
              : Padding(
                  padding: padding,
                  child: child,
                ),
        ),
      ),
    );

    return cardContent;
  }
}
