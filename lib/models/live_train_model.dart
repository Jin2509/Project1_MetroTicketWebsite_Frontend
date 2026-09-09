import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../widgets/status_badge.dart';

/// Data model representing a live train operating on the metro line
class LiveTrain {
  final String id;
  final String code;
  final String destination;
  final String lineId;
  LatLng position;
  final String nextStation;
  final int etaMinutes;
  final int speedKmh;
  final String statusText;
  final TicketStatus statusBadge;
  final double heading; // in degrees

  LiveTrain({
    required this.id,
    required this.code,
    required this.destination,
    required this.lineId,
    required this.position,
    required this.nextStation,
    required this.etaMinutes,
    required this.speedKmh,
    required this.statusText,
    required this.statusBadge,
    this.heading = 45.0,
  });
}

/// Data model representing a map station waypoint
class MapStationPoint {
  final String id;
  final String name;
  final String code;
  final LatLng location;
  final bool isInterchange;
  final String? transferInfo;

  const MapStationPoint({
    required this.id,
    required this.name,
    required this.code,
    required this.location,
    this.isInterchange = false,
    this.transferInfo,
  });
}

/// Geospatial constants and mock realtime WebSocket train positions service
class MetroMapData {
  // Line 1 Stations with accurate coordinates in HCMC
  static const List<MapStationPoint> line1Stations = [
    MapStationPoint(
      id: 'l1_01',
      name: 'Bến Thành',
      code: 'L1-01',
      location: LatLng(10.7719, 106.6983),
      isInterchange: true,
      transferInfo: 'Chuyển tuyến Tuyến 2',
    ),
    MapStationPoint(
      id: 'l1_02',
      name: 'Nhà Hát TP',
      code: 'L1-02',
      location: LatLng(10.7766, 106.7029),
    ),
    MapStationPoint(
      id: 'l1_03',
      name: 'Ba Son',
      code: 'L1-03',
      location: LatLng(10.7818, 106.7068),
      isInterchange: true,
      transferInfo: 'Buýt sông Sài Gòn',
    ),
    MapStationPoint(
      id: 'l1_04',
      name: 'Văn Thánh',
      code: 'L1-04',
      location: LatLng(10.7936, 106.7155),
    ),
    MapStationPoint(
      id: 'l1_05',
      name: 'Tân Cảng',
      code: 'L1-05',
      location: LatLng(10.7981, 106.7214),
      isInterchange: true,
      transferInfo: 'Landmark 81',
    ),
    MapStationPoint(
      id: 'l1_06',
      name: 'Thảo Điền',
      code: 'L1-06',
      location: LatLng(10.8016, 106.7329),
    ),
    MapStationPoint(
      id: 'l1_07',
      name: 'An Phú',
      code: 'L1-07',
      location: LatLng(10.8038, 106.7456),
    ),
    MapStationPoint(
      id: 'l1_08',
      name: 'Rạch Chiếc',
      code: 'L1-08',
      location: LatLng(10.8122, 106.7589),
    ),
    MapStationPoint(
      id: 'l1_09',
      name: 'Phước Long',
      code: 'L1-09',
      location: LatLng(10.8229, 106.7667),
    ),
    MapStationPoint(
      id: 'l1_10',
      name: 'Bình Thái',
      code: 'L1-10',
      location: LatLng(10.8351, 106.7725),
    ),
    MapStationPoint(
      id: 'l1_11',
      name: 'Thủ Đức',
      code: 'L1-11',
      location: LatLng(10.8468, 106.7788),
    ),
    MapStationPoint(
      id: 'l1_12',
      name: 'Khu CNC',
      code: 'L1-12',
      location: LatLng(10.8574, 106.7905),
    ),
    MapStationPoint(
      id: 'l1_13',
      name: 'ĐHQG TP.HCM',
      code: 'L1-13',
      location: LatLng(10.8682, 106.8018),
    ),
    MapStationPoint(
      id: 'l1_14',
      name: 'Suối Tiên',
      code: 'L1-14',
      location: LatLng(10.8752, 106.8142),
      isInterchange: true,
      transferInfo: 'Bến xe Miền Đông mới',
    ),
  ];

  // Line 2 Stations (Bến Thành – Tham Lương)
  static const List<MapStationPoint> line2Stations = [
    MapStationPoint(
      id: 'l2_01',
      name: 'Bến Thành',
      code: 'L2-01',
      location: LatLng(10.7719, 106.6983),
      isInterchange: true,
      transferInfo: 'Chuyển tuyến Tuyến 1',
    ),
    MapStationPoint(
      id: 'l2_02',
      name: 'Tao Đàn',
      code: 'L2-02',
      location: LatLng(10.7745, 106.6912),
    ),
    MapStationPoint(
      id: 'l2_03',
      name: 'Dân Chủ',
      code: 'L2-03',
      location: LatLng(10.7782, 106.6835),
    ),
    MapStationPoint(
      id: 'l2_04',
      name: 'Hòa Hưng',
      code: 'L2-04',
      location: LatLng(10.7831, 106.6748),
    ),
    MapStationPoint(
      id: 'l2_05',
      name: 'Lê Thị Riêng',
      code: 'L2-05',
      location: LatLng(10.7885, 106.6662),
    ),
    MapStationPoint(
      id: 'l2_06',
      name: 'Bảy Hiền',
      code: 'L2-06',
      location: LatLng(10.7995, 106.6508),
      isInterchange: true,
      transferInfo: 'Chuyển tuyến Tuyến 5',
    ),
    MapStationPoint(
      id: 'l2_07',
      name: 'Bà Quẹo',
      code: 'L2-07',
      location: LatLng(10.8128, 106.6355),
    ),
    MapStationPoint(
      id: 'l2_08',
      name: 'Tham Lương',
      code: 'L2-08',
      location: LatLng(10.8265, 106.6195),
    ),
  ];

