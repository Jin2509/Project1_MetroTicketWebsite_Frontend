import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../theme/app_theme.dart';
import 'metro_card.dart';

/// Category of station amenities
enum AmenityCategory {
  parking,
  bus,
  dining,
  atm,
  accessibility,
}

class StationAmenityItem {
  final String name;
  final String description;
  final AmenityCategory category;
  final String distance;
  final PhosphorIconData icon;

  const StationAmenityItem({
    required this.name,
    required this.description,
    required this.category,
    required this.distance,
    required this.icon,
  });
}

/// StationAmenitiesSheet:
/// Interactive sheet for exploring nearby amenities (parking, bus connections, dining, ATMs)
/// and station operational details across Metro Line 1 & Line 2.
class StationAmenitiesSheet extends StatefulWidget {
  final String? initialStationName;
  final bool openDirectoryMode;

  const StationAmenitiesSheet({
    super.key,
    this.initialStationName,
    this.openDirectoryMode = false,
  });

  static void show(
    BuildContext context, {
    String? initialStationName,
    bool openDirectoryMode = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StationAmenitiesSheet(
        initialStationName: initialStationName,
        openDirectoryMode: openDirectoryMode,
      ),
    );
  }

  @override
  State<StationAmenitiesSheet> createState() => _StationAmenitiesSheetState();
}

class _StationAmenitiesSheetState extends State<StationAmenitiesSheet> {
  late String _selectedStation;
  AmenityCategory _selectedCategory = AmenityCategory.parking;
  final String _searchFilter = '';

