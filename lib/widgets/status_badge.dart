import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../theme/app_theme.dart';

enum TicketStatus {
  paid,
  pending,
  used,
  expired;

  String get label {
    switch (this) {
      case TicketStatus.paid:
        return 'Đã thanh toán';
      case TicketStatus.pending:
        return 'Chờ thanh toán';
      case TicketStatus.used:
        return 'Đã sử dụng';
      case TicketStatus.expired:
        return 'Hết hạn';
    }
  }

  Color get backgroundColor {
    switch (this) {
      case TicketStatus.paid:
        return AppColors.ticketPaidBg;
      case TicketStatus.pending:
        return AppColors.ticketPendingBg;
      case TicketStatus.used:
        return AppColors.ticketUsedBg;
      case TicketStatus.expired:
        return AppColors.ticketExpiredBg;
    }
  }

  Color get textColor {
    switch (this) {
      case TicketStatus.paid:
        return AppColors.ticketPaidText;
      case TicketStatus.pending:
        return AppColors.ticketPendingText;
      case TicketStatus.used:
        return AppColors.ticketUsedText;
      case TicketStatus.expired:
        return AppColors.ticketExpiredText;
    }
  }

  Color get dotColor {
    switch (this) {
      case TicketStatus.paid:
        return AppColors.ticketPaid;
      case TicketStatus.pending:
        return AppColors.ticketPending;
      case TicketStatus.used:
        return AppColors.ticketUsed;
      case TicketStatus.expired:
        return AppColors.ticketExpired;
    }
  }

  PhosphorIconData get icon {
    switch (this) {
      case TicketStatus.paid:
        return PhosphorIconsRegular.checkCircle;
      case TicketStatus.pending:
        return PhosphorIconsRegular.clockCountdown;
      case TicketStatus.used:
        return PhosphorIconsRegular.ticket;
      case TicketStatus.expired:
        return PhosphorIconsRegular.warningCircle;
    }
  }
}

/// StatusBadge:
/// Displays ticket status (Paid / Pending / Used / Expired)
/// in a harmonious rounded pill matching the MetroGo theme.
class StatusBadge extends StatelessWidget {
  final TicketStatus status;
  final String? customLabel;
  final bool showIcon;
  final bool showDot;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  const StatusBadge({
    super.key,
    required this.status,
    this.customLabel,
    this.showIcon = false,
    this.showDot = true,
    this.fontSize = 12.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xxs + 1,
          ),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: status.dotColor.withValues(alpha: 0.22),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showIcon) ...[
            PhosphorIcon(
              status.icon,
              size: fontSize + 2,
              color: status.textColor,
            ),
            const SizedBox(width: AppSpacing.xxs + 1),
          ] else if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: status.dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.xs - 2),
          ],
          Text(
            customLabel ?? status.label,
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: status.textColor,
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
