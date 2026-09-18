import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

/// Bus route connection available at/near a metro station
class BusConnection {
  final String routeNumber;
  final String routeName;
  final String operatingHours;
  final String frequency;
  final String fare;
  final String busStopLocation;
  final bool isElectric;
  final List<String> keyStops;
  final String connectingStation;

  const BusConnection({
    required this.routeNumber,
    required this.routeName,
    required this.operatingHours,
    required this.frequency,
    required this.fare,
    required this.busStopLocation,
    this.isElectric = false,
    required this.keyStops,
    required this.connectingStation,
  });
}

/// Category for station points of interest & entertainment
enum DestinationCategory {
  entertainment,
  shopping,
  dining,
  culture,
}

extension DestinationCategoryExt on DestinationCategory {
  String get label {
    switch (this) {
      case DestinationCategory.entertainment:
        return 'Vui chơi & Giải trí';
      case DestinationCategory.shopping:
        return 'Mua sắm';
      case DestinationCategory.dining:
        return 'Ẩm thực & Cafe';
      case DestinationCategory.culture:
        return 'Văn hóa & Di tích';
    }
  }

  PhosphorIconData get icon {
    switch (this) {
      case DestinationCategory.entertainment:
        return PhosphorIconsRegular.confetti;
      case DestinationCategory.shopping:
        return PhosphorIconsRegular.shoppingBag;
      case DestinationCategory.dining:
        return PhosphorIconsRegular.coffee;
      case DestinationCategory.culture:
        return PhosphorIconsRegular.buildings;
    }
  }

  Color get color {
    switch (this) {
      case DestinationCategory.entertainment:
        return const Color(0xFFDB2777); // Pink
      case DestinationCategory.shopping:
        return const Color(0xFFF97316); // Orange
      case DestinationCategory.dining:
        return const Color(0xFF10B981); // Green
      case DestinationCategory.culture:
        return const Color(0xFF6366F1); // Indigo
    }
  }
}

/// Popular destination, entertainment spot or attraction accessible from a metro station
class StationDestination {
  final String id;
  final String name;
  final DestinationCategory category;
  final String stationName;
  final String distance;
  final String walkTime;
  final String exitGate;
  final String description;
  final double rating;
  final List<String> highlights;
  final PhosphorIconData icon;

  const StationDestination({
    required this.id,
    required this.name,
    required this.category,
    required this.stationName,
    required this.distance,
    required this.walkTime,
    required this.exitGate,
    required this.description,
    required this.rating,
    required this.highlights,
    required this.icon,
  });
}

