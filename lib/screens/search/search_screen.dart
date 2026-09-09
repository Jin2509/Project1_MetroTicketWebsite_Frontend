import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../models/transit_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/metro_app_bar.dart';
import '../../widgets/metro_card.dart';
import '../../widgets/metro_text_field.dart';
import '../../widgets/screen_switcher_sheet.dart';
import 'route_detail_screen.dart';

/// Screen: Search Screen
/// Search bar at top, "Suggested for you" horizontal-scroll cards,
/// and "All routes" vertical list with line details.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _suggestedRoutes = [
    {
      'title': 'Bến Thành → Suối Tiên',
      'line': 'Tuyến 1',
      'color': Color(0xFF2F6FED),
      'duration': '32 phút',
      'fare': '15.000 đ',
    },
    {
      'title': 'Ga Ba Son',
      'line': 'Tuyến 1',
      'color': Color(0xFF2F6FED),
      'duration': 'Kết nối Waterbus',
      'fare': 'Trung chuyển',
    },
    {
      'title': 'Nhà hát TP → Tân Cảng',
      'line': 'Tuyến 1',
      'color': Color(0xFF2F6FED),
      'duration': '14 phút',
      'fare': '12.000 đ',
    },
    {
      'title': 'Bến Thành → Tham Lương',
      'line': 'Tuyến 2',
      'color': Color(0xFF10B981),
      'duration': '22 phút',
      'fare': 'Sắp mở',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredLines = TransitData.lines.where((l) {
      if (_query.isEmpty) return true;
      return l.name.toLowerCase().contains(_query.toLowerCase()) ||
          l.code.toLowerCase().contains(_query.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MetroAppBar(
        showBackButton: false,
        title: 'Tra cứu tuyến',
        actions: const [
          ScreenSwitcherButton(),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TOP SEARCH BAR
              MetroTextField(
                controller: _searchController,
                hintText: 'Tìm kiếm tuyến, nhà ga hoặc điểm đến...',
                prefixIcon: PhosphorIconsRegular.magnifyingGlass,
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const PhosphorIcon(
                          PhosphorIconsRegular.xCircle,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                onChanged: (val) {
                  setState(() => _query = val.trim());
                },
              ),

              const SizedBox(height: AppSpacing.md),

              // LIVE MAP PROMINENT BANNER
              MetroCard(
                onTap: () {
                  Navigator.of(context).pushNamed('/live-map');
                },
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const PhosphorIcon(
                        PhosphorIconsBold.navigationArrow,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bản đồ theo dõi tàu thời gian thực',
                            style: AppTypography.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Vị trí GPS trực tiếp, lộ trình tuyến & thời gian đến',
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PhosphorIcon(
                      PhosphorIconsRegular.caretRight,
                      color: Colors.white70,
                      size: 16,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // QUICK NAVIGATION SHORTCUTS
              Row(
                children: [
                  Expanded(
                    child: _quickActionCard(
                      title: 'Lịch trình tàu',
                      subtitle: 'Giờ chạy & chuyến kế',
                      icon: PhosphorIconsRegular.clockCountdown,
                      color: AppColors.primary,
                      onTap: () {
                        Navigator.of(context).pushNamed('/schedule-lookup');
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _quickActionCard(
                      title: 'Bảng giá vé',
                      subtitle: 'So sánh các gói vé',
                      icon: PhosphorIconsRegular.currencyCircleDollar,
                      color: AppColors.success,
                      onTap: () {
                        Navigator.of(context).pushNamed('/fare-table');
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // 2. SUGGESTED FOR YOU (Horizontal Scroll)
              if (_query.isEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'GỢI Ý CHO BẠN',
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Tuyến phổ biến',
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _suggestedRoutes.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final item = _suggestedRoutes[index];
                      final Color color = item['color'] as Color;

                      return SizedBox(
                        width: 200,
                        child: MetroCard(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => RouteDetailScreen(
                                  line: TransitData.lines[0],
                                ),
                              ),
                            );
                          },
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(AppRadius.sm),
                                    ),
                                    child: PhosphorIcon(
                                      PhosphorIconsRegular.train,
                                      size: 14,
                                      color: color,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    item['line'],
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: color,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                item['title'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.textTheme.labelLarge
                                    ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item['duration'],
                                    style: AppTypography.textTheme.bodySmall
                                        ?.copyWith(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    item['fare'],
                                    style: AppTypography.textTheme.labelSmall
                                        ?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),
              ],

              // 3. ALL ROUTES (Vertical List)
              Text(
                'TẤT CẢ CÁC TUYẾN',
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: filteredLines.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final line = filteredLines[index];
                  return MetroCard(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => RouteDetailScreen(line: line),
                        ),
                      );
                    },
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        // Line Color Pill Tag
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: line.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: line.color.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Center(
                            child: PhosphorIcon(
                              PhosphorIconsRegular.train,
                              size: 22,
                              color: line.color,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    line.name,
                                    style: AppTypography.textTheme.titleSmall
                                        ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Text(
                                    '${line.stationCount} nhà ga • ${line.distanceKm}',
                                    style: AppTypography.textTheme.bodySmall
                                        ?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                line.operatingHours,
                                style: AppTypography.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
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
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickActionCard({
    required String title,
    required String subtitle,
    required PhosphorIconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return MetroCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: PhosphorIcon(
              icon,
              size: 18,
              color: color,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
