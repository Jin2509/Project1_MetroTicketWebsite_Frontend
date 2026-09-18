import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../models/live_train_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/metro_card.dart';
import '../../widgets/screen_switcher_sheet.dart';
import '../../widgets/station_amenities_sheet.dart';

/// Landmark or destination searched by the user in HCMC
class HcmcLandmark {
  final String name;
  final String address;
  final LatLng location;
  final String nearestStationId;
  final String nearestStationName;
  final String distanceToStation;
  final String walkTime;
  final PhosphorIconData icon;

  const HcmcLandmark({
    required this.name,
    required this.address,
    required this.location,
    required this.nearestStationId,
    required this.nearestStationName,
    required this.distanceToStation,
    required this.walkTime,
    required this.icon,
  });
}

/// Amenity marker on map
class MapAmenityMarker {
  final String name;
  final LatLng location;
  final AmenityCategory category;
  final String distance;

  const MapAmenityMarker({
    required this.name,
    required this.location,
    required this.category,
    required this.distance,
  });
}

/// Screen: SearchMapScreen
/// 1. Màn hình map fullscreen (100% không gian)
/// 2. Thanh tìm kiếm nổi nhập địa chỉ / địa điểm xung quanh
/// 3. Tính năng mở rộng tìm khu vực xung quanh & tiện ích (bãi xe, xe buýt, ăn uống, ATM)
/// 4. Danh sách các ga hiện có (drawer / bottom sheet tương tác)
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
  final FocusNode _searchFocusNode = FocusNode();

  late final LiveTrainService _trainService;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  String _searchQuery = '';
  bool _isSearchFocused = false;
  String _selectedLineId = 'line_1'; // 'line_1' or 'line_2'
  MapStationPoint? _selectedStation;
  HcmcLandmark? _selectedLandmark;
  AmenityCategory? _selectedAmenityCategory; // null = all

  // Curated prominent landmarks in HCMC near Metro Line 1 & Line 2
  static const List<HcmcLandmark> landmarks = [
    HcmcLandmark(
      name: 'Landmark 81 (Vinhomes Central Park)',
      address: '720A Điện Biên Phủ, Phường 22, Bình Thạnh',
      location: LatLng(10.7951, 106.7219),
      nearestStationId: 'l1_05',
      nearestStationName: 'Tân Cảng',
      distanceToStation: '450m',
      walkTime: '6 phút',
      icon: PhosphorIconsRegular.buildings,
    ),
    HcmcLandmark(
      name: 'Chợ Bến Thành',
      address: 'Đường Lê Lợi, Phường Bến Thành, Quận 1',
      location: LatLng(10.7725, 106.6980),
      nearestStationId: 'l1_01',
      nearestStationName: 'Bến Thành',
      distanceToStation: '50m',
      walkTime: '1 phút',
      icon: PhosphorIconsRegular.storefront,
    ),
    HcmcLandmark(
      name: 'Nhà hát Thành phố (Saigon Opera House)',
      address: '07 Công Trường Lam Sơn, Bến Nghé, Quận 1',
      location: LatLng(10.7767, 106.7032),
      nearestStationId: 'l1_02',
      nearestStationName: 'Nhà Hát TP',
      distanceToStation: '30m',
      walkTime: '1 phút',
      icon: PhosphorIconsRegular.bank,
    ),
    HcmcLandmark(
      name: 'Phố đi bộ Nguyễn Huệ',
      address: 'Nguyễn Huệ, Bến Nghé, Quận 1',
      location: LatLng(10.7745, 106.7042),
      nearestStationId: 'l1_02',
      nearestStationName: 'Nhà Hát TP',
      distanceToStation: '120m',
      walkTime: '2 phút',
      icon: PhosphorIconsRegular.footprints,
    ),
    HcmcLandmark(
      name: 'Thảo Cầm Viên Sài Gòn & Bảo tàng Lịch sử',
      address: '2 Nguyễn Bỉnh Khiêm, Bến Nghé, Quận 1',
      location: LatLng(10.7876, 106.7052),
      nearestStationId: 'l1_03',
      nearestStationName: 'Ba Son',
      distanceToStation: '350m',
      walkTime: '5 phút',
      icon: PhosphorIconsRegular.tree,
    ),
    HcmcLandmark(
      name: 'Bến Bạch Đằng & Buýt Sông Sài Gòn',
      address: 'Đường Tôn Đức Thắng, Bến Nghé, Quận 1',
      location: LatLng(10.7758, 106.7070),
      nearestStationId: 'l1_03',
      nearestStationName: 'Ba Son',
      distanceToStation: '300m',
      walkTime: '4 phút',
      icon: PhosphorIconsRegular.boat,
    ),
    HcmcLandmark(
      name: 'Thảo Điền Pearl & Khu phố Tây',
      address: '12 Quốc Hương, Thảo Điền, TP. Thủ Đức',
      location: LatLng(10.8035, 106.7320),
      nearestStationId: 'l1_06',
      nearestStationName: 'Thảo Điền',
      distanceToStation: '180m',
      walkTime: '2 phút',
      icon: PhosphorIconsRegular.coffee,
    ),
    HcmcLandmark(
      name: 'Vincom Mega Mall Thảo Điền',
      address: '161 Xa Lộ Hà Nội, Thảo Điền, TP. Thủ Đức',
      location: LatLng(10.8028, 106.7410),
      nearestStationId: 'l1_07',
      nearestStationName: 'An Phú',
      distanceToStation: '90m',
      walkTime: '1 phút',
      icon: PhosphorIconsRegular.shoppingBag,
    ),
    HcmcLandmark(
      name: 'Khu Công Nghệ Cao TP.HCM (SHTP)',
      address: 'Xa Lộ Hà Nội, Hiệp Phú, TP. Thủ Đức',
      location: LatLng(10.8540, 106.7860),
      nearestStationId: 'l1_12',
      nearestStationName: 'Khu Công Nghệ Cao',
      distanceToStation: '200m',
      walkTime: '3 phút',
      icon: PhosphorIconsRegular.cpu,
    ),
    HcmcLandmark(
      name: 'Đại Học Quốc Gia TP.HCM',
      address: 'Khu phố 6, Linh Trung, TP. Thủ Đức',
      location: LatLng(10.8710, 106.8020),
      nearestStationId: 'l1_13',
      nearestStationName: 'Đại Học Quốc Gia',
      distanceToStation: '250m',
      walkTime: '3 phút',
      icon: PhosphorIconsRegular.graduationCap,
    ),
    HcmcLandmark(
      name: 'Khu Du Lịch Văn Hóa Suối Tiên',
      address: '120 Xa Lộ Hà Nội, Tân Phú, TP. Thủ Đức',
      location: LatLng(10.8655, 106.8025),
      nearestStationId: 'l1_14',
      nearestStationName: 'Bến Xe Suối Tiên',
      distanceToStation: '150m',
      walkTime: '2 phút',
      icon: PhosphorIconsRegular.sunHorizon,
    ),
    HcmcLandmark(
      name: 'Bến Xe Miền Đông Mới',
      address: '501 Hoàng Hữu Nam, Long Bình, TP. Thủ Đức',
      location: LatLng(10.8805, 106.8180),
      nearestStationId: 'l1_14',
      nearestStationName: 'Bến Xe Suối Tiên',
      distanceToStation: '350m',
      walkTime: '4 phút',
      icon: PhosphorIconsRegular.bus,
    ),
  ];

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

    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });

    // Default select Ben Thanh
    _selectedStation = MetroMapData.line1Stations.first;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _trainService.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onStationTapped(MapStationPoint station) {
    setState(() {
      _selectedStation = station;
      _selectedLandmark = null;
      _isSearchFocused = false;
    });
    _searchFocusNode.unfocus();
    _mapController.move(station.location, 16.0);
  }

  void _onLandmarkTapped(HcmcLandmark landmark) {
    setState(() {
      _selectedLandmark = landmark;
      _searchController.text = landmark.name;
      _isSearchFocused = false;

      // Find nearest station object
      final allStations = _selectedLineId == 'line_1'
          ? MetroMapData.line1Stations
          : MetroMapData.line2Stations;
      try {
        _selectedStation = allStations.firstWhere(
          (s) => s.id == landmark.nearestStationId || s.name == landmark.nearestStationName,
        );
      } catch (_) {
        _selectedStation = null;
      }
    });
    _searchFocusNode.unfocus();
    _mapController.move(landmark.location, 16.2);
  }

  void _panToUserLocation() {
    _mapController.move(MetroMapData.userLocation, 16.0);
    setState(() {
      _selectedStation = MetroMapData.line1Stations.first;
      _selectedLandmark = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã định vị vị trí của bạn: Ga Trung tâm Bến Thành'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
    );
  }

  void _openStationDirectoryModal() {
    final allStations = _selectedLineId == 'line_1'
        ? MetroMapData.line1Stations
        : MetroMapData.line2Stations;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
                border: Border(
                  top: BorderSide(color: AppColors.borderSubtle, width: 1.5),
                ),
              ),
              child: Column(
                children: [
                  // Drag Handle
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Danh sách các ga Metro (${allStations.length})',
                              style: AppTypography.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              _selectedLineId == 'line_1'
                                  ? 'Tuyến 1: Bến Thành – Bến Xe Suối Tiên'
                                  : 'Tuyến 2: Bến Thành – Tham Lương',
                              style: AppTypography.textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          icon: const PhosphorIcon(PhosphorIconsRegular.x),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 16),

                  // Stations List
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: allStations.length,
                      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.xs),
                      itemBuilder: (context, index) {
                        final station = allStations[index];
                        final isSelected = _selectedStation?.id == station.id;

                        return MetroCard(
                          onTap: () {
                            Navigator.of(sheetContext).pop();
                            _onStationTapped(station);
                          },
                          backgroundColor: isSelected
                              ? AppColors.primary.withValues(alpha: 0.12)
                              : AppColors.surfaceSecondary,
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
                              Container(
                                width: 44,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary : AppColors.surface,
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                  border: Border.all(
                                    color: isSelected ? AppColors.primary : AppColors.border,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    station.code,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : AppColors.primaryText,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
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
                                    Text(
                                      station.isInterchange
                                          ? (station.transferInfo ?? 'Ga trung chuyển')
                                          : (index < 3 ? 'Ga ngầm' : 'Ga trên cao'),
                                      style: AppTypography.textTheme.bodySmall?.copyWith(
                                        color: station.isInterchange ? AppColors.warning : AppColors.textSecondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PhosphorIcon(
                                PhosphorIconsRegular.navigationArrow,
                                size: 16,
                                color: isSelected ? AppColors.primary : AppColors.textMuted,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Generate dynamic mock amenities surrounding the active station
  List<MapAmenityMarker> _generateSurroundingAmenities(MapStationPoint station) {
    final base = station.location;
    final markers = <MapAmenityMarker>[];

    // Parking (Bãi giữ xe)
    markers.add(
      MapAmenityMarker(
        name: 'Bãi giữ xe 24/7 Ga ${station.name}',
        location: LatLng(base.latitude + 0.0012, base.longitude + 0.0010),
        category: AmenityCategory.parking,
        distance: '40m',
      ),
    );

    // Bus Connection (Trạm xe buýt)
    markers.add(
      MapAmenityMarker(
        name: 'Trạm trung chuyển Bus Tuyến 03, 19, 150',
        location: LatLng(base.latitude - 0.0010, base.longitude + 0.0012),
        category: AmenityCategory.bus,
        distance: '60m',
      ),
    );

    // Dining / Cafe
    markers.add(
      MapAmenityMarker(
        name: 'Highlands Coffee & 7-Eleven Ga ${station.name}',
        location: LatLng(base.latitude + 0.0015, base.longitude - 0.0014),
        category: AmenityCategory.dining,
        distance: '80m',
      ),
    );

    // ATM / Bank
    markers.add(
      MapAmenityMarker(
        name: 'Cụm ATM Vietcombank, BIDV, MB',
        location: LatLng(base.latitude - 0.0012, base.longitude - 0.0011),
        category: AmenityCategory.atm,
        distance: '30m',
      ),
    );

    if (_selectedAmenityCategory == null) {
      return markers;
    }
    return markers.where((m) => m.category == _selectedAmenityCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final allStations = _selectedLineId == 'line_1'
        ? MetroMapData.line1Stations
        : MetroMapData.line2Stations;

    // Filter landmarks & stations based on search query
    final query = _searchQuery.trim().toLowerCase();
    final matchingLandmarks = landmarks.where((l) {
      if (query.isEmpty) return true;
      return l.name.toLowerCase().contains(query) || l.address.toLowerCase().contains(query);
    }).toList();

    final matchingStations = allStations.where((s) {
      if (query.isEmpty) return true;
      return s.name.toLowerCase().contains(query) || s.code.toLowerCase().contains(query);
    }).toList();

    final surroundingAmenities = _selectedStation != null
        ? _generateSurroundingAmenities(_selectedStation!)
        : <MapAmenityMarker>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. FULLSCREEN INTERACTIVE OPENSTREETMAP
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: const MapOptions(
                initialCenter: LatLng(10.7719, 106.6983), // Ben Thanh
                initialZoom: 15.0,
                minZoom: 11.0,
                maxZoom: 18.5,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.metrogo.hcmc.app',
                ),

                // Metro Track Polylines
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: MetroMapData.line1Polyline,
                      strokeWidth: 5.5,
                      color: AppColors.primary,
                    ),
                    Polyline(
                      points: MetroMapData.line2Polyline,
                      strokeWidth: 4.5,
                      color: const Color(0xFF10B981).withValues(alpha: 0.7),
                    ),
                    // If landmark selected, draw subtle walking dotted line to nearest station
                    if (_selectedLandmark != null && _selectedStation != null)
                      Polyline(
                        points: [
                          _selectedLandmark!.location,
                          _selectedStation!.location,
                        ],
                        strokeWidth: 2.5,
                        color: AppColors.warning,
                      ),
                  ],
                ),

                // Surrounding Amenities Markers
                MarkerLayer(
                  markers: surroundingAmenities.map((amenity) {
                    IconData iconData;
                    Color color;
                    switch (amenity.category) {
                      case AmenityCategory.parking:
                        iconData = PhosphorIconsFill.car;
                        color = const Color(0xFF3B82F6);
                        break;
                      case AmenityCategory.bus:
                        iconData = PhosphorIconsFill.bus;
                        color = const Color(0xFF10B981);
                        break;
                      case AmenityCategory.dining:
                        iconData = PhosphorIconsFill.coffee;
                        color = const Color(0xFFF59E0B);
                        break;
                      case AmenityCategory.atm:
                        iconData = PhosphorIconsFill.bank;
                        color = const Color(0xFF8B5CF6);
                        break;
                      default:
                        iconData = PhosphorIconsFill.mapPin;
                        color = AppColors.primary;
                    }

                    return Marker(
                      point: amenity.location,
                      width: 32,
                      height: 32,
                      child: Tooltip(
                        message: '${amenity.name} (${amenity.distance})',
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              iconData,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                // Metro Station Markers
                MarkerLayer(
                  markers: allStations.map((station) {
                    final isSelected = _selectedStation?.id == station.id;
                    return Marker(
                      point: station.location,
                      width: isSelected ? 46 : 30,
                      height: isSelected ? 46 : 30,
                      child: GestureDetector(
                        onTap: () => _onStationTapped(station),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.warning : AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: isSelected ? 2.5 : 2),
                            boxShadow: [
                              BoxShadow(
                                color: (isSelected ? AppColors.warning : AppColors.primary)
                                    .withValues(alpha: 0.5),
                                blurRadius: isSelected ? 10 : 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: PhosphorIcon(
                              PhosphorIconsFill.train,
                              size: isSelected ? 22 : 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                // Selected Landmark Pin Marker
                if (_selectedLandmark != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selectedLandmark!.location,
                        width: 44,
                        height: 44,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: const PhosphorIcon(
                                PhosphorIconsFill.mapPin,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                // Realtime Moving Trains
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
          ),

          // 2. FLOATING TOP BAR & ADDRESS SEARCH (WITH AMENITIES FILTERS)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search Bar Card
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: _isSearchFocused ? AppColors.primary : AppColors.borderSubtle,
                          width: _isSearchFocused ? 1.5 : 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          if (widget.showBackButton)
                            IconButton(
                              icon: const PhosphorIcon(PhosphorIconsRegular.arrowLeft),
                              onPressed: () => Navigator.of(context).pop(),
                            )
                          else
                            const Padding(
                              padding: EdgeInsets.only(left: 12, right: 8),
                              child: PhosphorIcon(
                                PhosphorIconsRegular.magnifyingGlass,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              decoration: InputDecoration(
                                hintText: 'Tìm địa chỉ, địa điểm xung quanh, tên ga...',
                                hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textMuted,
                                  fontSize: 13,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              style: AppTypography.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              onChanged: (val) {
                                setState(() {
                                  _searchQuery = val;
                                });
                              },
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            IconButton(
                              icon: const PhosphorIcon(
                                PhosphorIconsRegular.xCircle,
                                size: 18,
                                color: AppColors.textMuted,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _selectedLandmark = null;
                                });
                              },
                            ),
                          const ScreenSwitcherButton(),
                          const SizedBox(width: 4),
                        ],
                      ),
                    ),

                    // Autocomplete Suggestions Dropdown
                    if (_isSearchFocused) ...[
                      const SizedBox(height: 6),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 280),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(color: AppColors.borderSubtle),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          child: Material(
                            color: AppColors.surface,
                            child: ListView(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            children: [
                              // Section: Matching Metro Stations
                              if (matchingStations.isNotEmpty) ...[
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                  child: Text(
                                    'NHÀ GA METRO',
                                    style: TextStyle(
                                      color: AppColors.primaryText,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                                ...matchingStations.take(4).map((station) {
                                  return ListTile(
                                    dense: true,
                                    leading: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryLight,
                                        borderRadius: BorderRadius.circular(AppRadius.sm),
                                      ),
                                      child: const PhosphorIcon(
                                        PhosphorIconsRegular.train,
                                        color: AppColors.primary,
                                        size: 16,
                                      ),
                                    ),
                                    title: Text(
                                      'Ga ${station.name}',
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                    ),
                                    subtitle: Text(
                                      station.code,
                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                    ),
                                    onTap: () => _onStationTapped(station),
                                  );
                                }),
                              ],

                              // Section: Prominent HCMC Landmarks & Nearby Stations
                              if (matchingLandmarks.isNotEmpty) ...[
                                const Divider(height: 8),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                  child: Text(
                                    'ĐỊA ĐIỂM XUNG QUANH TUYẾN',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                                ...matchingLandmarks.take(5).map((l) {
                                  return ListTile(
                                    dense: true,
                                    leading: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceSecondary,
                                        borderRadius: BorderRadius.circular(AppRadius.sm),
                                      ),
                                      child: PhosphorIcon(
                                        l.icon,
                                        color: AppColors.textPrimary,
                                        size: 16,
                                      ),
                                    ),
                                    title: Text(
                                      l.name,
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                    ),
                                    subtitle: Text(
                                      'Gần Ga ${l.nearestStationName} • ${l.distanceToStation} (${l.walkTime} đi bộ)',
                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                    ),
                                    onTap: () => _onLandmarkTapped(l),
                                  );
                                }),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],

                    const SizedBox(height: 8),

                    // Surrounding Amenities Horizontal Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildAmenityChip(
                            title: 'Tất cả tiện ích',
                            icon: PhosphorIconsRegular.squaresFour,
                            isSelected: _selectedAmenityCategory == null,
                            onTap: () => setState(() => _selectedAmenityCategory = null),
                          ),
                          const SizedBox(width: 6),
                          _buildAmenityChip(
                            title: 'Bãi giữ xe',
                            icon: PhosphorIconsRegular.car,
                            isSelected: _selectedAmenityCategory == AmenityCategory.parking,
                            onTap: () => setState(() => _selectedAmenityCategory = AmenityCategory.parking),
                          ),
                          const SizedBox(width: 6),
                          _buildAmenityChip(
                            title: 'Xe buýt kết nối',
                            icon: PhosphorIconsRegular.bus,
                            isSelected: _selectedAmenityCategory == AmenityCategory.bus,
                            onTap: () => setState(() => _selectedAmenityCategory = AmenityCategory.bus),
                          ),
                          const SizedBox(width: 6),
                          _buildAmenityChip(
                            title: 'Ăn uống & Cà phê',
                            icon: PhosphorIconsRegular.coffee,
                            isSelected: _selectedAmenityCategory == AmenityCategory.dining,
                            onTap: () => setState(() => _selectedAmenityCategory = AmenityCategory.dining),
                          ),
                          const SizedBox(width: 6),
                          _buildAmenityChip(
                            title: 'ATM & Tiện ích',
                            icon: PhosphorIconsRegular.bank,
                            isSelected: _selectedAmenityCategory == AmenityCategory.atm,
                            onTap: () => setState(() => _selectedAmenityCategory = AmenityCategory.atm),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. FLOATING RIGHT CONTROLS: LINE SWITCHER, ZOOM & GPS
          Positioned(
            right: 14,
            top: 150,
            child: Column(
              children: [
                // Line Toggle Chip (Tuyến 1 / Tuyến 2)
                GestureDetector(
                  onTap: () {
                    final newLine = _selectedLineId == 'line_1' ? 'line_2' : 'line_1';
                    setState(() {
                      _selectedLineId = newLine;
                      _selectedStation = newLine == 'line_1'
                          ? MetroMapData.line1Stations.first
                          : MetroMapData.line2Stations.first;
                      _selectedLandmark = null;
                    });
                    if (newLine == 'line_1') {
                      _mapController.move(const LatLng(10.8050, 106.7400), 13.0);
                    } else {
                      _mapController.move(const LatLng(10.7980, 106.6600), 13.5);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(
                        color: _selectedLineId == 'line_1' ? AppColors.primary : const Color(0xFF10B981),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _selectedLineId == 'line_1' ? AppColors.primary : const Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _selectedLineId == 'line_1' ? 'Tuyến 1' : 'Tuyến 2',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: _selectedLineId == 'line_1' ? AppColors.primary : const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Zoom in
                _buildMapCircleButton(
                  icon: PhosphorIconsBold.plus,
                  onTap: () {
                    final zoom = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, zoom + 1);
                  },
                ),
                const SizedBox(height: 6),

                // Zoom out
                _buildMapCircleButton(
                  icon: PhosphorIconsBold.minus,
                  onTap: () {
                    final zoom = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, zoom - 1);
                  },
                ),
                const SizedBox(height: 6),

                // Recenter GPS
                _buildMapCircleButton(
                  icon: PhosphorIconsBold.crosshair,
                  onTap: _panToUserLocation,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),

          // 4. FLOATING BOTTOM CARD: SELECTED STATION DETAILS & SURROUNDING AMENITIES
          Positioned(
            bottom: 16,
            left: 14,
            right: 14,
            child: _buildBottomStationCard(context),
          ),
        ],
      ),
    );
  }

  // Amenity Pill
  Widget _buildAmenityChip({
    required String title,
    required PhosphorIconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderSubtle,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PhosphorIcon(
              icon,
              size: 13,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
            const SizedBox(width: 5),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Floating Bottom Card with Station details & action shortcuts
  Widget _buildBottomStationCard(BuildContext context) {
    final station = _selectedStation;
    final landmark = _selectedLandmark;

    if (station == null && landmark == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const PhosphorIcon(PhosphorIconsRegular.mapPin, color: AppColors.primary, size: 20),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Chạm vào nhà ga hoặc tìm kiếm để xem thông tin',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: _openStationDirectoryModal,
              child: const Text('Xem danh sách ga'),
            ),
          ],
        ),
      );
    }

    final stationName = station?.name ?? landmark?.nearestStationName ?? 'Bến Thành';
    final stationCode = station?.code ?? 'L1';
    final isInterchange = station?.isInterchange ?? false;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.borderSubtle, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Landmark notice if selected
          if (landmark != null) ...[
            Row(
              children: [
                const PhosphorIcon(PhosphorIconsFill.mapPin, color: Color(0xFFEF4444), size: 14),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    landmark.name,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    'Cách ga ${landmark.distanceToStation} • ${landmark.walkTime}',
                    style: const TextStyle(
                      color: AppColors.warning,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 12),
          ],

          // Station Title & Badges
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Center(
                  child: Text(
                    stationCode,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Ga $stationName',
                            style: AppTypography.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isInterchange) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: const Text(
                              'TRUNG CHUYỂN',
                              style: TextStyle(
                                color: AppColors.warning,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _selectedLineId == 'line_1'
                          ? 'Tuyến 1 (Bến Thành – Suối Tiên) • Tàu kế tiếp: 3 phút'
                          : 'Tuyến 2 (Bến Thành – Tham Lương)',
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              // Close button
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedStation = null;
                    _selectedLandmark = null;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    shape: BoxShape.circle,
                  ),
                  child: const PhosphorIcon(
                    PhosphorIconsRegular.x,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Action Shortcuts Row
          Row(
            children: [
              // Tiện ích quanh ga
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  onPressed: () {
                    StationAmenitiesSheet.show(
                      context,
                      initialStationName: stationName,
                    );
                  },
                  icon: const PhosphorIcon(
                    PhosphorIconsRegular.compass,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  label: const Text(
                    'Tiện ích quanh ga',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              // Danh sách 14 ga
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  onPressed: _openStationDirectoryModal,
                  icon: const PhosphorIcon(
                    PhosphorIconsRegular.listBullets,
                    size: 16,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Danh sách các ga',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
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
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: PhosphorIcon(
            icon,
            size: 18,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
