import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../models/ticket_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/metro_app_bar.dart';
import '../../widgets/metro_card.dart';
import '../../widgets/screen_switcher_sheet.dart';
import '../../widgets/vietnam_map_background.dart';
import '../booking/booking_flow_screen.dart';
import '../map/live_map_screen.dart';
import '../tickets/ticket_detail_screen.dart';

enum NotificationCategory {
  ticketAlert,
  trainDelay,
  promo,
  system,
}

class MetroNotificationItem {
  final String id;
  final String title;
  final String message;
  final String timeAgo;
  final NotificationCategory category;
  final bool isToday;
  bool isRead;
  final String? actionLabel;
  final VoidCallback? onAction;

  MetroNotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timeAgo,
    required this.category,
    required this.isToday,
    this.isRead = false,
    this.actionLabel,
    this.onAction,
  });
}

/// Screen: Notifications Screen
/// Displays passenger alerts (ticket expiration, line delays, promotions),
/// grouped by 'Today' and 'Earlier', with category filtering, unread status indicators,
/// and swipe-to-dismiss (Dismissible) with undo functionality.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'Tất cả';

  final List<String> _filters = [
    'Tất cả',
    'Chưa đọc',
    'Vé',
    'Chậm chuyến',
    'Ưu đãi',
  ];

  late List<MetroNotificationItem> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = [
      MetroNotificationItem(
        id: 'n1',
        title: 'Thông báo trễ tuyến Line 1',
        message:
            'Hiệu chỉnh tín hiệu gần ga Thảo Điền khiến các đoàn tàu hướng về trung tâm chậm 4-6 phút.',
        timeAgo: '12 phút trước',
        category: NotificationCategory.trainDelay,
        isToday: true,
        isRead: false,
        actionLabel: 'Xem bản đồ trực tiếp',
      ),
      MetroNotificationItem(
        id: 'n2',
        title: 'Vé tháng sắp hết hạn',
        message:
            'Vé tháng 30 ngày của bạn sẽ hết hạn sau 2 ngày nữa (15/10). Nhấn vào đây để gia hạn nhanh.',
        timeAgo: '1 giờ trước',
        category: NotificationCategory.ticketAlert,
        isToday: true,
        isRead: false,
        actionLabel: 'Gia hạn vé',
      ),
      MetroNotificationItem(
        id: 'n3',
        title: 'Ưu đãi vé sinh viên',
        message:
            'Giảm ngay 50% toàn bộ vé lượt trong tuần lễ thi cử! Áp dụng cho tài khoản sinh viên đã xác thực.',
        timeAgo: '3 giờ trước',
        category: NotificationCategory.promo,
        isToday: true,
        isRead: false,
        actionLabel: 'Nhận ưu đãi',
      ),
      MetroNotificationItem(
        id: 'n4',
        title: 'Mã QR soát vé đã sẵn sàng',
        message:
            'Vé lượt Bến Thành – Suối Tiên của bạn đã sẵn sàng. Nhấn để mở mã QR quét tại cổng soát vé.',
        timeAgo: 'Hôm qua, 18:24',
        category: NotificationCategory.ticketAlert,
        isToday: false,
        isRead: true,
        actionLabel: 'Xem mã QR',
      ),
      MetroNotificationItem(
        id: 'n5',
        title: 'Bảo trì tại ga Bến Thành',
        message:
            'Thang cuốn số 3 tại Lối vào A sẽ tạm dừng hoạt động để bảo trì định kỳ từ 23:00 đến 04:00 đêm nay.',
        timeAgo: '11/10, 14:10',
        category: NotificationCategory.system,
        isToday: false,
        isRead: true,
      ),
      MetroNotificationItem(
        id: 'n6',
        title: 'Tăng chuyến tàu đêm cuối tuần',
        message:
            'Tuyến Line 1 kéo dài thời gian hoạt động đến 23:30 vào mỗi tối Thứ Sáu và Thứ Bảy bắt đầu từ tuần này!',
        timeAgo: '09/10, 09:00',
        category: NotificationCategory.promo,
        isToday: false,
        isRead: true,
        actionLabel: 'Xem lịch trình',
      ),
    ];
  }

  void _markAllAsRead() {
    setState(() {
      for (final n in _notifications) {
        n.isRead = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            PhosphorIcon(
              PhosphorIconsRegular.checkCircle,
              color: Colors.white,
              size: 18,
            ),
            SizedBox(width: 8),
            Text('Đã đánh dấu tất cả là đã đọc'),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
    );
  }

  void _dismissNotification(MetroNotificationItem item, int originalIndex) {
    setState(() {
      _notifications.removeWhere((n) => n.id == item.id);
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã xóa "${item.title}"'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        action: SnackBarAction(
          label: 'HOÀN TÁC',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _notifications.insert(originalIndex, item);
            });
          },
        ),
      ),
    );
  }

  void _handleNotificationAction(MetroNotificationItem item) {
    setState(() {
      item.isRead = true;
    });

    switch (item.category) {
      case NotificationCategory.trainDelay:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const LiveMapScreen()),
        );
        break;
      case NotificationCategory.ticketAlert:
        if (TicketStore.instance.activeTickets.isNotEmpty) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TicketDetailScreen(
                ticket: TicketStore.instance.activeTickets.first,
              ),
            ),
          );
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const BookingFlowScreen(),
            ),
          );
        }
        break;
      case NotificationCategory.promo:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const BookingFlowScreen(),
          ),
        );
        break;
      case NotificationCategory.system:
        _showDetailModal(item);
        break;
    }
  }

  void _showDetailModal(MetroNotificationItem item) {
    setState(() => item.isRead = true);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
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
                  color: AppColors.borderMedium,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                _buildCategoryIcon(item.category),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: AppTypography.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        item.timeAgo,
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              item.message,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Đóng'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<MetroNotificationItem> get _filteredList {
    return _notifications.where((item) {
      if (_selectedFilter == 'Chưa đọc') return !item.isRead;
      if (_selectedFilter == 'Vé') {
        return item.category == NotificationCategory.ticketAlert;
      }
      if (_selectedFilter == 'Chậm chuyến') {
        return item.category == NotificationCategory.trainDelay;
      }
      if (_selectedFilter == 'Ưu đãi') {
        return item.category == NotificationCategory.promo;
      }
      return true;
    }).toList();
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredList;
    final todayList = filtered.where((n) => n.isToday).toList();
    final earlierList = filtered.where((n) => !n.isToday).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MetroAppBar(
        title: 'Thông báo',
        actions: [
          if (_unreadCount > 0)
            TextButton.icon(
              onPressed: _markAllAsRead,
              icon: const PhosphorIcon(
                PhosphorIconsRegular.checks,
                size: 16,
                color: AppColors.primaryText,
              ),
              label: Text(
                'Đã đọc',
                style: AppTypography.textTheme.labelMedium?.copyWith(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const ScreenSwitcherButton(),
        ],
      ),
      body: VietnamMapBackground(
        opacity: 0.08,
        showBeacon: false,
        child: Column(
          children: [
            // Filter Chips Row
            _buildFilterBar(),

            // Notifications List
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState()
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.sm,
                        AppSpacing.lg,
                        AppSpacing.xl,
                      ),
                      children: [
                        if (todayList.isNotEmpty) ...[
                          _buildSectionHeader('HÔM NAY'),
                          const SizedBox(height: AppSpacing.xs),
                          ...todayList.map((item) => _buildDismissibleTile(item)),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        if (earlierList.isNotEmpty) ...[
                          _buildSectionHeader('TRƯỚC ĐÓ'),
                          const SizedBox(height: AppSpacing.xs),
                          ...earlierList.map((item) => _buildDismissibleTile(item)),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          String label = filter;
          if (filter == 'Chưa đọc' && _unreadCount > 0) {
            label = 'Chưa đọc ($_unreadCount)';
          }

          return ChoiceChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (_) {
              setState(() => _selectedFilter = filter);
            },
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.surfaceSecondary,
            labelStyle: AppTypography.textTheme.bodySmall?.copyWith(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.full),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.borderSubtle,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            showCheckmark: false,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Text(
            title,
            style: AppTypography.textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Divider(
              color: AppColors.borderSubtle,
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDismissibleTile(MetroNotificationItem item) {
    final originalIndex = _notifications.indexOf(item);

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Xóa',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            SizedBox(width: 8),
            PhosphorIcon(
              PhosphorIconsRegular.trashSimple,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
      onDismissed: (_) {
        _dismissNotification(item, originalIndex);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: MetroCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          backgroundColor:
              item.isRead ? AppColors.surface : AppColors.surfaceSecondary,
          border: Border.all(
            color: item.isRead
                ? AppColors.borderSubtle
                : AppColors.primary.withValues(alpha: 0.45),
            width: item.isRead ? 1.0 : 1.2,
          ),
          onTap: () => _handleNotificationAction(item),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Icon Badge
              _buildCategoryIcon(item.category),

              const SizedBox(width: AppSpacing.md),

              // Content details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style:
                                AppTypography.textTheme.titleSmall?.copyWith(
                              fontWeight: item.isRead
                                  ? FontWeight.w600
                                  : FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          item.timeAgo,
                          style:
                              AppTypography.textTheme.labelSmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        if (!item.isRead) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.message,
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    if (item.actionLabel != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      InkWell(
                        onTap: () => _handleNotificationAction(item),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.actionLabel!,
                              style: AppTypography.textTheme.labelMedium
                                  ?.copyWith(
                                color: AppColors.primaryText,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const PhosphorIcon(
                              PhosphorIconsRegular.arrowRight,
                              size: 13,
                              color: AppColors.primaryText,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(NotificationCategory category) {
    Color bgColor;
    Color iconColor;
    PhosphorIconData icon;

    switch (category) {
      case NotificationCategory.trainDelay:
        bgColor = AppColors.warningLight;
        iconColor = AppColors.warning;
        icon = PhosphorIconsRegular.warningCircle;
        break;
      case NotificationCategory.ticketAlert:
        bgColor = AppColors.primaryLight;
        iconColor = AppColors.primaryText;
        icon = PhosphorIconsRegular.ticket;
        break;
      case NotificationCategory.promo:
        bgColor = AppColors.successLight;
        iconColor = AppColors.successText;
        icon = PhosphorIconsRegular.sparkle;
        break;
      case NotificationCategory.system:
        bgColor = AppColors.surfaceMuted;
        iconColor = AppColors.textSecondary;
        icon = PhosphorIconsRegular.info;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: iconColor.withValues(alpha: 0.3)),
      ),
      child: Center(
        child: PhosphorIcon(
          icon,
          color: iconColor,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: PhosphorIcon(
                  PhosphorIconsRegular.bellSlash,
                  color: AppColors.primary,
                  size: 38,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Không có thông báo',
              style: AppTypography.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _selectedFilter == 'Tất cả'
                  ? 'Bạn đã xem hết thông báo! Cảnh báo chậm chuyến và thông tin vé sẽ hiển thị tại đây.'
                  : 'Không tìm thấy thông báo ${_selectedFilter.toLowerCase()} nào.',
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (_selectedFilter != 'Tất cả') ...[
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton(
                onPressed: () {
                  setState(() => _selectedFilter = 'Tất cả');
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: const Text('Xem tất cả thông báo'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
