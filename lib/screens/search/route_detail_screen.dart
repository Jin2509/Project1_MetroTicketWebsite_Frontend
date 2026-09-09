import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../models/transit_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/metro_app_bar.dart';
import '../../widgets/metro_card.dart';
import '../../widgets/screen_switcher_sheet.dart';
import '../../widgets/secondary_button.dart';

/// Screen: Route Detail Screen
/// Vertical timeline diagram of stations along the metro line,
/// labeled stations, transfer-station badges, and "View on map" button.
class RouteDetailScreen extends StatelessWidget {
  final MetroLine line;

  const RouteDetailScreen({super.key, required this.line});


  @override
  Widget build(BuildContext context) {
    final stations = line.stations.isNotEmpty
        ? line.stations
        : TransitData.line1Stations;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MetroAppBar(
        title: line.code,
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
              // 1. LINE SUMMARY CARD
              MetroCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: line.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: PhosphorIcon(
                            PhosphorIconsRegular.train,
                            color: line.color,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                line.name,
                                style: AppTypography.textTheme.titleMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '${stations.length} nhà ga • ${line.distanceKm}',
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
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: Divider(height: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _metricCol(
                          'Giờ hoạt động',
                          line.operatingHours.split(' ')[0],
                          PhosphorIconsRegular.clock,
                        ),
                        _metricCol(
                          'Giờ cao điểm',
                          line.frequencyPeak,
                          PhosphorIconsRegular.lightning,
                        ),
                        _metricCol(
                          'Bình thường',
                          line.frequencyOffPeak,
                          PhosphorIconsRegular.hourglass,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // VIEW ON MAP BUTTON
              SecondaryButton(
                text: 'Xem trên bản đồ trực tiếp',
                leadingIcon: PhosphorIconsRegular.mapTrifold,
                onPressed: () {
                  Navigator.of(context).pushNamed('/live-map');
                },
              ),

              const SizedBox(height: AppSpacing.xl),

              // 2. VERTICAL TIMELINE OF STATIONS
              Text(
                'LỘ TRÌNH CÁC NHÀ GA',
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              MetroCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.lg,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: stations.length,
                  itemBuilder: (context, index) {
                    final station = stations[index];
                    final isFirst = index == 0;
                    final isLast = index == stations.length - 1;

                    return _TimelineStationTile(
                      station: station,
                      lineColor: line.color,
                      isFirst: isFirst,
                      isLast: isLast,
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricCol(String label, String value, PhosphorIconData icon) {
    return Column(
      children: [
        PhosphorIcon(
          icon,
          size: 16,
          color: AppColors.primary,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
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

/// Custom Timeline tile with connected vertical lines and transfer badges
class _TimelineStationTile extends StatelessWidget {
  final MetroStation station;
  final Color lineColor;
  final bool isFirst;
  final bool isLast;

  const _TimelineStationTile({
    required this.station,
    required this.lineColor,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final isTerminal = isFirst || isLast;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Station Node & Vertical rail line
          SizedBox(
            width: 32,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Top line segment
                if (!isFirst)
                  Positioned(
                    top: 0,
                    bottom: 24,
                    child: Container(
                      width: 4,
                      color: lineColor.withValues(alpha: 0.35),
                    ),
                  ),
                // Bottom line segment
                if (!isLast)
                  Positioned(
                    top: 24,
                    bottom: 0,
                    child: Container(
                      width: 4,
                      color: lineColor.withValues(alpha: 0.35),
                    ),
                  ),
                // Node Dot
                Container(
                  width: isTerminal ? 16 : 12,
                  height: isTerminal ? 16 : 12,
                  decoration: BoxDecoration(
                    color: isTerminal ? lineColor : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: lineColor,
                      width: isTerminal ? 3 : 2.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // Station Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        station.vietnameseName,
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          fontWeight:
                              isTerminal ? FontWeight.w700 : FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '(${station.code})',
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                      if (station.isUnderground) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSecondary,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: const Text(
                            'Ga ngầm',
                            style: TextStyle(
                              fontSize: 9,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Transfer Station Badges
                  if (station.isInterchange &&
                      station.interchangeNote != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const PhosphorIcon(
                            PhosphorIconsRegular.arrowsLeftRight,
                            size: 12,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            station.interchangeNote!,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
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
          ),
        ],
      ),
    );
  }
}
