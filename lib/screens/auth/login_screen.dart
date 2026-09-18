import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../theme/app_theme.dart';
import '../../widgets/metro_card.dart';
import '../../widgets/metro_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/screen_switcher_sheet.dart';
import '../../widgets/secondary_button.dart';

/// Screen: Modern Metro Login Screen
/// Light Pastel Orange & White Theme
/// Supports Phone (+84 / OTP), Google, and Facebook sign-in.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController(text: '0987 654 321');
  final _passwordController = TextEditingController(text: 'metro@2026');
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _socialLoadingProvider;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handlePhoneLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 750));
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.of(context).pushReplacementNamed('/main');
      }
    }
  }

  void _handleSocialLogin(String provider) async {
    setState(() => _socialLoadingProvider = provider);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _socialLoadingProvider = null);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đăng nhập thành công qua $provider! Chào mừng đến MetroGo.'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).pushReplacementNamed('/main');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.lg),

                    // 1. BRAND HERO HEADER
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(AppRadius.xl),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.18),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: PhosphorIcon(
                                PhosphorIconsBold.train,
                                size: 34,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          RichText(
                            text: TextSpan(
                              style: AppTypography.textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                              children: const [
                                TextSpan(text: 'Metro'),
                                TextSpan(
                                  text: 'Go',
                                  style: TextStyle(color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'ĐƯỜNG SẮT ĐÔ THỊ TP. HỒ CHÍ MINH',
                            style: AppTypography.textTheme.labelSmall?.copyWith(
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Đăng nhập để đặt vé, thanh toán và quản lý hành trình',
                            textAlign: TextAlign.center,
                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // 2. PHONE NUMBER INPUT
                    Text(
                      'Số điện thoại',
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // National Code Box (+84 🇻🇳)
                        Container(
                          height: 52,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Text('🇻🇳', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 4),
                              Text(
                                '+84',
                                style: AppTypography.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: 'Nhập số điện thoại của bạn',
                              prefixIcon: const PhosphorIcon(
                                PhosphorIconsRegular.deviceMobile,
                                size: 18,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: 14,
                              ),
                              fillColor: AppColors.surface,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Vui lòng nhập số điện thoại';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // 3. PASSWORD INPUT
                    MetroTextField(
                      label: 'Mật khẩu',
                      hintText: 'Nhập mật khẩu của bạn',
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      prefixIcon: PhosphorIconsRegular.lock,
                      suffixIcon: IconButton(
                        icon: PhosphorIcon(
                          _obscurePassword
                              ? PhosphorIconsRegular.eyeSlash
                              : PhosphorIconsRegular.eye,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      validator: (val) {
                        if (val == null || val.length < 6) {
                          return 'Mật khẩu phải có ít nhất 6 ký tự';
                        }
                        return null;
                      },
                    ),

                    // Forgot Password / OTP Switcher Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              '/otp',
                              arguments: _phoneController.text.trim().isNotEmpty
                                  ? _phoneController.text.trim()
                                  : '+84 987 654 321',
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Đăng nhập bằng mã OTP qua SMS',
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã gửi mã khôi phục mật khẩu về số điện thoại của bạn.'),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Quên mật khẩu?',
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // 4. PHONE LOGIN PRIMARY BUTTON
                    PrimaryButton(
                      text: 'Đăng nhập với Số điện thoại',
                      isLoading: _isLoading,
                      leadingIcon: PhosphorIconsBold.signIn,
                      onPressed: _handlePhoneLogin,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // 5. SOCIAL DIVIDER
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          child: Text(
                            'HOẶC TIẾP TỤC VỚI',
                            style: AppTypography.textTheme.labelSmall?.copyWith(
                              color: AppColors.textMuted,
                              letterSpacing: 0.8,
                              fontWeight: FontWeight.w700,
                              fontSize: 10.5,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // 6. SOCIAL BUTTONS: GOOGLE & FACEBOOK
                    Row(
                      children: [
                        // GOOGLE BUTTON
                        Expanded(
                          child: MetroCard(
                            onTap: _socialLoadingProvider != null
                                ? null
                                : () => _handleSocialLogin('Google'),
                            backgroundColor: AppColors.surface,
                            borderRadius: AppRadius.md,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            border: Border.all(color: AppColors.border),
                            child: _socialLoadingProvider == 'Google'
                                ? const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildGoogleBrandIcon(),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Google',
                                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        // FACEBOOK BUTTON
                        Expanded(
                          child: MetroCard(
                            onTap: _socialLoadingProvider != null
                                ? null
                                : () => _handleSocialLogin('Facebook'),
                            backgroundColor: AppColors.surface,
                            borderRadius: AppRadius.md,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            border: Border.all(color: AppColors.border),
                            child: _socialLoadingProvider == 'Facebook'
                                ? const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF1877F2),
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildFacebookBrandIcon(),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Facebook',
                                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // 7. GUEST / EXPLORE NOW BUTTON
                    SecondaryButton(
                      text: 'Khám phá ngay (Không cần đăng nhập)',
                      leadingIcon: PhosphorIconsRegular.compass,
                      textColor: AppColors.primary,
                      borderColor: AppColors.primary.withValues(alpha: 0.3),
                      backgroundColor: AppColors.primaryLight.withValues(alpha: 0.4),
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/main');
                      },
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // 8. SIGN UP FOOTER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Chưa có tài khoản? ',
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed('/signup');
                          },
                          child: Text(
                            'Đăng ký ngay',
                            style: AppTypography.textTheme.labelMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ),

            // Top screen switcher helper
            const Positioned(
              top: 8,
              right: AppSpacing.md,
              child: ScreenSwitcherButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleBrandIcon() {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'G',
          style: TextStyle(
            color: Color(0xFF4285F4),
            fontSize: 14,
            fontWeight: FontWeight.w900,
            fontFamily: 'Roboto',
          ),
        ),
      ),
    );
  }

  Widget _buildFacebookBrandIcon() {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        color: Color(0xFF1877F2),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          'f',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w900,
            fontFamily: 'Roboto',
          ),
        ),
      ),
    );
  }
}
