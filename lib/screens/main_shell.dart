import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/news_model.dart';
import '../models/ticket_model.dart';
import '../theme/app_theme.dart';
import '../widgets/global_floating_ai_button.dart';
import '../widgets/metro_app_bar.dart';
import '../widgets/metro_bottom_nav.dart';
import '../widgets/metro_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/screen_switcher_sheet.dart';
import '../widgets/vietnam_map_background.dart';
import 'map/search_map_screen.dart';
import 'news/article_detail_screen.dart';
import 'profile/profile_screen.dart';
import 'tickets/my_tickets_screen.dart';
import 'tickets/ticket_detail_screen.dart';

/// MainShell:
/// The primary host scaffold of the application featuring MetroBottomNav with 4 tabs:
/// 1. Home
/// 2. Search & Map (Tra cứu & Bản đồ)
/// 3. My Tickets (Vé của tôi)
/// 4. Profile (Tài khoản)
/// Includes global floating AI assistant button and Vietnam map background texture.
class MainShell extends StatefulWidget {
  final int initialTab;

  const MainShell({super.key, this.initialTab = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;
  String _selectedCheckInStation = 'Bến Thành';
  String _selectedExitStation = 'Bến Xe Suối Tiên';

  static const List<String> _metroStations = [
    'Bến Thành',
    'Nhà Hát Thành Phố',
    'Ba Son',
    'Công Viên Văn Thánh',
    'Tân Cảng',
    'Thảo Điền',
    'An Phú',
    'Rạch Chiếc',
    'Phước Long',
    'Bình Thái',
    'Thủ Đức',
    'Khu Công Nghệ Cao',
    'Đại Học Quốc Gia',
    'Bến Xe Suối Tiên',
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              _buildHomeTab(),
              const SearchMapScreen(showBackButton: false),
              const MyTicketsScreen(),
              const ProfileScreen(),
            ],
          ),
          // Persistent Floating AI Chatbot Button on all tabs
          const GlobalFloatingAiButton(
            bottomOffset: 16,
            rightOffset: 16,
          ),
        ],
      ),
      bottomNavigationBar: MetroBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }

  // Tab 0: Home Preview
  Widget _buildHomeTab() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: MetroAppBar(
        showBackButton: false,
        useGradient: true,
        titleWidget: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const PhosphorIcon(
                PhosphorIconsRegular.train,
                size: 18,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Metro',
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextSpan(
                    text: 'Go',
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed('/notifications'),
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const PhosphorIcon(
                  PhosphorIconsRegular.bellSimple,
                  size: 22,
                  color: AppColors.textPrimary,
                ),
                Positioned(
                  right: -1,
                  top: -1,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const ScreenSwitcherButton(),
        ],
      ),
      body: VietnamMapBackground(
        opacity: 0.09,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Active Ticket Boarding Pass Card
            _buildActiveTicketCard(context),

            const SizedBox(height: AppSpacing.md),

            // 2. Check-in / Check-out Section
            _buildCheckInOutSection(context),

            const SizedBox(height: AppSpacing.md),

            // 3. Action Buttons Row (Mua vé & Vé của tôi)
            _buildActionButtonsRow(context),

            const SizedBox(height: AppSpacing.xl),

            // 3. Quick Route Search Card
            _buildQuickRouteCard(context),

            const SizedBox(height: AppSpacing.xl),

            // 4. Metro News & Updates with Network Image Thumbnails
            _buildNewsSection(context),
          ],
        ),
      ),
    ),
  );
}

  // --- 1. ACTIVE TICKET BOARDING PASS CARD ---
  Widget _buildActiveTicketCard(BuildContext context) {
    return ListenableBuilder(
      listenable: TicketStore.instance,
      builder: (context, _) {
        final activeTickets = TicketStore.instance.activeTickets;
        final hasTicket = activeTickets.isNotEmpty;
        final ticket = hasTicket ? activeTickets.first : null;

        if (!hasTicket) {
          // Empty State / All Tickets Expired
          return MetroCard(
            backgroundColor: AppColors.surface,
            borderRadius: AppRadius.lg,
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.warningLight,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Center(
                        child: PhosphorIcon(
                          PhosphorIconsBold.ticket,
                          color: AppColors.warning,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chưa có vé để lên tàu',
                            style: AppTypography.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Tất cả vé đã hết hạn hoặc chưa đặt vé',
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Bạn cần mua vé để nhận mã QR quét qua cổng soát vé tại các ga Metro.',
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pushNamed('/booking'),
                        icon: const PhosphorIcon(PhosphorIconsBold.plus, size: 16),
                        label: const Text('Mua vé ngay'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    OutlinedButton.icon(
                      onPressed: () => _showNoActiveTicketDialog(context),
                      icon: const PhosphorIcon(PhosphorIconsBold.qrCode, size: 16),
                      label: const Text('Mã QR lên tàu'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.borderMedium),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        // Active Ticket Available
        return MetroCard(
          backgroundColor: AppColors.surface,
          borderRadius: AppRadius.lg,
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: const Center(
                          child: PhosphorIcon(
                            PhosphorIconsBold.ticket,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ticket!.title,
                            style: AppTypography.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            ticket.id,
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Vé hiệu lực',
                          style: TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Route & validity container
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  children: [
                    // Miniature QR Preview (tappable to enlarge)
                    GestureDetector(
                      onTap: () => _showTurnstilePassSheet(context, ticket),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: AppColors.borderSubtle),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: QrImageView(
                          data: ticket.qrCodeData,
                          version: QrVersions.auto,
                          size: 72,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: AppColors.primary,
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Color(0xFF13111C),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: AppSpacing.md),

                    // Route details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lộ trình lên tàu:',
                            style: AppTypography.textTheme.labelSmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${ticket.originStation ?? "Bến Thành"} → ${ticket.destinationStation ?? "Suối Tiên"}',
                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ticket.validityText,
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Prominent Button: Mã QR lên tàu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showTurnstilePassSheet(context, ticket),
                  icon: const PhosphorIcon(
                    PhosphorIconsBold.qrCode,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: const Text('Mã QR lên tàu'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- 2. CHECK-IN / CHECK-OUT SECTION ---
  Widget _buildCheckInOutSection(BuildContext context) {
    return ListenableBuilder(
      listenable: TicketStore.instance,
      builder: (context, _) {
        final isCheckedIn = TicketStore.instance.isCheckedIn;
        final checkInStation = TicketStore.instance.checkInStation;
        final checkInTime = TicketStore.instance.checkInTime;
        final activeTickets = TicketStore.instance.activeTickets;
        final hasActiveTicket = activeTickets.isNotEmpty;

        return MetroCard(
          backgroundColor: isCheckedIn ? AppColors.surfaceSecondary : AppColors.surface,
          borderRadius: AppRadius.lg,
          border: Border.all(
            color: isCheckedIn ? AppColors.primary : AppColors.borderSubtle,
            width: isCheckedIn ? 1.5 : 1.0,
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isCheckedIn
                              ? AppColors.primary.withValues(alpha: 0.2)
                              : AppColors.surfaceSecondary,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Center(
                          child: PhosphorIcon(
                            isCheckedIn
                                ? PhosphorIconsBold.train
                                : PhosphorIconsBold.signIn,
                            color: isCheckedIn ? AppColors.primary : AppColors.textPrimary,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isCheckedIn
                                ? 'Hành trình đang diễn ra'
                                : 'Cổng soát vé ga',
                            style: AppTypography.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            isCheckedIn
                                ? 'Đang trên tàu • Đã qua cổng vào'
                                : 'Check-in / Check-out tự động',
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isCheckedIn
                          ? AppColors.successLight
                          : AppColors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isCheckedIn) ...[
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          isCheckedIn ? 'ĐÃ CHECK-IN' : 'Chưa vào ga',
                          style: TextStyle(
                            color: isCheckedIn ? AppColors.success : AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              if (!isCheckedIn) ...[
                // NOT CHECKED IN STATE
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      const PhosphorIcon(
                        PhosphorIconsBold.mapPin,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Ga vào:',
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCheckInStation,
                            isExpanded: true,
                            icon: const PhosphorIcon(
                              PhosphorIconsBold.caretDown,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            items: _metroStations.map((station) {
                              return DropdownMenuItem<String>(
                                value: station,
                                child: Text(station),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedCheckInStation = val);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Button Check-in
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (!hasActiveTicket) {
                        _showNoActiveTicketDialog(context);
                      } else {
                        TicketStore.instance.checkIn(
                          _selectedCheckInStation,
                          activeTickets.first,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Đã Check-in vào Ga $_selectedCheckInStation!'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                          ),
                        );
                        // Auto-open Turnstile QR code so passenger can scan
                        _showTurnstilePassSheet(context, activeTickets.first);
                      }
                    },
                    icon: const PhosphorIcon(
                      PhosphorIconsBold.signIn,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: const Text('Check-in vào ga'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ] else ...[
                // CHECKED IN (IN TRANSIT) STATE
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Ga đã vào:',
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'Ga $checkInStation',
                                style: AppTypography.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                              if (checkInTime != null) ...[
                                const SizedBox(width: 6),
                                Text(
                                  '(${checkInTime.hour.toString().padLeft(2, '0')}:${checkInTime.minute.toString().padLeft(2, '0')})',
                                  style: AppTypography.textTheme.bodySmall?.copyWith(
                                    color: AppColors.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 16, color: AppColors.borderSubtle),
                      Row(
                        children: [
                          const PhosphorIcon(
                            PhosphorIconsBold.mapPin,
                            size: 18,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Ga ra:',
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedExitStation,
                                isExpanded: true,
                                icon: const PhosphorIcon(
                                  PhosphorIconsBold.caretDown,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                                style: AppTypography.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                                items: _metroStations.map((station) {
                                  return DropdownMenuItem<String>(
                                    value: station,
                                    child: Text(station),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedExitStation = val);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                Row(
                  children: [
                    // Show QR again
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          if (hasActiveTicket) {
                            _showTurnstilePassSheet(context, activeTickets.first);
                          }
                        },
                        icon: const PhosphorIcon(
                          PhosphorIconsBold.qrCode,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        label: const Text('Mã QR qua cổng'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    // Check-out button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _handleCheckOut(context),
                        icon: const PhosphorIcon(
                          PhosphorIconsBold.signOut,
                          size: 16,
                          color: Colors.white,
                        ),
                        label: const Text('Check-out ra ga'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // --- CHECK-OUT HANDLER & SUCCESS MODAL ---
  void _handleCheckOut(BuildContext context) {
    final entryStation = TicketStore.instance.checkInStation ?? 'Bến Thành';
    final exitStation = _selectedExitStation;

    TicketStore.instance.checkOut(exitStation);

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
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderMedium,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: AppColors.successLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: PhosphorIcon(
                      PhosphorIconsBold.checkCircle,
                      color: AppColors.success,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Check-out thành công!',
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bạn đã hoàn thành chuyến đi và qua cổng kiểm soát an toàn.',
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('Ga vào', 'Ga $entryStation'),
                      const Divider(height: 16, color: AppColors.borderSubtle),
                      _buildDetailRow('Ga ra', 'Ga $exitStation'),
                      const Divider(height: 16, color: AppColors.borderSubtle),
                      _buildDetailRow(
                        'Thời gian ra ga',
                        '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Hoàn tất'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- 3. ACTION BUTTONS ROW ---
  Widget _buildActionButtonsRow(BuildContext context) {
    return Row(
      children: [
        // Button 1: Mua vé
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed('/booking');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              elevation: 0,
            ),
            icon: const PhosphorIcon(
              PhosphorIconsBold.plus,
              size: 18,
            ),
            label: Text(
              'Mua vé',
              style: AppTypography.textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        const SizedBox(width: AppSpacing.sm),

        // Button 2: Quản lý vé
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() => _currentIndex = 2);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              elevation: 0,
            ),
            icon: const PhosphorIcon(
              PhosphorIconsBold.ticket,
              color: AppColors.primary,
              size: 18,
            ),
            label: Text(
              'Vé của tôi',
              style: AppTypography.textTheme.labelLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- TURNSTILE PASS SHEET (QR Loại 2 - QR Vé đã mua) ---
  void _showTurnstilePassSheet(BuildContext context, Ticket ticket) {
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
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderMedium,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const PhosphorIcon(
                  PhosphorIconsBold.ticket,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  'VÉ QUÉT CỔNG SOÁT VÉ',
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Đưa mã QR trước mắt quét tại cổng tự động nhà ga (cách 10cm)',
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Large Ticket QR code
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.borderSubtle),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: QrImageView(
                data: ticket.qrCodeData,
                version: QrVersions.auto,
                size: 190,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: AppColors.primary,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Color(0xFF13111C),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Ticket Summary Box
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ticket.title,
                        style: AppTypography.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: const Text(
                          'Còn hiệu lực',
                          style: TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Lộ trình: ${ticket.originStation ?? "Bến Thành"} → ${ticket.destinationStation ?? "Suối Tiên"}',
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        ticket.id,
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() => _currentIndex = 2);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Xem tất cả vé'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TicketDetailScreen(ticket: ticket),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Chi tiết vé'),
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

  // --- NO ACTIVE TICKET DIALOG ---
  void _showNoActiveTicketDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderMedium,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.warningLight,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: PhosphorIcon(
                  PhosphorIconsRegular.ticket,
                  color: AppColors.warning,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Bạn chưa có vé hiệu lực',
              style: AppTypography.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Vui lòng mua vé để nhận mã QR quét qua cổng soát vé tại nhà ga.',
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed('/booking');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Mua vé ngay'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 3. QUICK ROUTE SEARCH CARD ---
  Widget _buildQuickRouteCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tìm hành trình nhanh',
          style: AppTypography.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        MetroCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              Row(
                children: [
                  const PhosphorIcon(
                    PhosphorIconsRegular.circle,
                    color: AppColors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Ga Trung tâm Bến Thành',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 7, top: 4, bottom: 4),
                child: Container(
                  width: 2,
                  height: 18,
                  color: AppColors.border,
                ),
              ),
              Row(
                children: [
                  const PhosphorIcon(
                    PhosphorIconsRegular.mapPin,
                    color: AppColors.error,
                    size: 16,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Công viên Suối Tiên',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              PrimaryButton(
                text: 'Tra cứu lộ trình & lịch tàu',
                height: 46,
                leadingIcon: PhosphorIconsRegular.magnifyingGlass,
                onPressed: () {
                  Navigator.of(context).pushNamed('/schedule-lookup');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- 4. NEWS SECTION (Image.network with loading & fallback) ---
  Widget _buildNewsSection(BuildContext context) {
    final displayArticles = NewsData.articles.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tin tức & Cập nhật',
              style: AppTypography.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            InkWell(
              onTap: () => Navigator.of(context).pushNamed('/news'),
              child: Text(
                'Xem tất cả',
                style: AppTypography.textTheme.labelMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ...displayArticles.map((article) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: MetroCard(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ArticleDetailScreen(article: article),
                  ),
                );
              },
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Network image with loading placeholder & error fallback
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Image.network(
                      article.imageUrl ?? '',
                      width: 88,
                      height: 88,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 88,
                          height: 88,
                          color: AppColors.surfaceSecondary,
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: article.gradientColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Center(
                            child: PhosphorIcon(
                              PhosphorIconsRegular.newspaper,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: AppSpacing.md),

                  // Article details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                              ),
                              child: Text(
                                article.category.toUpperCase(),
                                style: AppTypography.textTheme.labelSmall?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              article.date,
                              style: AppTypography.textTheme.labelSmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          article.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          article.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const PhosphorIcon(
                    PhosphorIconsRegular.caretRight,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // --- HELPER: DETAIL ROW WITH COPY ---
  Widget _buildDetailRow(
    String label,
    String value, {
    bool isHighlight = false,
    VoidCallback? onCopy,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: AppTypography.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
                    color: isHighlight ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
              ),
              if (onCopy != null) ...[
                const SizedBox(width: 6),
                InkWell(
                  onTap: onCopy,
                  child: const PhosphorIcon(
                    PhosphorIconsRegular.copy,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

