import 'package:flutter/material.dart';

class MetroStation {
  final String id;
  final String name;
  final String vietnameseName;
  final String code;
  final bool isUnderground;
  final bool isInterchange;
  final String? interchangeNote;
  final bool hasElevator;
  final bool hasRestroom;

  const MetroStation({
    required this.id,
    required this.name,
    required this.vietnameseName,
    required this.code,
    this.isUnderground = false,
    this.isInterchange = false,
    this.interchangeNote,
    this.hasElevator = true,
    this.hasRestroom = true,
  });
}

class MetroLine {
  final String id;
  final String name;
  final String code;
  final Color color;
  final int stationCount;
  final String distanceKm;
  final String operatingHours;
  final String frequencyPeak;
  final String frequencyOffPeak;
  final List<MetroStation> stations;

  const MetroLine({
    required this.id,
    required this.name,
    required this.code,
    required this.color,
    required this.stationCount,
    required this.distanceKm,
    required this.operatingHours,
    required this.frequencyPeak,
    required this.frequencyOffPeak,
    required this.stations,
  });
}

class TransitData {
  static const List<MetroStation> line1Stations = [
    MetroStation(
      id: 'st_01',
      name: 'Ben Thanh',
      vietnameseName: 'Bến Thành',
      code: 'L1-01',
      isUnderground: true,
      isInterchange: true,
      interchangeNote: 'Tuyến 2 • Trạm xe buýt trung tâm',
    ),
    MetroStation(
      id: 'st_02',
      name: 'City Opera House',
      vietnameseName: 'Nhà Hát Thành Phố',
      code: 'L1-02',
      isUnderground: true,
      isInterchange: false,
    ),
    MetroStation(
      id: 'st_03',
      name: 'Ba Son',
      vietnameseName: 'Ba Son',
      code: 'L1-03',
      isUnderground: true,
      isInterchange: true,
      interchangeNote: 'Kết nối Buýt sông Sài Gòn',
    ),
    MetroStation(
      id: 'st_04',
      name: 'Van Thanh Park',
      vietnameseName: 'Công Viên Văn Thánh',
      code: 'L1-04',
      isUnderground: false,
      isInterchange: false,
    ),
    MetroStation(
      id: 'st_05',
      name: 'Tan Cang',
      vietnameseName: 'Tân Cảng',
      code: 'L1-05',
      isUnderground: false,
      isInterchange: true,
      interchangeNote: 'Lối sang Landmark 81',
    ),
    MetroStation(
      id: 'st_06',
      name: 'Thao Dien',
      vietnameseName: 'Thảo Điền',
      code: 'L1-06',
      isUnderground: false,
      isInterchange: false,
    ),
    MetroStation(
      id: 'st_07',
      name: 'An Phu',
      vietnameseName: 'An Phú',
      code: 'L1-07',
      isUnderground: false,
      isInterchange: false,
    ),
    MetroStation(
      id: 'st_08',
      name: 'Rach Chiec',
      vietnameseName: 'Rạch Chiếc',
      code: 'L1-08',
      isUnderground: false,
      isInterchange: false,
    ),
    MetroStation(
      id: 'st_09',
      name: 'Phuoc Long',
      vietnameseName: 'Phước Long',
      code: 'L1-09',
      isUnderground: false,
      isInterchange: false,
    ),
    MetroStation(
      id: 'st_10',
      name: 'Binh Thai',
      vietnameseName: 'Bình Thái',
      code: 'L1-10',
      isUnderground: false,
      isInterchange: false,
    ),
    MetroStation(
      id: 'st_11',
      name: 'Thu Duc',
      vietnameseName: 'Thủ Đức',
      code: 'L1-11',
      isUnderground: false,
      isInterchange: false,
    ),
    MetroStation(
      id: 'st_12',
      name: 'High-Tech Park',
      vietnameseName: 'Khu Công Nghệ Cao',
      code: 'L1-12',
      isUnderground: false,
      isInterchange: false,
    ),
    MetroStation(
      id: 'st_13',
      name: 'National University',
      vietnameseName: 'Đại Học Quốc Gia',
      code: 'L1-13',
      isUnderground: false,
      isInterchange: false,
    ),
    MetroStation(
      id: 'st_14',
      name: 'Suoi Tien Terminal',
      vietnameseName: 'Bến Xe Miền Đông Mới',
      code: 'L1-14',
      isUnderground: false,
      isInterchange: true,
      interchangeNote: 'Bến xe khách liên tỉnh',
    ),
  ];

