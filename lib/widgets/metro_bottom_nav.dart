import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../theme/app_theme.dart';

/// MetroBottomNavItem data model
class MetroBottomNavItem {
  final String label;
  final PhosphorIconData regularIcon;
  final PhosphorIconData activeIcon;

  const MetroBottomNavItem({
    required this.label,
    required this.regularIcon,
    required this.activeIcon,
  });
}

/// MetroBottomNav:
/// 5 tabs: Home, Search, My Tickets, AI Assistant, Profile.
/// Clean, floating or docked bottom navigation bar with smooth indicator pill,
/// Phosphor icons, and subtle elevation.
class MetroBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const MetroBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<MetroBottomNavItem> items = [
    MetroBottomNavItem(
      label: 'Trang chủ',
      regularIcon: PhosphorIconsRegular.house,
      activeIcon: PhosphorIconsFill.house,
    ),
    MetroBottomNavItem(
      label: 'Tra cứu & Bản đồ',
      regularIcon: PhosphorIconsRegular.mapTrifold,
      activeIcon: PhosphorIconsFill.mapTrifold,
    ),
    MetroBottomNavItem(
      label: 'Vé của tôi',
      regularIcon: PhosphorIconsRegular.ticket,
      activeIcon: PhosphorIconsFill.ticket,
    ),
    MetroBottomNavItem(
      label: 'Tài khoản',
      regularIcon: PhosphorIconsRegular.user,
      activeIcon: PhosphorIconsFill.user,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.borderSubtle,
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = index == currentIndex;

              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  splashColor: AppColors.primary.withValues(alpha: 0.15),
                  highlightColor: AppColors.primary.withValues(alpha: 0.08),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryLight
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.15),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: PhosphorIcon(
                            isSelected ? item.activeIcon : item.regularIcon,
                            size: 20,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            fontSize: 11,
                            fontWeight:
                                isSelected ? FontWeight.w800 : FontWeight.w500,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