/// Repository of realistic Bus connections & Destinations across Metro Line 1
class StationConnectionsData {
  static const List<BusConnection> allBusConnections = [
    // Ga Bến Thành
    BusConnection(
      routeNumber: '01',
      routeName: 'Bến Thành – Bến xe Chợ Lớn',
      operatingHours: '05:00 – 21:00',
      frequency: '5 – 8 phút/chuyến',
      fare: '5.000 – 7.000 đ',
      busStopLocation: 'Cửa số 1 - Trạm trung chuyển Hàm Nghi (cách 80m)',
      keyStops: ['Hàm Nghi', 'Trần Hưng Đạo', 'Nguyễn Tri Phương', 'Chợ Lớn'],
      connectingStation: 'Bến Thành',
    ),
    BusConnection(
      routeNumber: '19',
      routeName: 'Bến Thành – KCX Linh Trung – ĐHQG TP.HCM',
      operatingHours: '05:00 – 21:15',
      frequency: '6 – 10 phút/chuyến',
      fare: '7.000 đ (HSSV 3.000 đ)',
      busStopLocation: 'Cửa số 1 - Bến xe buýt Hàm Nghi',
      keyStops: ['Hàm Nghi', 'Đinh Tiên Hoàng', 'Xa Lộ Hà Nội', 'ĐHQG'],
      connectingStation: 'Bến Thành',
    ),
    BusConnection(
      routeNumber: '56',
      routeName: 'Bến Thành – Chợ Lớn – ĐH Giao Thông Vận Tải',
      operatingHours: '05:00 – 21:00',
      frequency: '7 – 10 phút/chuyến',
      fare: '6.000 – 7.000 đ',
      busStopLocation: 'Cửa số 2 - Đường Lê Lai',
      keyStops: ['Lê Lai', 'Trần Hưng Đạo', 'Hải Thượng Lãn Ông', 'ĐH GTVT'],
      connectingStation: 'Bến Thành',
    ),
    BusConnection(
      routeNumber: 'D4',
      routeName: 'VinBus: Bến Thành – Vinhomes Grand Park',
      operatingHours: '05:00 – 22:00',
      frequency: '10 – 12 phút/chuyến',
      fare: '7.000 đ (Xe điện thông minh)',
      busStopLocation: 'Cửa số 2 - Trạm xe điện VinBus Lê Lai',
      isElectric: true,
      keyStops: ['Bến Thành', 'Cầu Thủ Thiêm 2', 'Mai Chí Thọ', 'Vinhomes Grand Park'],
      connectingStation: 'Bến Thành',
    ),

    // Ga Nhà Hát Thành Phố
    BusConnection(
      routeNumber: '03',
      routeName: 'Bến Thành – Thạnh Lộc (Quận 12)',
      operatingHours: '05:15 – 20:45',
      frequency: '8 – 10 phút/chuyến',
      fare: '6.000 đ',
      busStopLocation: 'Cửa số 1 - Đường Hai Bà Trưng (cách 60m)',
      keyStops: ['Đồng Khởi', 'Hai Bà Trưng', 'Phan Đăng Lưu', 'Ngã tư Ga'],
      connectingStation: 'Nhà Hát Thành Phố',
    ),

    // Ga Ba Son
    BusConnection(
      routeNumber: 'WaterBus',
      routeName: 'Tuyến buýt sông Sài Gòn: Bạch Đằng – Linh Đông',
      operatingHours: '07:00 – 19:30',
      frequency: '30 – 45 phút/chuyến',
      fare: '15.000 đ/lượt',
      busStopLocation: 'Lối ra Cửa số 1 - Bến tàu thủy Ba Son (cách 200m)',
      keyStops: ['Bến Bạch Đằng', 'Bến Ba Son', 'Bến Thanh Đa', 'Bến Linh Đông'],
      connectingStation: 'Ba Son',
    ),

    // Ga Tân Cảng
    BusConnection(
      routeNumber: '30',
      routeName: 'Chợ Tân Hương – Cư xá Nhiêu Lộc',
      operatingHours: '05:15 – 19:30',
      frequency: '10 phút/chuyến',
      fare: '6.000 đ',
      busStopLocation: 'Trạm chân cầu Sài Gòn (cách lối lên ga 120m)',
      keyStops: ['Cư xá Thanh Đa', 'Điện Biên Phủ', 'Võ Thị Sáu', 'Tân Hương'],
      connectingStation: 'Tân Cảng',
    ),
    BusConnection(
      routeNumber: '56',
      routeName: 'Bến Thành – ĐH GTVT (Kết nối Vinhomes Central Park)',
      operatingHours: '05:00 – 21:00',
      frequency: '8 phút/chuyến',
      fare: '7.000 đ',
      busStopLocation: 'Lối đi bộ sang cổng Landmark 81',
      keyStops: ['Điện Biên Phủ', 'Landmark 81', 'Khu du lịch Văn Thánh'],
      connectingStation: 'Tân Cảng',
    ),

    // Ga Thảo Điền & An Phú
    BusConnection(
      routeNumber: '06',
      routeName: 'Bến xe Chợ Lớn – Đại học Nông Lâm',
      operatingHours: '04:55 – 21:00',
      frequency: '6 – 8 phút/chuyến',
      fare: '7.000 đ',
      busStopLocation: 'Trạm Xa Lộ Hà Nội ngay chân cầu bộ hành ga Thảo Điền',
      keyStops: ['Chợ Lớn', 'Hồng Bàng', 'Xa Lộ Hà Nội', 'ĐH Nông Lâm'],
      connectingStation: 'Thảo Điền',
    ),
    BusConnection(
      routeNumber: '43',
      routeName: 'Bến xe Miền Đông – Phà Cát Lái',
      operatingHours: '05:30 – 19:30',
      frequency: '12 – 15 phút/chuyến',
      fare: '6.000 đ',
      busStopLocation: 'Lối ra Cửa số 2 ga An Phú (cạnh Estella Place)',
      keyStops: ['Đinh Bộ Lĩnh', 'Mai Chí Thọ', 'Đồng Văn Cống', 'Phà Cát Lái'],
      connectingStation: 'An Phú',
    ),

    // Ga Đại Học Quốc Gia
    BusConnection(
      routeNumber: '53',
      routeName: 'Lê Hồng Phong – Đại học Quốc Gia TP.HCM',
      operatingHours: '05:00 – 19:45',
      frequency: '7 – 10 phút/chuyến',
      fare: '7.000 đ (HSSV 3.000 đ)',
      busStopLocation: 'Trạm xe buýt nội bộ ĐHQG (cách cửa ga 100m)',
      keyStops: ['Lê Hồng Phong', 'Nguyễn Thị Minh Khai', 'KTX Khu B', 'ĐH Bách Khoa'],
      connectingStation: 'Đại Học Quốc Gia',
    ),
    BusConnection(
      routeNumber: '33',
      routeName: 'Bến xe An Sương – Đại học Quốc Gia',
      operatingHours: '04:45 – 21:00',
      frequency: '6 – 8 phút/chuyến',
      fare: '7.000 đ',
      busStopLocation: 'Trạm trung chuyển Xa Lộ Hà Nội',
      keyStops: ['An Sương', 'Quốc Lộ 1A', 'Nông Lâm', 'ĐHQG'],
      connectingStation: 'Đại Học Quốc Gia',
    ),

    // Ga Bến Xe Suối Tiên (Miền Đông Mới)
    BusConnection(
      routeNumber: '150',
      routeName: 'Bến xe Chợ Lớn – Ngã 3 Tân Vạn',
      operatingHours: '04:30 – 21:30',
      frequency: '4 – 7 phút/chuyến',
      fare: '7.000 đ',
      busStopLocation: 'Cầu vượt bộ hành Ga Suối Tiên nối thẳng sang trạm buýt',
      keyStops: ['Chợ Lớn', 'Điện Biên Phủ', 'KDL Suối Tiên', 'Ngã 3 Tân Vạn'],
      connectingStation: 'Suối Tiên',
    ),
    BusConnection(
      routeNumber: '93',
      routeName: 'Bến Thành – Đại học Nông Lâm (Qua KDL Suối Tiên)',
      operatingHours: '05:15 – 19:30',
      frequency: '10 – 12 phút/chuyến',
      fare: '7.000 đ',
      busStopLocation: 'Trạm đón đối diện cổng chính Suối Tiên (cách 100m)',
      keyStops: ['Bến Thành', 'Hàng Xanh', 'Suối Tiên', 'ĐH Nông Lâm'],
      connectingStation: 'Suối Tiên',
    ),
    BusConnection(
      routeNumber: '76',
      routeName: 'Long Phước – Bến xe Miền Đông Mới (Ga Suối Tiên)',
      operatingHours: '05:00 – 19:00',
      frequency: '12 – 15 phút/chuyến',
      fare: '6.000 đ',
      busStopLocation: 'Sảnh đón xe buýt Bến xe Miền Đông Mới',
      keyStops: ['Long Phước', 'Nguyễn Xiển', 'Hoàng Hữu Nam', 'BX Miền Đông Mới'],
      connectingStation: 'Suối Tiên',
    ),
  ];

