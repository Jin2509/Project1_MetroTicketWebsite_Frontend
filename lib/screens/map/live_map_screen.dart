import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../models/live_train_model.dart';
import '../../models/transit_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/metro_card.dart';
import '../../widgets/screen_switcher_sheet.dart';
import '../../widgets/status_badge.dart';
import '../ai/compact_ai_chat_sheet.dart';

/// Screen: Live Train Tracking Map Screen (Bản đồ thật & Lịch trình tàu)
/// Features:
/// 1. Full-screen OpenStreetMap with colored metro line polylines & animated pulsing train markers.
/// 2. Top-left segmented pill toggle: "Bản đồ thật" vs "Lịch trình".
/// 3. Right-side stacked circular zoom buttons ("+" and "−") with location recenter button.
/// 4. Floating bottom info card (Draggable bottom sheet): "ĐANG THEO DÕI · TUYẾN 1", "Tàu đến: Ba Son",
///    StatusBadge ("Đúng giờ" / "Trễ"), and station progress ("Ga 3/14").
/// 5. Floating Action Button at bottom-right with red unread badge "1", opening a compact floating
///    AI chatbot modal (~65-70% height) with quick replies, rich transit cards, and message bubbles.
class LiveMapScreen extends StatefulWidget {
  final bool showBackButton;

  const LiveMapScreen({super.key, this.showBackButton = false});

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  late final LiveTrainService _trainService;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  // View mode toggle: false = 'Bản đồ thật' (Real Map), true = 'Lịch trình' (Schedule Timeline)
  bool _showScheduleView = false;

  String _selectedLineId = 'line_1'; // 'line_1' or 'line_2'
  LiveTrain? _selectedTrain;

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
    _trainService.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _switchLine(String lineId) {
    setState(() {
      _selectedLineId = lineId;
      _selectedTrain = null;
    });

    if (lineId == 'line_1') {
      _mapController.move(const LatLng(10.8150, 106.7450), 13.0);
    } else {
      _mapController.move(const LatLng(10.7980, 106.6600), 13.5);
    }
  }

