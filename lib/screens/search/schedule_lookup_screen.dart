import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../models/ticket_model.dart';
import '../../models/transit_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/metro_app_bar.dart';
import '../../widgets/metro_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/screen_switcher_sheet.dart';
import '../booking/booking_flow_screen.dart';

/// Screen: Schedule Lookup Screen
/// Origin & Destination pickers with animated swap button,
/// estimated travel time, next departure countdown chips, and corresponding fare.
class ScheduleLookupScreen extends StatefulWidget {
  const ScheduleLookupScreen({super.key});

  @override
  State<ScheduleLookupScreen> createState() => _ScheduleLookupScreenState();
}

class _ScheduleLookupScreenState extends State<ScheduleLookupScreen> {
  String _origin = 'Bến Thành';
  String _destination = 'Suối Tiên';

  void _swap() {
    setState(() {
      final temp = _origin;
      _origin = _destination;
      _destination = temp;
    });
  }

  void _pickStation(bool isOrigin) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppRadius.xl),
            topRight: Radius.circular(AppRadius.xl),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                isOrigin ? 'Chọn ga đi' : 'Chọn ga đến',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: TransitData.line1Stations.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final station = TransitData.line1Stations[index];
                  final isCurrent = isOrigin
                      ? _origin == station.vietnameseName
                      : _destination == station.vietnameseName;

                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? AppColors.primaryLight
                            : AppColors.surfaceSecondary,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: PhosphorIcon(
                        PhosphorIconsRegular.train,
                        size: 18,
                        color: isCurrent
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                    title: Text(
                      station.vietnameseName,
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        fontWeight:
                            isCurrent ? FontWeight.w700 : FontWeight.w500,
                        color: isCurrent
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Tuyến 1 • ${station.code}',
                      style: AppTypography.textTheme.bodySmall,
                    ),
                    trailing: isCurrent
                        ? const PhosphorIcon(
                            PhosphorIconsRegular.check,
                            color: AppColors.primary,
                            size: 18,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        if (isOrigin) {
                          _origin = station.vietnameseName;
                        } else {
                          _destination = station.vietnameseName;
                        }
                      });
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const estimatedTime = '28 phút';
    const stationCount = '9 ga';
    const fare = '15.000 đ';
    final departures = ['Sau 2 phút', '08:34', '08:42', '08:50', '08:58'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MetroAppBar(
        title: 'Lịch trình tàu',
        actions: const [
          ScreenSwitcherButton(),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. ORIGIN & DESTINATION PICKERS WITH SWAP
              MetroCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    Column(
                      children: [
                        _stationRow(
                          title: 'Ga đi',
                          station: _origin,
                          dotColor: AppColors.success,
                          onTap: () => _pickStation(true),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Divider(height: 1),
                        ),
                        _stationRow(
                          title: 'Ga đến',
                          station: _destination,
                          dotColor: AppColors.primary,
                          onTap: () => _pickStation(false),
                        ),
                      ],
                    ),
                    // Swap Button
                    Positioned(
                      right: 8,
                      child: GestureDetector(
                        onTap: _swap,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: const PhosphorIcon(
                            PhosphorIconsRegular.arrowsDownUp,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // 2. ESTIMATED TRAVEL TIME & FARE SUMMARY
              Text(
                'THÔNG TIN CHUYẾN ĐI',
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
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _metricBox(
                          'Thời gian ước tính',
                          estimatedTime,
                          PhosphorIconsRegular.timer,
                          AppColors.primary,
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppColors.borderSubtle,
                        ),
                        _metricBox(
                          'Số ga đi qua',
                          stationCount,
                          PhosphorIconsRegular.path,
                          AppColors.textPrimary,
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppColors.borderSubtle,
                        ),
                        _metricBox(
                          'Giá vé lượt',
                          fare,
                          PhosphorIconsRegular.ticket,
                          AppColors.successText,
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: Divider(height: 1),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: const PhosphorIcon(
                            PhosphorIconsRegular.train,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Tuyến 1 trực tiếp • Ga đón số 2 • Không cần đổi tàu',
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // 3. NEXT DEPARTURE TIMES
              Text(
                'CHUYẾN TÀU TIẾP THEO (BẾN THÀNH)',
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              MetroCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: departures.map((dep) {
                        final isImminent = dep.contains('phút');
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isImminent
                                ? AppColors.primary
                                : AppColors.surfaceSecondary,
                            borderRadius:
                                BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              PhosphorIcon(
                                isImminent
                                    ? PhosphorIconsRegular.clockCountdown
                                    : PhosphorIconsRegular.clock,
                                size: 14,
                                color: isImminent
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                dep,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isImminent
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Tàu chạy mỗi 4.5 phút trong giờ cao điểm (06:30 – 09:00 & 16:30 – 19:00).',
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // 4. BOOK THIS TICKET BUTTON
              PrimaryButton(
                text: 'Đặt vé chuyến này ($fare)',
                trailingIcon: PhosphorIconsRegular.arrowRight,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const BookingFlowScreen(
                        initialType: TicketType.singleRide,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stationRow({
    required String title,
    required String station,
    required Color dotColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Text(
                    station,
                    style: AppTypography.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const PhosphorIcon(
              PhosphorIconsRegular.caretRight,
              size: 16,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: 36),
          ],
        ),
      ),
    );
  }

  Widget _metricBox(
      String label, String value, PhosphorIconData icon, Color valueColor) {
    return Column(
      children: [
        PhosphorIcon(icon, size: 18, color: valueColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
        Text(
          label,
          style: AppTypography.textTheme.bodySmall?.copyWith(
            fontSize: 10,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
