import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../theme/app_theme.dart';
import '../../widgets/metro_card.dart';
import '../../widgets/screen_switcher_sheet.dart';
import '../../widgets/status_badge.dart';

class ProfileMenuItem {
  final String title;
  final String? subtitle;
  final PhosphorIconData icon;
  final VoidCallback onTap;
  final bool isDestructive;
  final Widget? trailingBadge;

  const ProfileMenuItem({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
    this.trailingBadge,
  });
}

/// Screen 6: Profile Screen
/// Circular avatar, user info, active metro pass card with StatusBadge,
/// and list-tile menu with icons and chevron arrows.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      ProfileMenuItem(
        title: 'Thông tin cá nhân',
        subtitle: 'Họ tên, ngày sinh, giới tính & liên hệ',
        icon: PhosphorIconsRegular.user,
        onTap: () {
          Navigator.of(context).pushNamed('/edit-profile');
        },
      ),
      ProfileMenuItem(
        title: 'Vé & Thẻ của tôi',
        subtitle: '1 thẻ đang dùng, 12 chuyến đã đi',
        icon: PhosphorIconsRegular.ticket,
        trailingBadge: const StatusBadge(
          status: TicketStatus.paid,
          fontSize: 11,
        ),
        onTap: () {
          _showTicketsDialog(context);
        },
      ),
      ProfileMenuItem(
        title: 'Phương thức thanh toán',
        subtitle: 'Visa •••• 4242, Ví MoMo, ZaloPay',
        icon: PhosphorIconsRegular.creditCard,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quản lý phương thức thanh toán'),
              backgroundColor: AppColors.primary,
            ),
          );
        },
      ),
      ProfileMenuItem(
        title: 'Thông báo',
        subtitle: 'Trễ tàu, cập nhật tuyến & ưu đãi',
        icon: PhosphorIconsRegular.bellSimple,
        onTap: () {
          Navigator.of(context).pushNamed('/notifications');
        },
      ),
      ProfileMenuItem(
        title: 'Tin tức & Cập nhật',
        subtitle: 'Thông báo vận hành, lịch tàu & cẩm nang',
        icon: PhosphorIconsRegular.newspaper,
        onTap: () {
          Navigator.of(context).pushNamed('/news');
        },
      ),
      ProfileMenuItem(
        title: 'Trợ giúp & Hỗ trợ',
        subtitle: 'Câu hỏi thường gặp, hướng dẫn & trợ giúp',
        icon: PhosphorIconsRegular.question,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Trung tâm Trợ giúp & Hỗ trợ'),
              backgroundColor: AppColors.primary,
            ),
          );
        },
      ),
      ProfileMenuItem(
        title: 'Điều khoản & Bảo mật',
        subtitle: 'Quy định đi tàu & an toàn hành khách',
        icon: PhosphorIconsRegular.shieldCheck,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Điều khoản sử dụng & Chính sách bảo mật'),
              backgroundColor: AppColors.primary,
            ),
          );
        },
      ),
      ProfileMenuItem(
        title: 'Đăng xuất',
        subtitle: 'Đăng xuất khỏi thiết bị này',
        icon: PhosphorIconsRegular.signOut,
        isDestructive: true,
        onTap: () {
          _showLogoutDialog(context);
        },
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header title with Screen Switcher
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tài khoản của tôi',
                    style: AppTypography.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/edit-profile');
                        },
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: const PhosphorIcon(
                            PhosphorIconsRegular.pencilSimple,
                            size: 18,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      const ScreenSwitcherButton(),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // User Info Card
              MetroCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    // Circular Avatar with edit indicator
                    Stack(
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF2F6FED),
                                Color(0xFF6898F8),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.25),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: PhosphorIcon(
                              PhosphorIconsRegular.user,
                              size: 34,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.surface,
                                width: 2,
                              ),
                            ),
                            child: const PhosphorIcon(
                              PhosphorIconsRegular.check,
                              size: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: AppSpacing.md),

                    // User details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'Alex Nguyễn',
                                  style: AppTypography.textTheme.titleMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.sm),
                                ),
                                child: Text(
                                  'ĐÃ XÁC THỰC',
                                  style: AppTypography.textTheme.labelSmall
                                      ?.copyWith(
                                    color: AppColors.primary,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '+84 987 654 321',
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            'alex.nguyen@example.com',
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Active Ticket / Monthly Pass Showcase
              MetroCard(
                backgroundColor: AppColors.primarySubtle,
                border: Border.all(
                  color: AppColors.primaryLight,
                  width: 1.2,
                ),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                              ),
                              child: const PhosphorIcon(
                                PhosphorIconsRegular.ticket,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Thẻ tháng đang hoạt động',
                              style:
                                  AppTypography.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                        const StatusBadge(status: TicketStatus.paid),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Bến Thành ⇄ Suối Tiên (Toàn tuyến không giới hạn)',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hạn dùng đến 25/10/2026 • Sẵn sàng chạm NFC',
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Section Title
              Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.xs,
                  bottom: AppSpacing.sm,
                ),
                child: Text(
                  'CÀI ĐẶT TÀI KHOẢN',
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              // Menu list tiles
              MetroCard(
                padding: EdgeInsets.zero,
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: menuItems.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    indent: 56,
                  ),
                  itemBuilder: (context, index) {
                    final item = menuItems[index];
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: item.onTap,
                        splashColor: (item.isDestructive
                                ? AppColors.error
                                : AppColors.primary)
                            .withValues(alpha: 0.08),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.md - 2,
                          ),
                          child: Row(
                            children: [
                              // Menu Icon
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: item.isDestructive
                                      ? AppColors.errorLight
                                      : AppColors.primaryLight,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.md),
                                ),
                                child: Center(
                                  child: PhosphorIcon(
                                    item.icon,
                                    size: 19,
                                    color: item.isDestructive
                                        ? AppColors.error
                                        : AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),

                              // Title & subtitle
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: AppTypography.textTheme.bodyLarge
                                          ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: item.isDestructive
                                            ? AppColors.error
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                    if (item.subtitle != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        item.subtitle!,
                                        style: AppTypography.textTheme.bodySmall
                                            ?.copyWith(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              // Optional trailing badge or chevron
                              if (item.trailingBadge != null) ...[
                                item.trailingBadge!,
                                const SizedBox(width: AppSpacing.xs),
                              ],

                              PhosphorIcon(
                                PhosphorIconsRegular.caretRight,
                                size: 16,
                                color: item.isDestructive
                                    ? AppColors.error
                                    : AppColors.textMuted,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Row(
          children: const [
            PhosphorIcon(
              PhosphorIconsRegular.signOut,
              color: AppColors.error,
              size: 22,
            ),
            SizedBox(width: AppSpacing.xs),
            Text('Đăng xuất'),
          ],
        ),
        content: const Text(
          'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản MetroGo không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: const Text(
              'Đăng xuất',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showTicketsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppRadius.xl),
            topRight: Radius.circular(AppRadius.xl),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Trạng thái vé mẫu',
              style: AppTypography.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Hiển thị 4 trạng thái vé trên hệ thống:',
              style: AppTypography.textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            _statusRow('Vé lượt (Bến Thành → Nhà Hát TP)', TicketStatus.paid),
            const SizedBox(height: AppSpacing.xs),
            _statusRow('Vé khứ hồi (Suối Tiên)', TicketStatus.pending),
            const SizedBox(height: AppSpacing.xs),
            _statusRow('Vé ngày (Hôm qua)', TicketStatus.used),
            const SizedBox(height: AppSpacing.xs),
            _statusRow('Vé khuyến mãi cuối tuần', TicketStatus.expired),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _statusRow(String route, TicketStatus status) {
    return MetroCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              route,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          StatusBadge(status: status, showIcon: true),
        ],
      ),
    );
  }
}
