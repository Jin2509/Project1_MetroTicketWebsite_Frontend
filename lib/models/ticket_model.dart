import 'package:flutter/foundation.dart';
import '../widgets/status_badge.dart';

enum TicketType {
  singleRide,
  dayPass,
  monthlyPass;

  String get displayName {
    switch (this) {
      case TicketType.singleRide:
        return 'Vé lượt';
      case TicketType.dayPass:
        return 'Vé ngày';
      case TicketType.monthlyPass:
        return 'Vé tháng';
    }
  }
}

class Ticket {
  final String id;
  final String title;
  final TicketType type;
  final String? originStation;
  final String? destinationStation;
  final String validityText;
  final TicketStatus status;
  final int priceVnd;
  final DateTime purchaseDate;
  final int quantity;
  final String lineCode;
  final String qrCodeData;
  final String passengerName;

  const Ticket({
    required this.id,
    required this.title,
    required this.type,
    this.originStation,
    this.destinationStation,
    required this.validityText,
    required this.status,
    required this.priceVnd,
    required this.purchaseDate,
    this.quantity = 1,
    this.lineCode = 'L1',
    required this.qrCodeData,
    this.passengerName = 'Alex Nguyễn',
  });

  String get formattedPrice {
    final str = priceVnd.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }
    return '${buffer.toString().split('').reversed.join('')} đ';
  }
}

/// Global in-memory reactive ticket store for MetroGo
class TicketStore extends ChangeNotifier {
  static final TicketStore instance = TicketStore._internal();
  TicketStore._internal();

  final List<Ticket> _activeTickets = [
    Ticket(
      id: 'MG-L1-2026-9842',
      title: 'Vé tháng không giới hạn',
      type: TicketType.monthlyPass,
      originStation: 'Bến Thành',
      destinationStation: 'Suối Tiên',
      validityText: 'Hạn dùng đến 25/10/2026 (30 ngày)',
      status: TicketStatus.paid,
      priceVnd: 260000,
      purchaseDate: DateTime(2026, 9, 25),
      lineCode: 'Toàn tuyến',
      qrCodeData: 'METROGO:TICKET:MG-L1-2026-9842:MONTHLY:ALL_LINES:ALEX_NGUYEN',
      passengerName: 'Alex Nguyễn',
    ),
    Ticket(
      id: 'MG-L1-2026-4412',
      title: 'Vé lượt (Nhanh)',
      type: TicketType.singleRide,
      originStation: 'Bến Thành',
      destinationStation: 'Nhà Hát Thành Phố',
      validityText: 'Có giá trị trong 4 giờ sau khi mua',
      status: TicketStatus.paid,
      priceVnd: 15000,
      purchaseDate: DateTime(2026, 9, 9, 8, 30),
      lineCode: 'L1',
      qrCodeData: 'METROGO:TICKET:MG-L1-2026-4412:SINGLE:BT-NHTP:ALEX_NGUYEN',
      passengerName: 'Alex Nguyễn',
    ),
  ];

  final List<Ticket> _historyTickets = [
    Ticket(
      id: 'MG-L1-2026-1033',
      title: 'Vé lượt',
      type: TicketType.singleRide,
      originStation: 'Ba Son',
      destinationStation: 'Tân Cảng',
      validityText: 'Đã sử dụng vào 07/09/2026 • 18:45',
      status: TicketStatus.used,
      priceVnd: 15000,
      purchaseDate: DateTime(2026, 9, 7),
      lineCode: 'L1',
      qrCodeData: 'METROGO:TICKET:MG-L1-2026-1033:USED',
    ),
    Ticket(
      id: 'MG-L1-2026-0912',
      title: 'Vé 1 ngày không giới hạn',
      type: TicketType.dayPass,
      validityText: 'Hết hạn vào 02/09/2026',
      status: TicketStatus.expired,
      priceVnd: 40000,
      purchaseDate: DateTime(2026, 9, 2),
      lineCode: 'Toàn tuyến',
      qrCodeData: 'METROGO:TICKET:MG-L1-2026-0912:EXPIRED',
    ),
    Ticket(
      id: 'MG-L1-2026-0881',
      title: 'Vé lượt',
      type: TicketType.singleRide,
      originStation: 'Thảo Điền',
      destinationStation: 'Bến Thành',
      validityText: 'Đã sử dụng vào 28/08/2026 • 09:15',
      status: TicketStatus.used,
      priceVnd: 17000,
      purchaseDate: DateTime(2026, 8, 28),
      lineCode: 'L1',
      qrCodeData: 'METROGO:TICKET:MG-L1-2026-0881:USED',
    ),
  ];

  List<Ticket> get activeTickets => List.unmodifiable(_activeTickets);
  List<Ticket> get historyTickets => List.unmodifiable(_historyTickets);

  void addTicket(Ticket ticket) {
    _activeTickets.insert(0, ticket);
    notifyListeners();
  }
}