  static const List<StationDestination> allDestinations = [
    // Ga Bến Thành
    StationDestination(
      id: 'dest_bt_01',
      name: 'Chợ Bến Thành & Chợ Đêm',
      category: DestinationCategory.culture,
      stationName: 'Bến Thành',
      distance: '100m',
      walkTime: '1 phút',
      exitGate: 'Lối ra Cửa số 1 (Đường Phan Chu Trinh)',
      description: 'Biểu tượng lịch sử hơn 100 năm của TP.HCM, thiên đường ẩm thực đường phố, quà lưu niệm và đặc sản truyền thống.',
      rating: 4.7,
      highlights: ['Biểu tượng Sài Gòn', 'Đặc sản ẩm thực', 'Chợ đêm sôi động'],
      icon: PhosphorIconsRegular.storefront,
    ),
    StationDestination(
      id: 'dest_bt_02',
      name: 'Phố đi bộ Nguyễn Huệ',
      category: DestinationCategory.entertainment,
      stationName: 'Bến Thành',
      distance: '350m',
      walkTime: '4 phút',
      exitGate: 'Lối ra Cửa số 2 hoặc 3 (Đường Lê Lợi)',
      description: 'Quảng trường đi bộ trung tâm thành phố, điểm check-in nghệ thuật công cộng, phun nước ánh sáng và các lễ hội đường phố náo nhiệt.',
      rating: 4.9,
      highlights: ['Quảng trường ánh sáng', 'Biểu diễn đường phố', 'Quán cafe Chung cư 42'],
      icon: PhosphorIconsRegular.sparkle,
    ),
    StationDestination(
      id: 'dest_bt_03',
      name: 'TTTM Takashimaya & Saigon Centre',
      category: DestinationCategory.shopping,
      stationName: 'Bến Thành',
      distance: '250m',
      walkTime: '3 phút',
      exitGate: 'Lối ra Cửa số 3 (Đường Nam Kỳ Khởi Nghĩa)',
      description: 'Thiên đường mua sắm thương hiệu quốc tế cao cấp, tầng hầm ẩm thực Nhật Bản, Hàn Quốc và cà phê thời thượng.',
      rating: 4.8,
      highlights: ['Mua sắm cao cấp', 'Ẩm thực Nhật Bản', 'Khu vui chơi trẻ em'],
      icon: PhosphorIconsRegular.shoppingBag,
    ),

    // Ga Nhà Hát TP
    StationDestination(
      id: 'dest_nh_01',
      name: 'Nhà Hát Thành Phố & Vincom Đồng Khởi',
      category: DestinationCategory.culture,
      stationName: 'Nhà Hát Thành Phố',
      distance: '50m',
      walkTime: '1 phút',
      exitGate: 'Lối ra Cửa số 1 (Kết nối trực tiếp sảnh ngầm)',
      description: 'Công trình kiến trúc Pháp cổ kính lộng lẫy, nơi biểu diễn xiếc tre A O Show, đối diện là Vincom Center sầm uất.',
      rating: 4.9,
      highlights: ['Kiến trúc Pháp cổ', 'Xiếc tre A O Show', 'Vincom Center'],
      icon: PhosphorIconsRegular.buildings,
    ),
    StationDestination(
      id: 'dest_nh_02',
      name: 'Đường sách Nguyễn Văn Bình & Bưu điện TP',
      category: DestinationCategory.culture,
      stationName: 'Nhà Hát Thành Phố',
      distance: '350m',
      walkTime: '4 phút',
      exitGate: 'Lối ra Cửa số 2 (Đường Đồng Khởi)',
      description: 'Không gian văn hóa đọc xanh mát rợp bóng cây, các tiệm cà phê sách cổ điển và Bưu điện Trung tâm TP tuyệt đẹp.',
      rating: 4.8,
      highlights: ['Đường sách xanh', 'Bưu điện cổ kính', 'Check-in chụp ảnh'],
      icon: PhosphorIconsRegular.bookOpen,
    ),

    // Ga Ba Son
    StationDestination(
      id: 'dest_bs_01',
      name: 'Bến Bạch Đằng & Buýt Sông WaterBus',
      category: DestinationCategory.entertainment,
      stationName: 'Ba Son',
      distance: '300m',
      walkTime: '3 phút',
      exitGate: 'Lối ra Cửa số 1 (Đường Tôn Đức Thắng)',
      description: 'Công viên bờ sông Sài Gòn thoáng đãng, ngắm trọn cảnh quan bán đảo Thủ Thiêm và trải nghiệm buýt sông hoàng hôn.',
      rating: 4.8,
      highlights: ['Buýt sông Sài Gòn', 'Ngắm hoàng hôn', 'Cầu Ba Son lung linh'],
      icon: PhosphorIconsRegular.boat,
    ),

    // Ga Tân Cảng
    StationDestination(
      id: 'dest_tc_01',
      name: 'Landmark 81 SkyView & Công viên Central Park',
      category: DestinationCategory.entertainment,
      stationName: 'Tân Cảng',
      distance: '350m',
      walkTime: '4 phút',
      exitGate: 'Lối ra Cửa số 1 (Có cầu vượt bộ hành sang cổng Landmark)',
      description: 'Tòa nhà cao nhất Việt Nam, đài quan sát kính trong suốt tầng 81, sân trượt băng Vincom Ice Rink và công viên ven sông 14ha.',
      rating: 5.0,
      highlights: ['Đài quan sát tầng 81', 'Sân trượt băng', 'Công viên ven sông 14ha'],
      icon: PhosphorIconsRegular.airplaneTilt,
    ),

    // Ga Thảo Điền
    StationDestination(
      id: 'dest_td_01',
      name: 'Phố Tây Thảo Điền & Vincom Mega Mall',
      category: DestinationCategory.dining,
      stationName: 'Thảo Điền',
      distance: '150m',
      walkTime: '2 phút',
      exitGate: 'Lối ra Cửa số 1 (Đường Quốc Hương)',
      description: 'Khu phố ẩm thực đa quốc gia châu Âu, quầy bar ven sông, tiệm bánh nghệ thuật và trung tâm mua sắm Vincom Mega Mall.',
      rating: 4.7,
      highlights: ['Phố ẩm thực quốc tế', 'Quán cafe ven sông', 'Rạp chiếu phim BHD'],
      icon: PhosphorIconsRegular.wine,
    ),

    // Ga Suối Tiên (Bến Xe Suối Tiên)
    StationDestination(
      id: 'dest_st_01',
      name: 'Khu Du Lịch Văn Hóa Suối Tiên',
      category: DestinationCategory.entertainment,
      stationName: 'Suối Tiên',
      distance: '100m',
      walkTime: '1 phút',
      exitGate: 'Lối ra Cửa số 1 (Cầu vượt bộ hành nối thẳng cổng chính)',
      description: 'Thiên đường giải trí hàng đầu Đông Nam Á với Biển Tiên Đồng - Ngọc Nữ, Lâu đài phép thuật, Tàu lượn siêu tốc và Đền Hùng.',
      rating: 4.8,
      highlights: ['Biển Tiên Đồng nước mặn', 'Lâu đài tuyết', 'Cầu vượt nối thẳng ga'],
      icon: PhosphorIconsRegular.sunHorizon,
    ),
    StationDestination(
      id: 'dest_st_02',
      name: 'Đền Tưởng Niệm Các Vua Hùng Q.9',
      category: DestinationCategory.culture,
      stationName: 'Suối Tiên',
      distance: '1.2 km',
      walkTime: 'Xe buýt 5 phút',
      exitGate: 'Lối ra Cửa số 2 (Đón xe buýt Tuyến 76 hoặc 150)',
      description: 'Quần thể công viên lịch sử văn hóa dân tộc rộng lớn, nơi tổ chức Quốc giỗ Hùng Vương trang nghiêm hàng năm.',
      rating: 4.6,
      highlights: ['Di tích linh thiêng', 'Kiến trúc đền đài', 'Không gian cây xanh mát'],
      icon: PhosphorIconsRegular.tree,
    ),

    // Ga Đại Học Quốc Gia
    StationDestination(
      id: 'dest_dhqg_01',
      name: 'Làng Đại Học Quốc Gia TP.HCM & Hồ Đá',
      category: DestinationCategory.entertainment,
      stationName: 'Đại Học Quốc Gia',
      distance: '250m',
      walkTime: '3 phút',
      exitGate: 'Lối ra Cửa số 1 (Đường vào KTX Khu A)',
      description: 'Trung tâm văn hóa sinh viên năng động, phố ăn vặt đêm KTX sôi động, Nhà văn hóa sinh viên hình cánh diều khổng lồ.',
      rating: 4.7,
      highlights: ['Nhà VH Sinh Viên', 'Thiên đường ăn vặt đêm', 'Không gian xanh rộng lớn'],
      icon: PhosphorIconsRegular.graduationCap,
    ),
  ];

