import 'dart:math';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../models/ticket_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/metro_app_bar.dart';
import '../../widgets/metro_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/screen_switcher_sheet.dart';
import '../../widgets/status_badge.dart';

enum PaymentMethodType {
  zalopay,
  momo,
  vnpay,
  creditCard;

  String get title {
    switch (this) {
      case PaymentMethodType.zalopay:
        return 'Ví điện tử ZaloPay';
      case PaymentMethodType.momo:
        return 'Ví điện tử MoMo';
      case PaymentMethodType.vnpay:
        return 'VNPay / Chuyển khoản ngân hàng';
      case PaymentMethodType.creditCard:
        return 'Thẻ quốc tế / Thẻ nội địa';
    }
  }

  String get subtitle {
    switch (this) {
      case PaymentMethodType.zalopay:
        return 'Thanh toán 1 chạm nhanh chóng qua ZaloPay';
      case PaymentMethodType.momo:
        return 'Xác thực sinh trắc học nhanh và an toàn';
      case PaymentMethodType.vnpay:
        return 'Quét mã QR qua hơn 40 ứng dụng ngân hàng';
      case PaymentMethodType.creditCard:
        return 'Hỗ trợ thẻ Visa, Mastercard, JCB & ATM nội địa';
    }
  }

  Color get brandColor {
    switch (this) {
      case PaymentMethodType.zalopay:
        return const Color(0xFF0068FF);
      case PaymentMethodType.momo:
        return const Color(0xFFA50064);
      case PaymentMethodType.vnpay:
        return const Color(0xFFE31837);
      case PaymentMethodType.creditCard:
        return AppColors.primary;
    }
  }

  PhosphorIconData get icon {
    switch (this) {
      case PaymentMethodType.zalopay:
        return PhosphorIconsRegular.wallet;
      case PaymentMethodType.momo:
        return PhosphorIconsRegular.deviceMobile;
      case PaymentMethodType.vnpay:
        return PhosphorIconsRegular.qrCode;
      case PaymentMethodType.creditCard:
        return PhosphorIconsRegular.creditCard;
    }
  }
}

/// Screen: Payment Screen
/// Order summary card, payment method radio-cards (ZaloPay, MoMo, VNPay, Bank Card),
/// pinned "Confirm Payment" button.
class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> bookingData;

  const PaymentScreen({super.key, required this.bookingData});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethodType _selectedPayment = PaymentMethodType.zalopay;
  bool _isProcessing = false;

  String _formatVnd(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }
    return '${buffer.toString().split('').reversed.join('')} đ';
  }

  void _confirmPayment() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 1100));

    if (!mounted) return;

    // Generate unique Ticket ID
    final randomId = 'MG-L1-2026-${Random().nextInt(8999) + 1000}';
    final ticketType = widget.bookingData['ticketType'] as TicketType;
    final title = widget.bookingData['title'] as String;
    final origin = widget.bookingData['origin'] as String?;
    final destination = widget.bookingData['destination'] as String?;
    final validity = widget.bookingData['validity'] as String;
    final totalPrice = widget.bookingData['totalPrice'] as int;
    final quantity = widget.bookingData['quantity'] as int;

    final newTicket = Ticket(
      id: randomId,
      title: title,
      type: ticketType,
      originStation: origin,
      destinationStation: destination,
      validityText: validity,
      status: TicketStatus.paid,
      priceVnd: totalPrice,
      purchaseDate: DateTime.now(),
      quantity: quantity,
      qrCodeData: 'METROGO:TICKET:$randomId:${ticketType.name.toUpperCase()}:$totalPrice',
      passengerName: 'Alex Nguyen',
    );

    // Save into global TicketStore
    TicketStore.instance.addTicket(newTicket);

    setState(() => _isProcessing = false);

    Navigator.of(context).pushReplacementNamed(
      '/payment-success',
      arguments: newTicket,
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.bookingData['title'] as String? ?? 'Vé lượt Metro';
    final quantity = widget.bookingData['quantity'] as int? ?? 1;
    final totalPrice = widget.bookingData['totalPrice'] as int? ?? 15000;
    final validity = widget.bookingData['validity'] as String? ?? 'Hiệu lực 4 giờ';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MetroAppBar(
        title: 'Thanh toán',
        actions: const [
          ScreenSwitcherButton(),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ORDER SUMMARY CARD
                    Text(
                      'THÔNG TIN ĐƠN HÀNG',
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    MetroCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                ),
                                child: const PhosphorIcon(
                                  PhosphorIconsRegular.ticket,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: AppTypography.textTheme.titleSmall
                                          ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      validity,
                                      style: AppTypography.textTheme.bodySmall
                                          ?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            child: Divider(height: 1),
                          ),
                          // Line items
                          _summaryRow('Số lượng', '$quantity vé'),
                          const SizedBox(height: AppSpacing.xs),
                          _summaryRow('Phí tiện ích', '0 đ (Miễn phí)'),
                          const SizedBox(height: AppSpacing.xs),
                          _summaryRow('Thuế GTGT (VAT 8%)', 'Đã bao gồm'),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: AppSpacing.sm,
                            ),
                            child: Divider(height: 1),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tổng thanh toán',
                                style: AppTypography.textTheme.titleMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                _formatVnd(totalPrice),
                                style: AppTypography.textTheme.titleLarge
                                    ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // PAYMENT METHOD RADIO-CARDS
                    Text(
                      'PHƯƠNG THỨC THANH TOÁN',
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    Column(
                      children: PaymentMethodType.values.map((method) {
                        final isSelected = _selectedPayment == method;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: MetroCard(
                            onTap: () =>
                                setState(() => _selectedPayment = method),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.borderSubtle,
                              width: isSelected ? 1.6 : 1.0,
                            ),
                            backgroundColor: isSelected
                                ? AppColors.primarySubtle
                                : AppColors.surface,
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Row(
                              children: [
                                // Brand Icon
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: method.brandColor
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(AppRadius.md),
                                  ),
                                  child: Center(
                                    child: PhosphorIcon(
                                      method.icon,
                                      size: 22,
                                      color: method.brandColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        method.title,
                                        style: AppTypography
                                            .textTheme.labelLarge
                                            ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        method.subtitle,
                                        style: AppTypography
                                            .textTheme.bodySmall
                                            ?.copyWith(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                // Custom Radio Indicator
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.border,
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Center(
                                          child: PhosphorIcon(
                                            PhosphorIconsRegular.check,
                                            size: 13,
                                            color: Colors.white,
                                          ),
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),

            // PINNED BOTTOM BUTTON
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: const Border(
                  top: BorderSide(color: AppColors.borderSubtle, width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A1D29).withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: PrimaryButton(
                  text: 'Xác nhận thanh toán • ${_formatVnd(totalPrice)}',
                  isLoading: _isProcessing,
                  trailingIcon: PhosphorIconsRegular.shieldCheck,
                  onPressed: _confirmPayment,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
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
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
