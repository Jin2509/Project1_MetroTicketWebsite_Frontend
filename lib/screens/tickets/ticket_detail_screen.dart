import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/ticket_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/metro_app_bar.dart';
import '../../widgets/metro_card.dart';
import '../../widgets/screen_switcher_sheet.dart';
import '../../widgets/secondary_button.dart';
import '../../widgets/status_badge.dart';

/// Screen: Ticket Detail Screen
/// Large centered QR code, full ticket info table, status badge,
/// and Download/Share action buttons.
class TicketDetailScreen extends StatelessWidget {
  final Ticket ticket;

  const TicketDetailScreen({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MetroAppBar(
        title: 'Chi tiết vé',
        actions: const [
          ScreenSwitcherButton(),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. LARGE CENTERED QR CODE CARD
              MetroCard(
                padding: const EdgeInsets.all(AppSpacing.xl),
                borderRadius: AppRadius.xl,
                child: Column(
                  children: [
                    // Status Badge & Pass type
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          ticket.type.displayName.toUpperCase(),
                          style: AppTypography.textTheme.labelMedium?.copyWith(
                            color: AppColors.primary,
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        StatusBadge(status: ticket.status),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Large QR Code
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        border: Border.all(
                          color: AppColors.border,
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: ticket.qrCodeData,
                        version: QrVersions.auto,
                        size: 210.0,
                        padding: EdgeInsets.zero,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Ticket ID & Scan Hint
                    Text(
                      ticket.id,
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        PhosphorIcon(
                          PhosphorIconsRegular.sun,
                          size: 14,
                          color: AppColors.warningText,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Độ sáng màn hình tự động tăng để quét tại cổng',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // 2. FULL TICKET INFO TABLE
              MetroCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'THÔNG TIN VÉ',
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _tableRow(
                      'Tuyến / Lộ trình',
                      (ticket.originStation != null &&
                              ticket.destinationStation != null)
                          ? '${ticket.originStation} ⇄ ${ticket.destinationStation}'
                          : 'Toàn mạng lưới tuyến',
                    ),
                    const Divider(height: 20),
                    _tableRow('Thời hạn sử dụng', ticket.validityText),
                    const Divider(height: 20),
                    _tableRow('Loại vé', ticket.title),
                    const Divider(height: 20),
                    _tableRow('Tên hành khách', ticket.passengerName),
                    const Divider(height: 20),
                    _tableRow('Mã tuyến', ticket.lineCode),
                    const Divider(height: 20),
                    _tableRow('Giá vé', ticket.formattedPrice),
                    const Divider(height: 20),
                    _tableRow('Quy định qua cổng', '1 lần chạm vào, 1 lần chạm ra'),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // 3. ACTION BUTTONS: Download & Share
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      text: 'Tải vé về máy',
                      leadingIcon: PhosphorIconsRegular.downloadSimple,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã lưu vé vào thiết bị.'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: SecondaryButton(
                      text: 'Chia sẻ vé',
                      leadingIcon: PhosphorIconsRegular.shareNetwork,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đang chia sẻ mã vé QR...'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tableRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
