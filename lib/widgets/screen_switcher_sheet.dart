import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../theme/app_theme.dart';
import 'metro_card.dart';

class ScreenOption {
  final String title;
  final String description;
  final String routeName;
  final PhosphorIconData icon;

  const ScreenOption({
    required this.title,
    required this.description,
    required this.routeName,
    required this.icon,
  });
}

/// ScreenSwitcherSheet:
/// A developer/reviewer modal sheet enabling quick navigation to any of the app screens.
class ScreenSwitcherSheet extends StatelessWidget {
  const ScreenSwitcherSheet({super.key});

  static const List<ScreenOption> screens = [
    ScreenOption(
      title: '1. Màn hình khởi động',
      description: 'Logo trung tâm, dải màu chuyển nhẹ và hiệu ứng mượt mà',
      routeName: '/splash',
      icon: PhosphorIconsRegular.sparkle,
    ),
    ScreenOption(
      title: '2. Giới thiệu ứng dụng',
      description: '3 bước hướng dẫn, đồ họa tàu metro và thanh chỉ báo',
      routeName: '/onboarding',
      icon: PhosphorIconsRegular.compass,
    ),
    ScreenOption(
      title: '3. Đăng nhập',
      description: 'Số điện thoại/Email, ẩn hiện mật khẩu, đăng nhập mạng xã hội',
      routeName: '/login',
      icon: PhosphorIconsRegular.signIn,
    ),
    ScreenOption(
      title: '4. Đăng ký',
      description: 'Biểu mẫu tạo tài khoản, xác nhận mật khẩu & điều khoản',
      routeName: '/signup',
      icon: PhosphorIconsRegular.userPlus,
    ),
    ScreenOption(
      title: '5. Xác thực OTP',
      description: 'Nhập từng ô mã số, đếm ngược thời gian và gửi lại mã',
      routeName: '/otp',
      icon: PhosphorIconsRegular.shieldCheck,
    ),
    ScreenOption(
      title: '6. Hồ sơ cá nhân',
      description: 'Ảnh đại diện, huy hiệu thẻ đang dùng, menu danh mục',
      routeName: '/profile',
      icon: PhosphorIconsRegular.user,
    ),
    ScreenOption(
      title: '7. Chỉnh sửa hồ sơ',
      description: 'Cập nhật thông tin cá nhân, giới tính & ngày sinh',
      routeName: '/edit-profile',
      icon: PhosphorIconsRegular.pencilSimple,
    ),
    ScreenOption(
      title: '8. Quy trình đặt vé',
      description: 'Chọn loại vé theo tab, chọn chặng hành trình, số lượng vé',
      routeName: '/booking',
      icon: PhosphorIconsRegular.ticket,
    ),
    ScreenOption(
      title: '9. Thanh toán vé',
      description: 'Tóm tắt đơn hàng, tùy chọn ví ZaloPay / MoMo / VNPay',
      routeName: '/payment',
      icon: PhosphorIconsRegular.creditCard,
    ),
    ScreenOption(
      title: '10. Thanh toán thành công (Mã QR)',
      description: 'Mã QR soát vé khổ lớn (qr_flutter) và thông tin vé',
      routeName: '/payment-success',
      icon: PhosphorIconsRegular.checkCircle,
    ),
    ScreenOption(
      title: '11. Vé của tôi',
      description: 'Thẻ vé dạng cuống vé có đường cắt răng cưa & lọc lịch sử',
      routeName: '/my-tickets',
      icon: PhosphorIconsRegular.barcode,
    ),
    ScreenOption(
      title: '12. Chi tiết vé & Mã QR',
      description: 'Xem mã QR quét tại cửa kiểm soát, lưu vé & chia sẻ',
      routeName: '/ticket-detail',
      icon: PhosphorIconsRegular.qrCode,
    ),
    ScreenOption(
      title: '13. Tra cứu mạng lưới',
      description: 'Thanh tìm kiếm, thẻ gợi ý lộ trình, tất cả các tuyến',
      routeName: '/search',
      icon: PhosphorIconsRegular.magnifyingGlass,
    ),
    ScreenOption(
      title: '14. Chi tiết tuyến',
      description: 'Sơ đồ timeline các ga dọc tuyến, ga trung chuyển & bản đồ',
      routeName: '/route-detail',
      icon: PhosphorIconsRegular.gitBranch,
    ),
    ScreenOption(
      title: '15. Tra cứu lịch trình',
      description: 'Chọn ga đi/đến, đổi chiều ga, thời gian đi & đếm ngược',
      routeName: '/schedule-lookup',
      icon: PhosphorIconsRegular.clockCountdown,
    ),
    ScreenOption(
      title: '16. Bảng giá vé',
      description: 'So sánh vé lượt, vé 1 ngày/3 ngày và vé tháng ưu đãi',
      routeName: '/fare-table',
      icon: PhosphorIconsRegular.currencyCircleDollar,
    ),
    ScreenOption(
      title: '17. Bản đồ theo dõi tàu trực tiếp',
      description: 'Bản đồ OpenStreetMap full-screen, tàu chuyển động & bảng thông tin',
      routeName: '/live-map',
      icon: PhosphorIconsRegular.navigationArrow,
    ),
    ScreenOption(
      title: '18. Trợ lý AI Metro',
      description: 'Trợ lý AI trả lời thắc mắc hành trình, gợi ý nhanh & thẻ phong phú',
      routeName: '/ai-assistant',
      icon: PhosphorIconsRegular.robot,
    ),
    ScreenOption(
      title: '19. Trung tâm thông báo',
      description: 'Phân loại thông báo, chấm chưa đọc, vuốt xóa & lọc danh mục',
      routeName: '/notifications',
      icon: PhosphorIconsRegular.bellSimple,
    ),
    ScreenOption(
      title: '20. Tin tức & Cập nhật Metro',
      description: 'Tin nổi bật, thông báo vận hành & cẩm nang đi lại',
      routeName: '/news',
      icon: PhosphorIconsRegular.newspaper,
    ),
    ScreenOption(
      title: '21. Chi tiết bài viết tin tức',
      description: 'Ảnh bìa lớn, nội dung chi tiết, lời khuyên hành khách & chia sẻ',
      routeName: '/article-detail',
      icon: PhosphorIconsRegular.article,
    ),
  ];

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ScreenSwitcherSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xl),
          topRight: Radius.circular(AppRadius.xl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.xs),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const PhosphorIcon(
                    PhosphorIconsRegular.squaresFour,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Điều hướng màn hình MetroGo',
                        style: AppTypography.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Truy cập nhanh tất cả màn hình ứng dụng',
                        style: AppTypography.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const PhosphorIcon(
                    PhosphorIconsRegular.x,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: screens.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.xs),
              itemBuilder: (context, index) {
                final item = screens[index];
                return MetroCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm + 2,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamed(item.routeName);
                  },
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: PhosphorIcon(
                          item.icon,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style:
                                  AppTypography.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              item.description,
                              style: AppTypography.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const PhosphorIcon(
                        PhosphorIconsRegular.caretRight,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Floating Screen Switcher trigger button to review UI anywhere
class ScreenSwitcherButton extends StatelessWidget {
  const ScreenSwitcherButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      heroTag: 'screen_switcher_fab_${context.hashCode}',
      backgroundColor: AppColors.surface,
      elevation: 2,
      onPressed: () => ScreenSwitcherSheet.show(context),
      tooltip: 'Chuyển màn hình',
      child: const PhosphorIcon(
        PhosphorIconsRegular.squaresFour,
        color: AppColors.primary,
        size: 18,
      ),
    );
  }
}
