import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/ticket_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/metro_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/screen_switcher_sheet.dart';
import '../../widgets/secondary_button.dart';

/// Screen: Payment Success Screen
/// Green circular checkmark, "Payment successful" message,
/// LARGE QR CODE centered on screen (via qr_flutter), ticket info below,
/// and two buttons: "View my tickets" and "Back to home".
class PaymentSuccessScreen extends StatelessWidget {
  final Ticket ticket;

  const PaymentSuccessScreen({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.sm),

                  // 1. GREEN CIRCULAR CHECKMARK
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.25),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.success.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: PhosphorIcon(
                        PhosphorIconsRegular.checkCircle,
                        size: 40,
                        color: AppColors.success,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // 2. SUCCESS HEADLINE
                  Text(
                    'Thanh toán thành công!',
                    style: AppTypography.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Vé điện tử của bạn đã kích hoạt và sẵn sàng quét tại cổng',
                    textAlign: TextAlign.center,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // 3. LARGE QR CODE CENTERED CARD
                  MetroCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    borderRadius: AppRadius.lg,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Turnstile Banner
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              PhosphorIcon(
                                PhosphorIconsRegular.scan,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'VÉ QUÉT CỔNG SOÁT VÉ',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // Large Centered QR Code via qr_flutter
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            border: Border.all(color: AppColors.borderSubtle),
                            boxShadow: AppShadows.subtle,
                          ),
                          child: QrImageView(
                            data: ticket.qrCodeData,
                            version: QrVersions.auto,
                            size: 190.0,
                            padding: EdgeInsets.zero,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.md),

                        Text(
                          'Đặt mã cách mắt đọc quét quang học 5–10 cm',
                          textAlign: TextAlign.center,
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // 4. TICKET INFO CARD BELOW
                  MetroCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        _infoRow('Mã vé', ticket.id, isHighlighted: true),
                        const Divider(height: 16),
                        _infoRow('Loại vé', ticket.type.displayName),
                        const Divider(height: 16),
                        _infoRow(
                          'Phạm vi / Lộ trình',
                          (ticket.originStation != null &&
                                  ticket.destinationStation != null)
                              ? '${ticket.originStation} ⇄ ${ticket.destinationStation}'
                              : 'Toàn mạng lưới tuyến',
                        ),
                        const Divider(height: 16),
                        _infoRow('Thời hạn', ticket.validityText),
                        const Divider(height: 16),
                        _infoRow('Tổng tiền đã trả', ticket.formattedPrice),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // 5. DUAL ACTION BUTTONS
                  PrimaryButton(
                    text: 'Xem vé của tôi',
                    trailingIcon: PhosphorIconsRegular.ticket,
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/main',
                        (route) => false,
                        arguments: 2, // Switch to My Tickets tab
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  SecondaryButton(
                    text: 'Về trang chủ',
                    leadingIcon: PhosphorIconsRegular.house,
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/main',
                        (route) => false,
                        arguments: 0, // Switch to Home tab
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),

            // Top screen switcher button
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

  Widget _infoRow(String label, String value, {bool isHighlighted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w600,
            color: isHighlighted ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