  static const List<String> _stationList = [
    'Bến Thành',
    'Nhà Hát TP',
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

  static const Map<String, List<StationAmenityItem>> _mockStationAmenities = {
    'Bến Thành': [
      StationAmenityItem(
        name: 'Bãi giữ xe ngầm Ga Bến Thành',
        description: 'Sức chứa 600 xe máy, 80 ô tô • 24/7 • Có trạm sạc xe điện',
        category: AmenityCategory.parking,
        distance: 'Trong khuôn viên ga',
        icon: PhosphorIconsBold.car,
      ),
      StationAmenityItem(
        name: 'Trạm trung chuyển xe buýt Hàm Nghi',
        description: 'Kết nối 28 tuyến buýt nội thành (Tuyến 01, 03, 04, 19, 56...)',
        category: AmenityCategory.bus,
        distance: 'Cách 80m (Cửa số 1)',
        icon: PhosphorIconsBold.bus,
      ),
      StationAmenityItem(
        name: 'Tuyến buýt điện D4 (VinBus)',
        description: 'Bến Thành – Vinhomes Grand Park (Tần suất 10 phút/chuyến)',
        category: AmenityCategory.bus,
        distance: 'Cửa số 2',
        icon: PhosphorIconsBold.lightning,
      ),
      StationAmenityItem(
        name: 'Highlands Coffee & Phúc Long Tea',
        description: 'Tầng B1 trung tâm thương mại ngầm ga',
        category: AmenityCategory.dining,
        distance: 'Tầng B1',
        icon: PhosphorIconsBold.coffee,
      ),
      StationAmenityItem(
        name: 'Cửa hàng tiện lợi 7-Eleven & Circle K',
        description: 'Mở cửa 24/7 • Nước uống, đồ ăn nhanh & sạc dự phòng',
        category: AmenityCategory.dining,
        distance: 'Sảnh chính B1',
        icon: PhosphorIconsBold.storefront,
      ),
      StationAmenityItem(
        name: 'Cụm ATM Vietcombank, Techcombank, BIDV',
        description: 'Rút tiền, nạp tiền tự động CDM • Hoạt động 24/7',
        category: AmenityCategory.atm,
        distance: 'Cửa số 3',
        icon: PhosphorIconsBold.creditCard,
      ),
      StationAmenityItem(
        name: 'Thang máy ưu tiên & WC tiếp cận',
        description: 'Dành riêng cho người khuyết tật, người già và trẻ nhỏ',
        category: AmenityCategory.accessibility,
        distance: 'Tại tất cả các cửa',
        icon: PhosphorIconsBold.wheelchair,
      ),
    ],
  };

  List<StationAmenityItem> _getAmenitiesForStation(String stationName) {
    if (_mockStationAmenities.containsKey(stationName)) {
      return _mockStationAmenities[stationName]!;
    }
    return [
      StationAmenityItem(
        name: 'Bãi giữ xe ga $stationName',
        description: 'Trông giữ xe máy ngày đêm • Có camera giám sát',
        category: AmenityCategory.parking,
        distance: 'Cạnh lối lên ga',
        icon: PhosphorIconsBold.motorcycle,
      ),
      StationAmenityItem(
        name: 'Trạm xe buýt kết nối ga $stationName',
        description: 'Các tuyến buýt gom kết nối khu dân cư lân cận',
        category: AmenityCategory.bus,
        distance: 'Cách 50m',
        icon: PhosphorIconsBold.bus,
      ),
      StationAmenityItem(
        name: 'Cửa hàng tiện ích & Cà phê mang đi',
        description: 'Cung cấp nước giải khát, bánh mì & nạp tiền thẻ',
        category: AmenityCategory.dining,
        distance: 'Sảnh tầng 1',
        icon: PhosphorIconsBold.coffee,
      ),
      StationAmenityItem(
        name: 'Cây rút tiền tự động ATM',
        description: 'ATM liên minh Napas chấp nhận tất cả ngân hàng',
        category: AmenityCategory.atm,
        distance: 'Khu vực bán vé',
        icon: PhosphorIconsBold.creditCard,
      ),
      StationAmenityItem(
        name: 'Thang máy & Lối đi cho người khuyết tật',
        description: 'Trang bị gạch dẫn hướng cho người khiếm thị',
        category: AmenityCategory.accessibility,
        distance: 'Lối vào chính',
        icon: PhosphorIconsBold.wheelchair,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _selectedStation = widget.initialStationName ?? _stationList.first;
    if (!_stationList.contains(_selectedStation)) {
      _selectedStation = _stationList.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final amenities = _getAmenitiesForStation(_selectedStation).where((item) {
      final matchesCat = item.category == _selectedCategory;
      if (_searchFilter.isEmpty) return matchesCat;
      final q = _searchFilter.toLowerCase();
      return item.name.toLowerCase().contains(q) ||
          item.description.toLowerCase().contains(q);
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderMedium,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: PhosphorIcon(
                        widget.openDirectoryMode
                            ? PhosphorIconsBold.buildings
                            : PhosphorIconsBold.storefront,
                        color: AppColors.primaryText,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.openDirectoryMode
                              ? 'Tra cứu thông tin nhà ga'
                              : 'Tiện ích quanh ga Metro',
                          style: AppTypography.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Tuyến 1 (Bến Thành – Suối Tiên)',
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const PhosphorIcon(
                    PhosphorIconsRegular.x,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Station selector dropdown pill
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
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
                    'Chọn ga:',
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedStation,
                        isExpanded: true,
                        dropdownColor: AppColors.surfaceSecondary,
                        icon: const PhosphorIcon(
                          PhosphorIconsBold.caretDown,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        items: _stationList.map((st) {
                          return DropdownMenuItem<String>(
                            value: st,
                            child: Text('Ga $st'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedStation = val);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Station Quick Glance Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildGlanceInfo(
                    PhosphorIconsRegular.clock,
                    'Giờ mở cửa',
                    '05:00 - 22:00',
                  ),
                  Container(width: 1, height: 28, color: AppColors.borderSubtle),
                  _buildGlanceInfo(
                    PhosphorIconsRegular.timer,
                    'Tần suất tàu',
                    '4.5 - 6 phút',
                  ),
                  Container(width: 1, height: 28, color: AppColors.borderSubtle),
                  _buildGlanceInfo(
                    PhosphorIconsRegular.door,
                    'Cửa ra vào',
                    _selectedStation == 'Bến Thành' ? '6 cửa' : '4 cửa',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Category filter tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                _buildCategoryTab(
                  AmenityCategory.parking,
                  'Bãi giữ xe',
                  PhosphorIconsBold.car,
                ),
                const SizedBox(width: AppSpacing.xs),
                _buildCategoryTab(
                  AmenityCategory.bus,
                  'Xe buýt gom',
                  PhosphorIconsBold.bus,
                ),
                const SizedBox(width: AppSpacing.xs),
                _buildCategoryTab(
                  AmenityCategory.dining,
                  'Ẩm thực & Cà phê',
                  PhosphorIconsBold.coffee,
                ),
                const SizedBox(width: AppSpacing.xs),
                _buildCategoryTab(
                  AmenityCategory.atm,
                  'ATM / Ngân hàng',
                  PhosphorIconsBold.creditCard,
                ),
                const SizedBox(width: AppSpacing.xs),
                _buildCategoryTab(
                  AmenityCategory.accessibility,
                  'Hỗ trợ tiếp cận',
                  PhosphorIconsBold.wheelchair,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),
          const Divider(height: 1, color: AppColors.borderSubtle),

          // Amenities List
          Expanded(
            child: amenities.isEmpty
                ? Center(
                    child: Text(
                      'Không có tiện ích nào trong danh mục này',
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: amenities.length,
                    separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final item = amenities[index];
                      return MetroCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        backgroundColor: AppColors.surfaceSecondary,
                        borderRadius: AppRadius.md,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                              ),
                              child: Center(
                                child: PhosphorIcon(
                                  item.icon,
                                  color: AppColors.primaryText,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.name,
                                          style: AppTypography.textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.successLight,
                                          borderRadius: BorderRadius.circular(AppRadius.sm),
                                        ),
                                        child: Text(
                                          item.distance,
                                          style: const TextStyle(
                                            color: AppColors.successText,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.description,
                                    style: AppTypography.textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
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
    );
  }

  Widget _buildGlanceInfo(PhosphorIconData icon, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PhosphorIcon(icon, size: 12, color: AppColors.primaryText),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTab(
    AmenityCategory category,
    String title,
    PhosphorIconData icon,
  ) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderSubtle,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PhosphorIcon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              title,
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
}