  void _panToUserLocation() {
    _mapController.move(MetroMapData.userLocation, 15.5);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã định vị: Ga Trung tâm Bến Thành'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _panToTrain(LiveTrain train) {
    setState(() {
      _selectedTrain = train;
      if (_showScheduleView) {
        _showScheduleView = false;
      }
    });
    _mapController.move(train.position, 15.5);
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom + 1.0);
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom - 1.0);
  }

  void _openCompactAiChat() {
    CompactAiChatSheet.show(
      context,
      onSelectRoute: (route) {
        if (route.contains('Suối Tiên') || route.contains('Tuyến 1')) {
          _switchLine('line_1');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListenableBuilder(
        listenable: _trainService,
        builder: (context, _) {
          final trains = _trainService.getTrainsForLine(_selectedLineId);
          final activeTrain = _selectedTrain ?? (trains.isNotEmpty ? trains.first : null);

          return Stack(
            children: [
              // 1. BASE LAYER: MAP VIEW OR SCHEDULE VIEW
              if (!_showScheduleView)
                _buildRealMapView(trains)
              else
                _buildScheduleTimelineView(trains, activeTrain),

              // 2. TOP FLOATING CONTROLS: Segmented Pill Toggle + Line Switcher
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button if requested
                      if (widget.showBackButton) ...[
                        _buildCircleButton(
                          icon: PhosphorIconsRegular.arrowLeft,
                          onTap: () => Navigator.of(context).maybePop(),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                      ],

                      // Segmented Pill Toggle: "Bản đồ thật" vs "Lịch trình"
                      _buildSegmentedViewToggle(),

                      const Spacer(),

                      // Line Switcher Dropdown Chip
                      _buildLineSwitcherDropdown(),

                      const SizedBox(width: AppSpacing.xs),

                      // Screen Switcher (Dev Reviewer Sheet)
                      const ScreenSwitcherButton(),
                    ],
                  ),
                ),
              ),

              // 3. RIGHT FLOATING CONTROLS: Stacked Circular Zoom Buttons (+ / -) & Location
              if (!_showScheduleView)
                Positioned(
                  right: AppSpacing.md,
                  bottom: 240,
                  child: Column(
                    children: [
                      // Zoom In (+)
                      _buildCircleButton(
                        icon: PhosphorIconsRegular.plus,
                        onTap: _zoomIn,
                      ),
                      const SizedBox(height: 8),

                      // Zoom Out (−)
                      _buildCircleButton(
                        icon: PhosphorIconsRegular.minus,
                        onTap: _zoomOut,
                      ),
                      const SizedBox(height: 12),

                      // Recenter User Location
                      _buildCircleButton(
                        icon: PhosphorIconsRegular.crosshair,
                        iconColor: AppColors.primary,
                        onTap: _panToUserLocation,
                      ),
                    ],
                  ),
                ),

              // 4. FLOATING ACTION BUTTON (AI CHATBOT)
              // Bottom right, above bottom panel, with unread badge '1'
              Positioned(
                right: AppSpacing.md,
                bottom: 125,
                child: _buildFloatingAiButton(),
              ),

              // 5. DRAGGABLE FLOATING BOTTOM SHEET (Train Status & Tracking Card)
              if (!_showScheduleView)
                _buildDraggableBottomPanel(trains, activeTrain),
            ],
          );
        },
      ),
    );
  }

  // --- 1. REAL MAP VIEW ---
  Widget _buildRealMapView(List<LiveTrain> trains) {
    return FlutterMap(
      mapController: _mapController,
      options: const MapOptions(
        initialCenter: LatLng(10.8150, 106.7450),
        initialZoom: 13.0,
        minZoom: 10.0,
        maxZoom: 18.0,
      ),
      children: [
        // OpenStreetMap Tile Layer
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.metrogo.app',
        ),

        // Metro Line Polylines (Blue for Line 1, Green for Line 2)
        PolylineLayer(
          polylines: [
            Polyline(
              points: MetroMapData.line1Polyline,
              color: _selectedLineId == 'line_1'
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.35),
              strokeWidth: _selectedLineId == 'line_1' ? 6.0 : 3.5,
            ),
            Polyline(
              points: MetroMapData.line2Polyline,
              color: _selectedLineId == 'line_2'
                  ? const Color(0xFF10B981)
                  : const Color(0xFF10B981).withValues(alpha: 0.35),
              strokeWidth: _selectedLineId == 'line_2' ? 6.0 : 3.5,
            ),
          ],
        ),

        // Station & Train Markers
        MarkerLayer(
          markers: [
            // Line 1 Stations
            ...MetroMapData.line1Stations.map(
              (station) => Marker(
                point: station.location,
                width: 32,
                height: 32,
                child: _buildStationMarker(station, AppColors.primary),
              ),
            ),

            // Line 2 Stations
            ...MetroMapData.line2Stations.map(
              (station) => Marker(
                point: station.location,
                width: 32,
                height: 32,
                child: _buildStationMarker(station, const Color(0xFF10B981)),
              ),
            ),

            // User Location Marker
            const Marker(
              point: MetroMapData.userLocation,
              width: 38,
              height: 38,
              child: _UserLocationMarker(),
            ),

            // Live Animated Train Markers
            ...trains.map(
              (train) => Marker(
                point: train.position,
                width: 58,
                height: 58,
                child: _LiveTrainMarkerWidget(
                  train: train,
                  pulseAnimation: _pulseAnimation,
                  isSelected: _selectedTrain?.id == train.id,
                  onTap: () => _panToTrain(train),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- 2. SCHEDULE / TIMELINE VIEW ---
  Widget _buildScheduleTimelineView(List<LiveTrain> trains, LiveTrain? activeTrain) {
    final stations = _selectedLineId == 'line_1'
        ? TransitData.line1Stations
        : TransitData.line2Stations;

    return Container(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 54), // Spacing for floating top bar

            // Route Overview Header Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: AppShadows.subtle,
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _selectedLineId == 'line_1'
                          ? AppColors.primary
                          : const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Center(
                      child: PhosphorIcon(
                        PhosphorIconsBold.train,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedLineId == 'line_1'
                              ? 'Tuyến 1: Bến Thành – Suối Tiên'
                              : 'Tuyến 2: Bến Thành – Tham Lương',
                          style: AppTypography.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${stations.length} ga • Tần suất 4-5 phút/chuyến • 05:00 - 22:00',
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      '${trains.length} đoàn tàu',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Timeline station list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.xs,
                  AppSpacing.lg,
                  100,
                ),
                itemCount: stations.length,
                itemBuilder: (context, index) {
                  final station = stations[index];
                  final isFirst = index == 0;
                  final isLast = index == stations.length - 1;

                  // Check if current active train is approaching this station (e.g. index 2: Ba Son)
                  final isApproaching = index == 2;

                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Left: Timeline vertical line & dot
                        SizedBox(
                          width: 32,
                          child: Column(
                            children: [
                              Container(
                                width: 3,
                                height: 16,
                                color: isFirst ? Colors.transparent : AppColors.primary,
                              ),
                              Container(
                                width: isApproaching ? 18 : 12,
                                height: isApproaching ? 18 : 12,
                                decoration: BoxDecoration(
                                  color: isApproaching ? AppColors.primary : Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primary,
                                    width: isApproaching ? 4 : 2.5,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  width: 3,
                                  color: isLast ? Colors.transparent : AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: AppSpacing.sm),

                        // Right: Station Card
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: MetroCard(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              backgroundColor: isApproaching
                                  ? AppColors.primaryLight.withValues(alpha: 0.5)
                                  : AppColors.surface,
                              border: Border.all(
                                color: isApproaching
                                    ? AppColors.primary
                                    : AppColors.borderSubtle,
                                width: isApproaching ? 1.5 : 1.0,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              '${index + 1}. ${station.vietnameseName}',
                                              style: AppTypography.textTheme.bodyMedium?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              station.code,
                                              style: AppTypography.textTheme.labelSmall?.copyWith(
                                                color: AppColors.textSecondary,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (station.isInterchange && station.interchangeNote != null) ...[
                                          const SizedBox(height: 3),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: AppColors.surfaceSecondary,
                                              borderRadius: BorderRadius.circular(AppRadius.sm),
                                              border: Border.all(color: AppColors.borderSubtle),
                                            ),
                                            child: Text(
                                              station.interchangeNote!,
                                              style: const TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),

                                  // Upcoming Train ETA Tag
                                  if (isApproaching)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(AppRadius.pill),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          PhosphorIcon(
                                            PhosphorIconsBold.train,
                                            size: 11,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Đến sau 2p',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    Text(
                                      '${(index - 2).abs() * 3 + 2} phút',
                                      style: AppTypography.textTheme.bodySmall?.copyWith(
                                        color: AppColors.textSecondary,
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- TOP BAR: Segmented Pill Toggle ("Bản đồ thật" & "Lịch trình") ---
  Widget _buildSegmentedViewToggle() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Button: "Bản đồ thật"
          _buildToggleOption(
            label: 'Bản đồ thật',
            icon: PhosphorIconsRegular.mapTrifold,
            isSelected: !_showScheduleView,
            onTap: () {
              if (_showScheduleView) {
                setState(() => _showScheduleView = false);
              }
            },
          ),
          // Button: "Lịch trình"
          _buildToggleOption(
            label: 'Lịch trình',
            icon: PhosphorIconsRegular.clockCountdown,
            isSelected: _showScheduleView,
            onTap: () {
              if (!_showScheduleView) {
                setState(() => _showScheduleView = true);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption({
    required String label,
    required PhosphorIconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PhosphorIcon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- TOP BAR: Line Switcher Dropdown ---
  Widget _buildLineSwitcherDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.subtle,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedLineId,
          isDense: true,
          dropdownColor: AppColors.surface,
          icon: const PhosphorIcon(
            PhosphorIconsRegular.caretDown,
            size: 13,
            color: AppColors.textSecondary,
          ),
          items: const [
            DropdownMenuItem(
              value: 'line_1',
              child: Row(
                children: [
                  _LineDot(color: AppColors.primary),
                  SizedBox(width: 6),
                  Text(
                    'Tuyến 1',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'line_2',
              child: Row(
                children: [
                  _LineDot(color: Color(0xFF10B981)),
                  SizedBox(width: 6),
                  Text(
                    'Tuyến 2',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
          onChanged: (val) {
            if (val != null) _switchLine(val);
          },
        ),
      ),
    );
  }

  // --- FLOATING CIRCLE BUTTON (Zoom In / Out / Recenter) ---
  Widget _buildCircleButton({
    required PhosphorIconData icon,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Center(
            child: PhosphorIcon(
              icon,
              size: 20,
              color: iconColor ?? AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  // --- FLOATING AI CHATBOT BUTTON (Bottom Right) ---
  Widget _buildFloatingAiButton() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.38),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _openCompactAiChat,
              child: const Center(
                child: PhosphorIcon(
                  PhosphorIconsFill.sparkle,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ),
        ),

        // Red unread message badge '1'
        Positioned(
          top: -2,
          right: -2,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Center(
              child: Text(
                '1',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- 4. FLOATING BOTTOM INFO PANEL (Draggable bottom sheet) ---
  Widget _buildDraggableBottomPanel(List<LiveTrain> trains, LiveTrain? activeTrain) {
    final rawStation = activeTrain?.nextStation ?? 'Ba Son';
    final nextStationName = rawStation.replaceAll(' Station', '');
    final lineLabel = _selectedLineId == 'line_1' ? 'TUYẾN 1' : 'TUYẾN 2';

    return DraggableScrollableSheet(
      initialChildSize: 0.18,
      minChildSize: 0.14,
      maxChildSize: 0.55,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppRadius.xl),
              topRight: Radius.circular(AppRadius.xl),
            ),
            border: const Border(
              top: BorderSide(color: AppColors.border, width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            children: [
              // Drag Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 8),
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),

              // Glance Summary Row (Requested exact format)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Stylized train icon in soft blue square
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Center(
                      child: PhosphorIcon(
                        PhosphorIconsBold.train,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                  ),

                  const SizedBox(width: AppSpacing.md),

                  // Text column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ĐANG THEO DÕI · $lineLabel',
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            color: AppColors.primaryText,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tàu đến: $nextStationName',
                          style: AppTypography.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status and station count badges
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const StatusBadge(
                        status: TicketStatus.paid,
                        customLabel: 'Đúng giờ',
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          _selectedLineId == 'line_1' ? 'Ga 3/14' : 'Ga 2/11',
                          style: const TextStyle(
                            color: AppColors.primaryText,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),
              const Divider(color: AppColors.borderSubtle, height: 1),
              const SizedBox(height: AppSpacing.md),

              // Expanded list of active trains
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Đoàn tàu đang vận hành (${trains.length})',
                    style: AppTypography.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Tốc độ TB: 58 km/h',
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              ...trains.map((train) {
                final isSelected = _selectedTrain?.id == train.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: MetroCard(
                    onTap: () => _panToTrain(train),
                    backgroundColor:
                        isSelected ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surfaceSecondary,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.borderSubtle,
                      width: isSelected ? 1.6 : 1.0,
                    ),
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: const PhosphorIcon(
                            PhosphorIconsBold.train,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${train.code} → ${train.destination}',
                                style: AppTypography.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Ga kế tiếp: ${train.nextStation} • Đến sau ${train.etaMinutes}p',
                                style: AppTypography.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const StatusBadge(
                          status: TicketStatus.paid,
                          customLabel: 'Đúng giờ',
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStationMarker(MapStationPoint station, Color lineColor) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${station.name} (${station.code})${station.isInterchange ? " • ${station.transferInfo}" : ""}',
            ),
            backgroundColor: lineColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Center(
        child: Container(
          width: station.isInterchange ? 18 : 13,
          height: station.isInterchange ? 18 : 13,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: lineColor,
              width: station.isInterchange ? 3.5 : 2.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LineDot extends StatelessWidget {
  final Color color;
  const _LineDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _UserLocationMarker extends StatelessWidget {
  const _UserLocationMarker();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.20),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LiveTrainMarkerWidget extends StatelessWidget {
  final LiveTrain train;
  final Animation<double> pulseAnimation;
  final bool isSelected;
  final VoidCallback onTap;

  const _LiveTrainMarkerWidget({
    required this.train,
    required this.pulseAnimation,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: pulseAnimation,
        builder: (context, child) {
          final pulseVal = pulseAnimation.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              // Pulsing translucent ring
              Container(
                width: 32 + (pulseVal * 20),
                height: 32 + (pulseVal * 20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(
                    alpha: (1.0 - pulseVal) * 0.35,
                  ),
                ),
              ),

              // Train Icon Marker Circle
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF1B56C7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? const Color(0xFFFFD166) : Colors.white,
                    width: isSelected ? 3.0 : 2.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.45),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: PhosphorIcon(
                    PhosphorIconsBold.train,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
