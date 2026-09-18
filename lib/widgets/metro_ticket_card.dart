import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/ticket_model.dart';
import '../theme/app_theme.dart';
import 'status_badge.dart';

/// MetroTicketCard:
/// The visual centerpiece of the MetroGo ticketing flow.
/// Features a subtle transit-blue gradient with stylized rail lines,
/// authentic ticket stub notches, a dashed perforated divider, and live turnstile QR code.
class MetroTicketCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback? onTap;
  final bool showQrPreview;

  const MetroTicketCard({
    super.key,
    required this.ticket,
    this.onTap,
    this.showQrPreview = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.18),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: const Color(0xFF1A1D29).withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2B67E3),
                  Color(0xFF3B7BF6),
                  Color(0xFF4C8CF8),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Stylized rail lines watermark background
                Positioned.fill(
                  child: CustomPaint(
                    painter: _RailPatternPainter(),
                  ),
                ),

                // Card Content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // TOP SECTION: Header, Route, Validity
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top bar: Branding & Status Badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(AppRadius.md),
                                    ),
                                    child: const PhosphorIcon(
                                      PhosphorIconsRegular.train,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(
                                    'Vé điện tử MetroGo',
                                    style: AppTypography.textTheme.labelMedium
                                        ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              StatusBadge(
                                status: ticket.status,
                                fontSize: 11,
                              ),
                            ],
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // Route or Ticket Title
                          if (ticket.originStation != null &&
                              ticket.destinationStation != null) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    ticket.originStation!,
                                    style: AppTypography.textTheme.titleLarge
                                        ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: AppSpacing.xs),
                                  child: PhosphorIcon(
                                    PhosphorIconsRegular.arrowsLeftRight,
                                    color: Colors.white70,
                                    size: 18,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    ticket.destinationStation!,
                                    textAlign: TextAlign.right,
                                    style: AppTypography.textTheme.titleLarge
                                        ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            Text(
                              ticket.title,
                              style:
                                  AppTypography.textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],

                          const SizedBox(height: AppSpacing.xs),

                          // Validity & Line
                          Row(
                            children: [
                              const PhosphorIcon(
                                PhosphorIconsRegular.clock,
                                color: Colors.white70,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  ticket.validityText,
                                  style: AppTypography.textTheme.bodySmall
                                      ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (ticket.parking != null) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.35),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  PhosphorIcon(
                                    ticket.parking!.vehicleType == 'Ô tô'
                                        ? PhosphorIconsRegular.car
                                        : PhosphorIconsRegular.moped,
                                    size: 13,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      'Giữ xe: Ga ${ticket.parking!.station} (${ticket.parking!.licensePlate})',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // PERFORATED NOTCH & DASHED LINE DIVIDER
                    const _PerforatedDivider(),

                    // BOTTOM STUB SECTION: QR Code preview & Ticket ID
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      child: Row(
                        children: [
                          if (showQrPreview) ...[
                            // Mini QR Code preview
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                              child: QrImageView(
                                data: ticket.qrCodeData,
                                version: QrVersions.auto,
                                size: 54,
                                padding: EdgeInsets.zero,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'MÃ VÉ',
                                  style: AppTypography.textTheme.labelSmall
                                      ?.copyWith(
                                    color: Colors.white60,
                                    fontSize: 10,
                                    letterSpacing: 1.1,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  ticket.id,
                                  style: AppTypography.textTheme.labelMedium
                                      ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Chạm để phóng to quét tại cổng soát vé',
                                  style: AppTypography.textTheme.bodySmall
                                      ?.copyWith(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: const PhosphorIcon(
                              PhosphorIconsRegular.cornersOut,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for stylized rail tracks watermark
class _RailPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    // Diagonal gentle curves representing transit network tracks
    path.moveTo(-40, size.height * 0.4);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.2,
      size.width + 40,
      size.height * 0.7,
    );

    path.moveTo(-20, size.height * 0.6);
    path.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.4,
      size.width + 40,
      size.height * 0.9,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Perforated separator with left & right circular notch cutouts
class _PerforatedDivider extends StatelessWidget {
  const _PerforatedDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Dashed line across
          Positioned(
            left: 20,
            right: 20,
            child: CustomPaint(
              size: const Size(double.infinity, 1),
              painter: _DashedLinePainter(),
            ),
          ),
          // Left semi-circle notch cutout
          Positioned(
            left: -10,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Right semi-circle notch cutout
          Positioned(
            right: -10,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..strokeWidth = 1.2;

    const dashWidth = 5.0;
    const dashSpace = 4.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
