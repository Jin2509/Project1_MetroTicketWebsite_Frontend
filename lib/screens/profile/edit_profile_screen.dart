import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../theme/app_theme.dart';
import '../../widgets/metro_app_bar.dart';
import '../../widgets/metro_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/screen_switcher_sheet.dart';

/// Screen 7: Edit Profile Screen
/// Form for name, date of birth, gender segmented selector, email (read-only), phone (read-only),
/// and "Save Changes" action.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _dobController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  String _selectedGender = 'Nam';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Alex Nguyễn');
    _dobController = TextEditingController(text: '14 / 08 / 1996');
    _emailController = TextEditingController(text: 'alex.nguyen@example.com');
    _phoneController = TextEditingController(text: '+84 987 654 321');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1996, 8, 14),
      firstDate: DateTime(1940),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final day = picked.day.toString().padLeft(2, '0');
      final month = picked.month.toString().padLeft(2, '0');
      final year = picked.year.toString();
      setState(() {
        _dobController.text = '$day / $month / $year';
      });
    }
  }

  void _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSaving = true);
      await Future.delayed(const Duration(milliseconds: 900));
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật thông tin thành công!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const MetroAppBar(
        title: 'Chỉnh sửa hồ sơ',
        actions: [
          ScreenSwitcherButton(),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar with Camera / Edit button
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary,
                              Color(0xFF6797F7),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.24),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: PhosphorIcon(
                            PhosphorIconsRegular.user,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Chọn ảnh từ thư viện hoặc chụp ảnh mới'),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.surface,
                                width: 2.5,
                              ),
                              boxShadow: AppShadows.subtle,
                            ),
                            child: const PhosphorIcon(
                              PhosphorIconsRegular.camera,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Name field (editable)
                MetroTextField(
                  label: 'Họ và tên',
                  hintText: 'Nhập họ và tên của bạn',
                  controller: _nameController,
                  prefixIcon: PhosphorIconsRegular.user,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Vui lòng nhập họ và tên';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.lg),

                // Date of Birth (interactive date picker)
                MetroTextField(
                  label: 'Ngày sinh',
                  hintText: 'Ngày / Tháng / Năm',
                  controller: _dobController,
                  readOnly: true,
                  onTap: _selectDate,
                  prefixIcon: PhosphorIconsRegular.calendarBlank,
                  suffixIcon: IconButton(
                    icon: const PhosphorIcon(
                      PhosphorIconsRegular.caretDown,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: _selectDate,
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Gender selector (Segmented pill buttons)
                Text(
                  'Giới tính',
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: ['Nam', 'Nữ', 'Khác'].map((gender) {
                    final isSelected = _selectedGender == gender;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: InkWell(
                          onTap: () {
                            setState(() => _selectedGender = gender);
                          },
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryLight
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                gender,
                                style: AppTypography.textTheme.labelMedium
                                    ?.copyWith(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Email field (read-only with verified indicator)
                MetroTextField(
                  label: 'Địa chỉ Email (Đã xác thực)',
                  hintText: 'email@domain.com',
                  controller: _emailController,
                  readOnly: true,
                  prefixIcon: PhosphorIconsRegular.envelope,
                  suffixIcon: const Padding(
                    padding: EdgeInsets.all(12),
                    child: PhosphorIcon(
                      PhosphorIconsRegular.lock,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Phone field (read-only with verified indicator)
                MetroTextField(
                  label: 'Số điện thoại (Đã xác thực)',
                  hintText: '+84 ...',
                  controller: _phoneController,
                  readOnly: true,
                  prefixIcon: PhosphorIconsRegular.phone,
                  suffixIcon: const Padding(
                    padding: EdgeInsets.all(12),
                    child: PhosphorIcon(
                      PhosphorIconsRegular.lock,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Save Changes Button
                PrimaryButton(
                  text: 'Lưu thay đổi',
                  isLoading: _isSaving,
                  trailingIcon: PhosphorIconsRegular.check,
                  onPressed: _handleSave,
                ),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
