import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../models/live_train_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/metro_app_bar.dart';
import '../../widgets/metro_card.dart';
import '../../widgets/metro_text_field.dart';
import '../../widgets/screen_switcher_sheet.dart';
import '../../widgets/vietnam_map_background.dart';
import '../ai/compact_ai_chat_sheet.dart';

/// Screen: SearchMapScreen
/// Gộp Tra cứu và Bản đồ vào 1 mục:
/// 1. Phía trên: Thanh tra cứu tuyến & nhà ga
/// 2. Ở giữa: Bản đồ Metro tương tác thời gian thực
/// 3. Phía dưới: Danh sách các ga hiện có (chạm vào ga sẽ di chuyển tâm bản đồ)
class SearchMapScreen extends StatefulWidget {
  final bool showBackButton;

  const SearchMapScreen({super.key, this.showBackButton = false});

  @override
  State<SearchMapScreen> createState() => _SearchMapScreenState();
}

class _SearchMapScreenState extends State<SearchMapScreen>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  late final LiveTrainService _trainService;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  String _searchQuery = '';
  String _selectedLineId = 'line_1'; // 'line_1' or 'line_2'
  MapStationPoint? _selectedStation;

  @override
  void initState() {
    super.initState();
    _trainService = LiveTrainService();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: false);

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _trainService.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onStationTapped(MapStationPoint station) {
    setState(() {
      _selectedStation = station;
    });
    _mapController.move(station.location, 15.5);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã định vị: Ga ${station.name} (${station.code})'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
    );
  }

  void _panToUserLocation() {
    _mapController.move(MetroMapData.userLocation, 15.5);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã định vị: Ga Trung tâm Bến Thành'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
    );
  }

  void _openAiChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CompactAiChatSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allStations = _selectedLineId == 'line_1'
        ? MetroMapData.line1Stations
        : MetroMapData.line2Stations;

    final filteredStations = allStations.where((s) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return s.name.toLowerCase().contains(query) ||
          s.code.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MetroAppBar(
        showBackButton: widget.showBackButton,
        title: 'Tra cứu & Bản đồ',
        actions: const [
          ScreenSwitcherButton(),
        ],
      ),
      body: VietnamMapBackground(
        opacity: 0.08,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. PHÍA TRÊN: MỤC TRA CỨU TUYẾN / THANH TRA CỨU
                MetroTextField(
                  controller: _searchController,
                  hintText: 'Tìm kiếm tuyến, nhà ga (Bến Thành, Ba Son...)',
                  prefixIcon: PhosphorIconsRegular.magnifyingGlass,
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const PhosphorIcon(
                            PhosphorIconsRegular.xCircle,
                            size: 18,
                            color: AppColors.textMuted,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),

                const SizedBox(height: AppSpacing.sm),

                // Filter Line Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildLineFilterChip(
                        id: 'line_1',
                        title: 'Tuyến 1: Bến Thành – Suối Tiên',
                        color: AppColors.primary,
                        stationCount: 14,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _buildLineFilterChip(
                        id: 'line_2',
                        title: 'Tuyến 2: Bến Thành – Tham Lương',
                        color: const Color(0xFF10B981),
                        stationCount: 11,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // 2. PHÍA DƯỚI THANH TRA CỨU: BẢN ĐỒ THẬT
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const PhosphorIcon(
                          PhosphorIconsBold.mapTrifold,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Bản đồ tuyến Metro',
                          style: AppTypography.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pushNamed('/live-map'),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const PhosphorIcon(
                              PhosphorIconsBold.cornersOut,
                              size: 15,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Xem toàn bản đồ',
                              style: AppTypography.textTheme.labelMedium?.copyWith(
                                color: AppColors.primaryText,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xs),

                Container(
                  height: 380,
                  decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.borderSubtle),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: Stack(
                    children: [
                      // Interactive FlutterMap
                      FlutterMap(
                        mapController: _mapController,
                        options: const MapOptions(
                          initialCenter: LatLng(10.8050, 106.7400),
                          initialZoom: 12.8,
                          minZoom: 11.0,
                          maxZoom: 18.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.metrogo.hcmc.app',
                          ),
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: MetroMapData.line1Polyline,
                                strokeWidth: 5.0,
                                color: AppColors.primary,
                              ),
                              Polyline(
                                points: MetroMapData.line2Polyline,
                                strokeWidth: 4.0,
                                color: const Color(0xFF10B981).withValues(alpha: 0.7),
                              ),
                            ],
                          ),
                          // Station markers
                          MarkerLayer(
                            markers: allStations.map((station) {
                              final isSelected = _selectedStation?.id == station.id;
                              return Marker(
                                point: station.location,
                                width: isSelected ? 40 : 26,
                                height: isSelected ? 40 : 26,
                                child: GestureDetector(
                                  onTap: () => _onStationTapped(station),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.warning : AppColors.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (isSelected ? AppColors.warning : AppColors.primary)
                                              .withValues(alpha: 0.4),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: PhosphorIcon(
                                        PhosphorIconsFill.train,
                                        size: isSelected ? 20 : 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          // Live Moving Train Markers
                          ListenableBuilder(
                            listenable: _trainService,
                            builder: (context, _) {
                              final trains = _trainService.getTrainsForLine(_selectedLineId);
                              return MarkerLayer(
                                markers: trains.map((train) {
                                  return Marker(
                                    point: train.position,
                                    width: 36,
                                    height: 36,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        AnimatedBuilder(
                                          animation: _pulseAnimation,
                                          builder: (context, child) {
                                            return Container(
                                              width: 34 * _pulseAnimation.value,
                                              height: 34 * _pulseAnimation.value,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppColors.primary.withValues(
                                                  alpha: (1.0 - _pulseAnimation.value) * 0.5,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1A1D29),
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 2),
                                          ),
                                          child: const Center(
                                            child: PhosphorIcon(
                                              PhosphorIconsFill.navigationArrow,
                                              size: 12,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      ),

                      // Map Control Overlay: Full-screen, Zoom and Recenter
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Column(
                          children: [
                            _buildMapCircleButton(
                              icon: PhosphorIconsBold.cornersOut,
                              onTap: () => Navigator.of(context).pushNamed('/live-map'),
                            ),
                            const SizedBox(height: 6),
                            _buildMapCircleButton(
                              icon: PhosphorIconsBold.plus,
                              onTap: () {
                                final zoom = _mapController.camera.zoom;
                                _mapController.move(_mapController.camera.center, zoom + 1);
                              },
                            ),
                            const SizedBox(height: 6),
                            _buildMapCircleButton(
                              icon: PhosphorIconsBold.minus,
                              onTap: () {
                                final zoom = _mapController.camera.zoom;
                                _mapController.move(_mapController.camera.center, zoom - 1);
                              },
                            ),
                            const SizedBox(height: 6),
                            _buildMapCircleButton(
                              icon: PhosphorIconsBold.crosshair,
                              onTap: _panToUserLocation,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),

                      // Full-screen map pill on bottom-left
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pushNamed('/live-map'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.surface.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                              border: Border.all(color: AppColors.borderSubtle),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                PhosphorIcon(
                                  PhosphorIconsBold.cornersOut,
                                  size: 13,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Xem toàn bản đồ',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Floating AI Assistant Button
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: GestureDetector(
                          onTap: _openAiChat,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                PhosphorIcon(
                                  PhosphorIconsFill.sparkle,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Hỏi AI',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // 3. PHÍA DƯỚI BẢN ĐỒ: DANH SÁCH CÁC GA HIỆN CÓ
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Danh sách các ga hiện có (${filteredStations.length})',
                    style: AppTypography.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Chạm để định vị',
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              if (filteredStations.isEmpty)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  alignment: Alignment.center,
                  child: Text(
                    'Không tìm thấy nhà ga phù hợp',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredStations.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.xs),
                  itemBuilder: (context, index) {
                    final station = filteredStations[index];
                    final isSelected = _selectedStation?.id == station.id;

                    return MetroCard(
                      onTap: () => _onStationTapped(station),
                      backgroundColor: isSelected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surface,
                      borderRadius: AppRadius.md,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.borderSubtle,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          // Station Code Badge
                          Container(
                            width: 46,
                            height: 34,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Center(
                              child: Text(
                                station.code,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : AppColors.primaryText,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: AppSpacing.md),

                          // Station Name & Type
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  station.name,
                                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: isSelected ? AppColors.primaryText : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  station.isInterchange
                                      ? (station.transferInfo ?? 'Ga trung chuyển')
                                      : (index < 3 ? 'Ga ngầm' : 'Ga trên cao'),
                                  style: AppTypography.textTheme.bodySmall?.copyWith(
                                    color: station.isInterchange
                                        ? AppColors.warning
                                        : AppColors.textSecondary,
                                    fontSize: 11,
                                    fontWeight: station.isInterchange
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Action Icon
                          PhosphorIcon(
                            isSelected
                                ? PhosphorIconsFill.mapPin
                                : PhosphorIconsRegular.navigationArrow,
                            color: isSelected ? AppColors.primary : AppColors.textMuted,
                            size: 18,
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildLineFilterChip({
    required String id,
    required String title,
    required Color color,
    required int stationCount,
  }) {
    final isSelected = _selectedLineId == id;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLineId = id;
          _selectedStation = null;
        });
        if (id == 'line_1') {
          _mapController.move(const LatLng(10.8050, 106.7400), 12.8);
        } else {
          _mapController.move(const LatLng(10.7980, 106.6600), 13.5);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: isSelected ? color : AppColors.borderSubtle,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? color : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapCircleButton({
    required PhosphorIconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: PhosphorIcon(
            icon,
            size: 16,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