  /// Get bus connections for a given station
  static List<BusConnection> getBusConnections(String stationName) {
    // Normalization to match both 'Suối Tiên' and 'Bến Xe Miền Đông Mới'
    final normalized = stationName.contains('Suối Tiên') || stationName.contains('Miền Đông')
        ? 'Suối Tiên'
        : stationName;

    final results = allBusConnections
        .where((b) => b.connectingStation == normalized || b.connectingStation == stationName)
        .toList();

    if (results.isNotEmpty) return results;

    // Default fallback bus routes for any other station
    return [
      BusConnection(
        routeNumber: 'Tuyến buýt gom',
        routeName: 'Tuyến buýt trung chuyển kết nối Ga $stationName',
        operatingHours: '05:30 – 21:00',
        frequency: '10 – 15 phút/chuyến',
        fare: '6.000 đ',
        busStopLocation: 'Chân cầu thang lối lên ga $stationName',
        keyStops: ['Ga $stationName', 'Khu dân cư lân cận', 'UBND Phường'],
        connectingStation: stationName,
      ),
    ];
  }

  /// Get destinations for a given station
  static List<StationDestination> getDestinations(String stationName) {
    final normalized = stationName.contains('Suối Tiên') || stationName.contains('Miền Đông')
        ? 'Suối Tiên'
        : stationName;

    final results = allDestinations
        .where((d) => d.stationName == normalized || d.stationName == stationName)
        .toList();

    if (results.isNotEmpty) return results;

    return [
      StationDestination(
        id: 'dest_gen_${stationName.hashCode}',
        name: 'Khu thương mại & Tiện ích Ga $stationName',
        category: DestinationCategory.shopping,
        stationName: stationName,
        distance: '50m',
        walkTime: '1 phút',
        exitGate: 'Sảnh chính nhà ga',
        description: 'Cửa hàng tiện lợi, quầy cà phê mang đi, trạm sạc điện thoại và các dịch vụ dân sinh tiện ích.',
        rating: 4.5,
        highlights: ['Cửa hàng tiện lợi', 'Cà phê mang đi', 'Cây ATM 24/7'],
        icon: PhosphorIconsRegular.storefront,
      ),
    ];
  }
}
