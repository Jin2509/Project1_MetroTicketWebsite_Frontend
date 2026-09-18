import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../theme/app_theme.dart';
import '../../widgets/metro_card.dart';
import '../../widgets/screen_switcher_sheet.dart';

/// Minimalist Settings Screen
/// Giữ lại các chức năng thiết yếu nhất cho người dùng:
/// 1. Thông tin cá nhân & Tài khoản (Alex Nguyễn)
/// 2. Cài đặt ứng dụng: Thông báo, Ngôn ngữ, Giao diện tối
/// 3. Hỗ trợ & Quy định: Tổng đài hỗ trợ 24/7, Quy tắc an toàn & bảo mật
/// 4. Đăng xuất tài khoản
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _pushNotifications = true;
  String _selectedLanguage = 'Tiếng Việt';

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          'Chọn ngôn ngữ',
          style: AppTypography.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        children: [
          ListTile(
            leading: const PhosphorIcon(PhosphorIconsRegular.globe),
            title: const Text('Tiếng Việt', style: TextStyle(fontWeight: FontWeight.w600)),
            trailing: _selectedLanguage == 'Tiếng Việt'
                ? const PhosphorIcon(PhosphorIconsFill.checkCircle, color: AppColors.primary)
                : null,
            onTap: () {
              setState(() => _selectedLanguage = 'Tiếng Việt');
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: const PhosphorIcon(PhosphorIconsRegular.globe),
            title: const Text('English (US)', style: TextStyle(fontWeight: FontWeight.w600)),
            trailing: _selectedLanguage == 'English'
                ? const PhosphorIcon(PhosphorIconsFill.checkCircle, color: AppColors.primary)
                : null,
            onTap: () {
              setState(() => _selectedLanguage = 'English');
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showThemeInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Row(
          children: const [
            PhosphorIcon(
              PhosphorIconsRegular.moonStars,
              color: AppColors.primary,
              size: 22,
            ),
            SizedBox(width: AppSpacing.xs),
            Text('Giao diện MetroGo'),
          ],
        ),
        content: const Text(
          'Ứng dụng đang sử dụng phong cách giao diện tối Proton Dark với nền bản đồ Việt Nam nét trắng sắc nét, đồng bộ cho tất cả màn hình.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Hỗ trợ hành khách MetroGo',
              style: AppTypography.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Bộ phận Chăm sóc Hành khách Đường sắt Đô thị TP.HCM phục vụ 24/7:',
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            MetroCard(
              backgroundColor: AppColors.surfaceSecondary,
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const PhosphorIcon(
                      PhosphorIconsFill.phoneCall,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tổng đài Hotline',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '1900 1234',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      Clipboard.setData(const ClipboardData(text: '19001234'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã sao chép số tổng đài: 1900 1234'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Text('Sao chép'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            MetroCard(
              backgroundColor: AppColors.surfaceSecondary,
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const PhosphorIcon(
                      PhosphorIconsFill.envelopeSimple,
                      color: AppColors.success,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Email hỗ trợ',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'hotro@metrogo.hcmc.vn',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  void _showSafetyTermsDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Điều khoản & An toàn Metro',
              style: AppTypography.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '1. Luôn đứng sau vạch vàng an toàn khi đợi tàu.\n'
              '2. Giữ vé / mã QR trên ứng dụng từ khi vào cổng đến khi ra khỏi ga đích.\n'
              '3. Không mang chất dễ cháy nổ, vũ khí hoặc hành lý cồng kềnh lên tàu.\n'
              '4. Dữ liệu cá nhân và hành trình đi tàu được bảo vệ theo Luật An toàn thông tin mạng.',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                height: 1.6,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Tôi đã hiểu & đồng ý',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
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
          'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản MetroGo trên thiết bị này?',
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
              style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    'Cài đặt',
                    style: AppTypography.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const ScreenSwitcherButton(),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // 1. User Info Card (Minimalist)
              MetroCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    // Circular Avatar
                    Container(
                      width: 58,
                      height: 58,
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
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: PhosphorIcon(
                          PhosphorIconsRegular.user,
                          size: 28,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(width: AppSpacing.md),

                    // User Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'Alex Nguyễn',
                                  style: AppTypography.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                ),
                                child: const Text(
                                  'XÁC THỰC',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '+84 987 654 321',
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Edit Profile Button
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/edit-profile');
                      },
                      icon: const PhosphorIcon(
                        PhosphorIconsRegular.pencilSimple,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // 2. Section: Thiết lập ứng dụng
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.sm),
                child: Text(
                  'HỆ THỐNG',
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              MetroCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    // Thông báo Switch
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: const PhosphorIcon(
                          PhosphorIconsRegular.bellSimple,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      title: const Text(
                        'Thông báo chuyến tàu',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      subtitle: const Text(
                        'Nhắc giờ tàu chạy, thông báo sự cố',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      trailing: Switch.adaptive(
                        value: _pushNotifications,
                        activeTrackColor: AppColors.primary,
                        onChanged: (val) {
                          setState(() => _pushNotifications = val);
                        },
                      ),
                    ),

                    const Divider(height: 1, indent: 56),

                    // Ngôn ngữ
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: const PhosphorIcon(
                          PhosphorIconsRegular.translate,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      title: const Text(
                        'Ngôn ngữ (Language)',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedLanguage,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const PhosphorIcon(
                            PhosphorIconsRegular.caretRight,
                            size: 16,
                            color: AppColors.textMuted,
                          ),
                        ],
                      ),
                      onTap: _showLanguageDialog,
                    ),

                    const Divider(height: 1, indent: 56),

                    // Giao diện (Theme)
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: const PhosphorIcon(
                          PhosphorIconsRegular.palette,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      title: const Text(
                        'Chế độ giao diện',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      subtitle: const Text(
                        'Proton Dark (Bản đồ nét trắng)',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      trailing: const PhosphorIcon(
                        PhosphorIconsRegular.caretRight,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                      onTap: _showThemeInfoDialog,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // 3. Section: Hỗ trợ & Pháp lý
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.sm),
                child: Text(
                  'HỖ TRỢ & QUY ĐỊNH',
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              MetroCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    // Hotline & Trợ giúp
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: const PhosphorIcon(
                          PhosphorIconsRegular.phoneCall,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      title: const Text(
                        'Hỗ trợ & Hotline 24/7',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      subtitle: const Text(
                        '1900 1234 (Tổng đài Đường sắt)',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      trailing: const PhosphorIcon(
                        PhosphorIconsRegular.caretRight,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                      onTap: _showSupportDialog,
                    ),

                    const Divider(height: 1, indent: 56),

                    // Quy định an toàn & Điều khoản
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: const PhosphorIcon(
                          PhosphorIconsRegular.shieldCheck,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      title: const Text(
                        'Điều khoản & An toàn Metro',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      subtitle: const Text(
                        'Quy tắc an toàn hành khách & Bảo mật',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      trailing: const PhosphorIcon(
                        PhosphorIconsRegular.caretRight,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                      onTap: _showSafetyTermsDialog,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // 4. Section: Đăng xuất
              MetroCard(
                padding: EdgeInsets.zero,
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const PhosphorIcon(
                      PhosphorIconsRegular.signOut,
                      size: 18,
                      color: AppColors.error,
                    ),
                  ),
                  title: const Text(
                    'Đăng xuất',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.error,
                    ),
                  ),
                  subtitle: const Text(
                    'Đăng xuất khỏi thiết bị này',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  trailing: const PhosphorIcon(
                    PhosphorIconsRegular.caretRight,
                    size: 16,
                    color: AppColors.error,
                  ),
                  onTap: _showLogoutDialog,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // App Version footer
              Center(
                child: Text(
                  'MetroGo phiên bản 2.4.0 (Build 2026.10)',
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