  static const List<MetroStation> line2Stations = [
    MetroStation(
      id: 'l2_01',
      name: 'Ben Thanh',
      vietnameseName: 'Bến Thành',
      code: 'L2-01',
      isUnderground: true,
      isInterchange: true,
      interchangeNote: 'Kết nối Tuyến 1',
    ),
    MetroStation(
      id: 'l2_02',
      name: 'Tao Dan',
      vietnameseName: 'Tao Đàn',
      code: 'L2-02',
      isUnderground: true,
    ),
    MetroStation(
      id: 'l2_03',
      name: 'Dan Chu',
      vietnameseName: 'Dân Chủ',
      code: 'L2-03',
      isUnderground: true,
    ),
    MetroStation(
      id: 'l2_04',
      name: 'Hoa Hung',
      vietnameseName: 'Hòa Hưng',
      code: 'L2-04',
      isUnderground: true,
      isInterchange: true,
      interchangeNote: 'Ga Đường sắt Sài Gòn',
    ),
    MetroStation(
      id: 'l2_05',
      name: 'Le Thi Rieng',
      vietnameseName: 'Lê Thị Riêng',
      code: 'L2-05',
      isUnderground: true,
    ),
    MetroStation(
      id: 'l2_06',
      name: 'Pham Van Hai',
      vietnameseName: 'Phạm Văn Hai',
      code: 'L2-06',
      isUnderground: true,
    ),
    MetroStation(
      id: 'l2_07',
      name: 'Bay Hien',
      vietnameseName: 'Bảy Hiền',
      code: 'L2-07',
      isUnderground: true,
      isInterchange: true,
      interchangeNote: 'Kết nối Tuyến 5',
    ),
    MetroStation(
      id: 'l2_08',
      name: 'Nguyen Hong Dao',
      vietnameseName: 'Nguyễn Hồng Đào',
      code: 'L2-08',
      isUnderground: true,
    ),
    MetroStation(
      id: 'l2_09',
      name: 'Ba Queo',
      vietnameseName: 'Bà Quẹo',
      code: 'L2-09',
      isUnderground: false,
    ),
    MetroStation(
      id: 'l2_10',
      name: 'Pham Van Bach',
      vietnameseName: 'Phạm Văn Bạch',
      code: 'L2-10',
      isUnderground: false,
    ),
    MetroStation(
      id: 'l2_11',
      name: 'Tham Luong Depot',
      vietnameseName: 'Tham Lương',
      code: 'L2-11',
      isUnderground: false,
      isInterchange: true,
      interchangeNote: 'Depot & Trạm bảo dưỡng Tuyến 2',
    ),
  ];

  static const List<MetroLine> lines = [
    MetroLine(
      id: 'line_1',
      name: 'Line 1: Bến Thành – Suối Tiên',
      code: 'Line 1',
      color: Color(0xFF2F6FED),
      stationCount: 14,
      distanceKm: '19.7 km',
      operatingHours: '05:00 – 23:00 hàng ngày',
      frequencyPeak: '4.5 phút',
      frequencyOffPeak: '8 phút',
      stations: line1Stations,
    ),
    MetroLine(
      id: 'line_2',
      name: 'Line 2: Bến Thành – Tham Lương',
      code: 'Line 2',
      color: Color(0xFF10B981),
      stationCount: 11,
      distanceKm: '11.3 km',
      operatingHours: '05:30 – 22:30 hàng ngày',
      frequencyPeak: '6 phút',
      frequencyOffPeak: '10 phút',
      stations: [],
    ),
    MetroLine(
      id: 'line_3a',
      name: 'Line 3A: Bến Thành – Tân Kiên',
      code: 'Line 3A',
      color: Color(0xFFF59E0B),
      stationCount: 17,
      distanceKm: '19.8 km',
      operatingHours: '05:00 – 22:00 hàng ngày',
      frequencyPeak: '7 phút',
      frequencyOffPeak: '12 phút',
      stations: [],
    ),
    MetroLine(
      id: 'line_4',
      name: 'Line 4: Thạnh Xuân – Hiệp Phước',
      code: 'Line 4',
      color: Color(0xFF8B5CF6),
      stationCount: 15,
      distanceKm: '16.0 km',
      operatingHours: '05:30 – 22:00 hàng ngày',
      frequencyPeak: '8 phút',
      frequencyOffPeak: '12 phút',
      stations: [],
    ),
  ];
}