  static List<LatLng> get line1Polyline =>
      line1Stations.map((s) => s.location).toList();

  static List<LatLng> get line2Polyline =>
      line2Stations.map((s) => s.location).toList();

  // User simulated passenger location at Bến Thành Hub
  static const LatLng userLocation = LatLng(10.7725, 106.6995);
}

/// Simulated Live WebSocket Train Tracking Service
class LiveTrainService extends ChangeNotifier {
  Timer? _timer;
  double _progress = 0.0;

  final List<LiveTrain> _line1Trains = [
    LiveTrain(
      id: 'T101',
      code: 'Tàu #101',
      destination: 'Ga Suối Tiên',
      lineId: 'line_1',
      position: const LatLng(10.7780, 106.7040),
      nextStation: 'Ga Ba Son',
      etaMinutes: 2,
      speedKmh: 54,
      statusText: 'Đúng giờ',
      statusBadge: TicketStatus.paid,
      heading: 50.0,
    ),
    LiveTrain(
      id: 'T104',
      code: 'Tàu #104',
      destination: 'Ga Suối Tiên',
      lineId: 'line_1',
      position: const LatLng(10.8020, 106.7350),
      nextStation: 'Ga An Phú',
      etaMinutes: 3,
      speedKmh: 62,
      statusText: 'Đúng giờ',
      statusBadge: TicketStatus.paid,
      heading: 65.0,
    ),
    LiveTrain(
      id: 'T108',
      code: 'Tàu #108',
      destination: 'Ga Bến Thành',
      lineId: 'line_1',
      position: const LatLng(10.8400, 106.7750),
      nextStation: 'Ga Bình Thái',
      etaMinutes: 1,
      speedKmh: 58,
      statusText: 'Trễ +2p',
      statusBadge: TicketStatus.pending,
      heading: 235.0,
    ),
    LiveTrain(
      id: 'T112',
      code: 'Tàu #112',
      destination: 'Ga Bến Thành',
      lineId: 'line_1',
      position: const LatLng(10.8650, 106.7980),
      nextStation: 'Ga Khu CNC',
      etaMinutes: 4,
      speedKmh: 68,
      statusText: 'Đúng giờ',
      statusBadge: TicketStatus.paid,
      heading: 230.0,
    ),
  ];

  final List<LiveTrain> _line2Trains = [
    LiveTrain(
      id: 'T201',
      code: 'Tàu #201',
      destination: 'Ga Tham Lương',
      lineId: 'line_2',
      position: const LatLng(10.7760, 106.6870),
      nextStation: 'Ga Dân Chủ',
      etaMinutes: 2,
      speedKmh: 48,
      statusText: 'Đúng giờ',
      statusBadge: TicketStatus.paid,
      heading: 310.0,
    ),
    LiveTrain(
      id: 'T203',
      code: 'Tàu #203',
      destination: 'Ga Bến Thành',
      lineId: 'line_2',
      position: const LatLng(10.8040, 106.6450),
      nextStation: 'Ga Bảy Hiền',
      etaMinutes: 3,
      speedKmh: 52,
      statusText: 'Đúng giờ',
      statusBadge: TicketStatus.paid,
      heading: 130.0,
    ),
  ];

  LiveTrainService() {
    _startSimulatedStream();
  }

  List<LiveTrain> getTrainsForLine(String lineId) {
    return lineId == 'line_1' ? _line1Trains : _line2Trains;
  }

  void _startSimulatedStream() {
    _timer = Timer.periodic(const Duration(milliseconds: 1400), (timer) {
      _progress += 0.015;
      if (_progress > 1.0) _progress = 0.0;

      // Smoothly nudge train coordinates along their track vectors
      final l1Points = MetroMapData.line1Polyline;
      if (l1Points.length >= 10) {
        _line1Trains[0].position = _interpolatePoints(l1Points[1], l1Points[3], _progress);
        _line1Trains[1].position = _interpolatePoints(l1Points[5], l1Points[7], _progress);
        _line1Trains[2].position = _interpolatePoints(l1Points[10], l1Points[8], _progress);
        _line1Trains[3].position = _interpolatePoints(l1Points[13], l1Points[11], _progress);
      }

      final l2Points = MetroMapData.line2Polyline;
      if (l2Points.length >= 6) {
        _line2Trains[0].position = _interpolatePoints(l2Points[1], l2Points[3], _progress);
        _line2Trains[1].position = _interpolatePoints(l2Points[5], l2Points[3], _progress);
      }

      notifyListeners();
    });
  }

  LatLng _interpolatePoints(LatLng p1, LatLng p2, double t) {
    final lat = p1.latitude + (p2.latitude - p1.latitude) * t;
    final lng = p1.longitude + (p2.longitude - p1.longitude) * t;
    return LatLng(lat, lng);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
