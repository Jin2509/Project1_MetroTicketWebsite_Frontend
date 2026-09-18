import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/ticket_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/confetti_overlay.dart';
import '../../widgets/metro_app_bar.dart';
import '../../widgets/metro_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/screen_switcher_sheet.dart';
import '../../widgets/secondary_button.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/vietnam_map_background.dart';

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
/// QR Payment modal, celebration effects with confetti, pinned "Confirm Payment" button.
class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> bookingData;

  const PaymentScreen({super.key, required this.bookingData});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethodType _selectedPayment = PaymentMethodType.zalopay;
  bool _isProcessing = false;
  bool _isCelebrating = false;
  late final String _orderCode;

  @override
  void initState() {
    super.initState();
    _orderCode = 'METRO${Random().nextInt(89999) + 10000}';
  }

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

  void _showPaymentQrModal(BuildContext context, int totalPrice, String title) {
    // Generate VietQR or Partner QR data string
    final qrData = '00020101021238540010A000000727012600069704220112982348123840208QRIBFTTA520460115303704540$totalPrice'
        '5802VN62240820$_orderCode'
        '6304';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
          ),
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.md,
            bottom: MediaQuery.of(modalContext).viewInsets.bottom + AppSpacing.xl,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Title & Subtitle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quét mã QR thanh toán',
                            style: AppTypography.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Sử dụng ứng dụng ${_selectedPayment.title}',
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const PhosphorIcon(
                        PhosphorIconsRegular.x,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => Navigator.pop(modalContext),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // QR Code Container
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(color: AppColors.borderSubtle, width: 1.5),
                    boxShadow: AppShadows.subtle,
                  ),
                  child: Column(
                    children: [
                      // Partner Tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _selectedPayment.brandColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PhosphorIcon(
                              _selectedPayment.icon,
                              size: 14,
                              color: _selectedPayment.brandColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _selectedPayment.title,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _selectedPayment.brandColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      // Large QR Code
                      QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 190.0,
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Quét mã để thanh toán đúng ${_formatVnd(totalPrice)}',
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (widget.bookingData['hasParking'] == true) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const PhosphorIcon(PhosphorIconsBold.car, size: 13, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Text(
                                'Mã QR thanh toán vé tàu + giữ xe Ga ${widget.bookingData['parkingStation'] ?? ""}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Transfer Details Card
                MetroCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      _qrDetailRow('Đơn vị thụ hưởng', 'HURC1 - ĐƯỜNG SẮT ĐÔ THỊ TPHCM'),
                      const Divider(height: 14),
                      _qrDetailRow(
                        'Số tài khoản / Mã ví',
                        '9823 4812 3840',
                        canCopy: true,
                        onCopy: () {
                          Clipboard.setData(const ClipboardData(text: '982348123840'));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã sao chép số tài khoản'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 14),
                      _qrDetailRow(
                        'Nội dung chuyển khoản',
                        _orderCode,
                        canCopy: true,
                        onCopy: () {
                          Clipboard.setData(ClipboardData(text: _orderCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã sao chép nội dung chuyển khoản'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 14),
                      _qrDetailRow(
                        'Số tiền thanh toán',
                        _formatVnd(totalPrice),
                        isBoldHighlight: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Confirm Payment Button
                PrimaryButton(
                  text: 'Tôi đã thanh toán thành công',
                  leadingIcon: PhosphorIconsRegular.checkCircle,
                  onPressed: () {
                    Navigator.pop(modalContext);
                    _handlePaymentSuccess();
                  },
                ),
                const SizedBox(height: AppSpacing.sm),

                SecondaryButton(
                  text: 'Đổi phương thức thanh toán',
                  onPressed: () => Navigator.pop(modalContext),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _qrDetailRow(
    String label,
    String value, {
    bool canCopy = false,
    bool isBoldHighlight = false,
    VoidCallback? onCopy,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    fontWeight: isBoldHighlight ? FontWeight.w800 : FontWeight.w600,
                    color: isBoldHighlight ? AppColors.primary : AppColors.textPrimary,
                    fontSize: isBoldHighlight ? 15 : 13,
                  ),
                ),
              ),
              if (canCopy) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onCopy,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const PhosphorIcon(
                      PhosphorIconsRegular.copy,
                      size: 13,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _handlePaymentSuccess() async {
    setState(() {
      _isCelebrating = true;
      _isProcessing = true;
    });

    // Generate unique Ticket ID
    final randomId = 'MG-L1-2026-${Random().nextInt(8999) + 1000}';
    final ticketType =
        widget.bookingData['ticketType'] as TicketType? ?? TicketType.singleRide;
    final title = widget.bookingData['title'] as String;
    final origin = widget.bookingData['origin'] as String?;
    final destination = widget.bookingData['destination'] as String?;
    final validity = widget.bookingData['validity'] as String;
    final totalPrice = widget.bookingData['totalPrice'] as int;
    final quantity = widget.bookingData['quantity'] as int;

    // Parking reservation info
    final hasParking = widget.bookingData['hasParking'] as bool? ?? false;
    ParkingBooking? parkingBooking;
    if (hasParking) {
      parkingBooking = ParkingBooking(
        station: widget.bookingData['parkingStation'] as String? ?? 'Ga Bến Thành',
        ownerName: widget.bookingData['parkingOwner'] as String? ?? 'Alex Nguyễn',
        licensePlate: widget.bookingData['parkingPlate'] as String? ?? '',
        packageType: widget.bookingData['parkingPackage'] as String? ?? '1 buổi',
        vehicleType: widget.bookingData['parkingVehicle'] as String? ?? 'Xe máy',
        price: widget.bookingData['parkingFee'] as int? ?? 5000,
      );
    }

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
      passengerName: hasParking
          ? (widget.bookingData['parkingOwner'] as String? ?? 'Alex Nguyễn')
          : 'Alex Nguyễn',
      parking: parkingBooking,
    );

    // Save into global TicketStore
    TicketStore.instance.addTicket(newTicket);

    // Keep celebration visible with confetti shower for 1.8 seconds
    await Future.delayed(const Duration(milliseconds: 1800));

    if (!mounted) return;
    setState(() {
      _isCelebrating = false;
      _isProcessing = false;
    });

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
    final hasParking = widget.bookingData['hasParking'] as bool? ?? false;
    final parkingStation = widget.bookingData['parkingStation'] as String? ?? '';
    final parkingOwner = widget.bookingData['parkingOwner'] as String? ?? '';
    final parkingPlate = widget.bookingData['parkingPlate'] as String? ?? '';
    final parkingVehicle = widget.bookingData['parkingVehicle'] as String? ?? 'Xe máy';
    final parkingPackage = widget.bookingData['parkingPackage'] as String? ?? '1 buổi';
    final parkingFee = widget.bookingData['parkingFee'] as int? ?? 0;
    final ticketTotal =
        widget.bookingData['ticketTotal'] as int? ?? (totalPrice - parkingFee);
    final bool isParkingOnly =
        (widget.bookingData['isParkingOnly'] as bool? ?? false) ||
        (ticketTotal == 0 && hasParking);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MetroAppBar(
        title: 'Thanh toán',
        actions: const [
          ScreenSwitcherButton(),
        ],
      ),
      body: ConfettiOverlay(
        isPlaying: _isCelebrating,
        child: VietnamMapBackground(
          opacity: 0.08,
          child: Stack(
            children: [
              SafeArea(
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
                                child: PhosphorIcon(
                                  isParkingOnly
                                      ? PhosphorIconsRegular.car
                                      : PhosphorIconsRegular.ticket,
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
                          if (!isParkingOnly) ...[
                            _summaryRow('Số lượng vé', '$quantity vé'),
                            const SizedBox(height: AppSpacing.xs),
                            _summaryRow('Tiền vé Metro', _formatVnd(ticketTotal)),
                          ],
                          if (hasParking) ...[
                            const SizedBox(height: AppSpacing.xs),
                            _summaryRow(
                              isParkingOnly
                                  ? 'Cước phí giữ xe'
                                  : 'Giữ xe ($parkingVehicle - $parkingPackage)',
                              _formatVnd(parkingFee),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                              ),
                              child: Row(
                                children: [
                                  PhosphorIcon(
                                    parkingVehicle == 'Ô tô'
                                        ? PhosphorIconsRegular.car
                                        : PhosphorIconsRegular.moped,
                                    size: 14,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Ga $parkingStation • BS: $parkingPlate • Chủ xe: $parkingOwner',
                                      style: AppTypography.textTheme.bodySmall?.copyWith(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
                  trailingIcon: PhosphorIconsRegular.qrCode,
                  onPressed: () => _showPaymentQrModal(context, totalPrice, title),
                ),
              ),
            ),
          ],
        ),
      ),
      if (_isCelebrating)
        Positioned.fill(
          child: Container(
            color: Colors.black.withValues(alpha: 0.45),
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.75, end: 1.0),
                duration: const Duration(milliseconds: 350),
                curve: Curves.elasticOut,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withValues(alpha: 0.25),
                        blurRadius: 28,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: const Center(
                          child: PhosphorIcon(
                            PhosphorIconsBold.check,
                            size: 38,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Thanh toán thành công!',
                        style: AppTypography.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Hệ thống đã nhận thanh toán.\nĐang phát hành mã QR vé cho bạn...',
                        textAlign: TextAlign.center,
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
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
