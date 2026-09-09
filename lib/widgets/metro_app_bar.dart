import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../theme/app_theme.dart';

/// MetroAppBar:
/// Minimal, modern app bar for MetroGo.
/// Supports a clean title, Phosphor back navigation arrow, optional actions,
/// and an optional subtle soft-blue gradient background.
class MetroAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final bool useGradient;
  final Color? backgroundColor;
  final double elevation;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;

  const MetroAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.useGradient = false,
    this.backgroundColor,
    this.elevation = 0,
    this.centerTitle = true,
    this.bottom,
  });

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );

  @override
  Widget build(BuildContext context) {
    final bool canPop = Navigator.of(context).canPop();
    final bool shouldShowBack = showBackButton && canPop;

    Widget? leading;
    if (shouldShowBack) {
      leading = Center(
        child: Container(
          margin: const EdgeInsets.only(left: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.borderSubtle, width: 1),
            boxShadow: AppShadows.subtle,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.md),
              onTap: onBackPressed ?? () => Navigator.of(context).maybePop(),
              child: const SizedBox(
                width: 38,
                height: 38,
                child: Center(
                  child: PhosphorIcon(
                    PhosphorIconsRegular.arrowLeft,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    Widget appBar = AppBar(
      elevation: elevation,
      scrolledUnderElevation: 0,
      centerTitle: centerTitle,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leading: leading,
      leadingWidth: shouldShowBack ? 54 : 16,
      title: titleWidget ??
          (title != null
              ? Text(
                  title!,
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                )
              : null),
      actions: actions != null
          ? [
              ...actions!,
              const SizedBox(width: AppSpacing.sm),
            ]
          : null,
      bottom: bottom,
    );

    if (useGradient) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEAF2FD),
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(bottom: false, child: appBar),
      );
    }

    return Container(
      color: backgroundColor ?? AppColors.background,
      child: SafeArea(bottom: false, child: appBar),
    );
  }
}
