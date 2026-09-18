import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../models/station_connections_model.dart';
import '../../models/ticket_model.dart';
import '../../models/transit_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/metro_app_bar.dart';
import '../../widgets/metro_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/screen_switcher_sheet.dart';

/// Booking page mode: Ticket Booking vs Station Parking Reservation
enum BookingPageMode {
  ticket,
  parking,
}

/// Screen: Booking Flow Screen
/// Step 1: Segmented ticket type selection (Single ride / Day pass / Monthly pass)
/// Step 2: Dynamic sub-options (stations / durations / discounts)
/// Step 3: Quantity selector (+/- stepper) with live-updating total price
class BookingFlowScreen extends StatefulWidget {
  final TicketType initialType;
  final BookingPageMode initialMode;

  const BookingFlowScreen({
    super.key,
    this.initialType = TicketType.singleRide,
    this.initialMode = BookingPageMode.ticket,
  });

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  late BookingPageMode _currentMode;
  bool _didReadRouteArgs = false;
  late TicketType _selectedType;

  // Single Ride state
  String _originStation = 'Bến Thành';
  String _destinationStation = 'Suối Tiên';
  final int _singleRideBaseFare = 15000;

  // Day Pass state
  int _selectedDayPassDays = 1; // 1 or 3
  final int _dayPass1DayPrice = 40000;
  final int _dayPass3DayPrice = 90000;

  // Monthly Pass state
  int _selectedMonthlyDurationDays = 30; // 30 or 90
  bool _isStudentDiscount = false;
  final int _monthly30DayPrice = 260000;
  final int _monthly90DayPrice = 720000;

  // Quantity stepper
  int _quantity = 1;

  // Parking Reservation state (Parallel dedicated service)
  late String _parkingStation;
  late final TextEditingController _parkingOwnerController;
  late final TextEditingController _parkingPlateController;
  String _parkingVehicleType = 'Xe máy'; // 'Xe máy' or 'Ô tô'
  String _parkingPackage = '1 buổi'; // '1 buổi', '1 ngày', 'Qua đêm'

  // Bus Connection & Entertainment exploration state
  int _selectedBusStationIndex = 0; // 0 = origin, 1 = destination
  int _selectedDestStationIndex = 1; // 0 = origin, 1 = destination (defaults to destination)
  DestinationCategory? _selectedDestCategory; // null = all

  @override
  void initState() {
    super.initState();
    _currentMode = widget.initialMode;
    _selectedType = widget.initialType;
    _parkingStation = _originStation;
    _parkingOwnerController = TextEditingController(text: 'Alex Nguyễn');
    _parkingPlateController = TextEditingController(text: '59-A1 123.45');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didReadRouteArgs) {
      _didReadRouteArgs = true;
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is BookingPageMode) {
        _currentMode = args;
      } else if (args is TicketType) {
        _selectedType = args;
        _currentMode = BookingPageMode.ticket;
      } else if (args is Map) {
        if (args['mode'] == 'parking') {
          _currentMode = BookingPageMode.parking;
        } else if (args['mode'] == 'ticket') {
          _currentMode = BookingPageMode.ticket;
        }
        if (args['ticketType'] is TicketType) {
          _selectedType = args['ticketType'] as TicketType;
        }
      } else if (args == 'parking') {
        _currentMode = BookingPageMode.parking;
      }
    }
  }

  @override
  void dispose() {
    _parkingOwnerController.dispose();
    _parkingPlateController.dispose();
    super.dispose();
  }

  int get _parkingFee {
    if (_parkingVehicleType == 'Xe máy') {
      switch (_parkingPackage) {
        case '1 buổi':
          return 5000;
        case '1 ngày':
          return 10000;
        case 'Qua đêm':
          return 15000;
        default:
          return 5000;
      }
    } else {
      switch (_parkingPackage) {
        case '1 buổi':
          return 25000;
        case '1 ngày':
          return 50000;
        case 'Qua đêm':
          return 70000;
        default:
          return 25000;
      }
    }
  }

  int get _unitPrice {
    switch (_selectedType) {
      case TicketType.singleRide:
        return _singleRideBaseFare;
      case TicketType.dayPass:
        return _selectedDayPassDays == 1
            ? _dayPass1DayPrice
            : _dayPass3DayPrice;
      case TicketType.monthlyPass:
        final base = _selectedMonthlyDurationDays == 30
            ? _monthly30DayPrice
            : _monthly90DayPrice;
        return _isStudentDiscount ? (base * 0.5).round() : base;
    }
  }

  int get _ticketTotal => _unitPrice * _quantity;
  int get _totalPrice =>
      _currentMode == BookingPageMode.parking ? _parkingFee : _ticketTotal;

  String _formatVnd(int amount) {
    final str = amount.toString();
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

  void _swapStations() {
    setState(() {
      final temp = _originStation;
      _originStation = _destinationStation;
      _destinationStation = temp;
    });
  }

  void _pickStation(bool isOrigin) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppRadius.xl),
            topRight: Radius.circular(AppRadius.xl),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                isOrigin ? 'Chọn ga đi' : 'Chọn ga đến',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: TransitData.line1Stations.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final station = TransitData.line1Stations[index];
                  final isCurrent = isOrigin
                      ? _originStation == station.vietnameseName
                      : _destinationStation == station.vietnameseName;

                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? AppColors.primaryLight
                            : AppColors.surfaceSecondary,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: PhosphorIcon(
                        PhosphorIconsRegular.train,
                        size: 18,
                        color: isCurrent
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                    title: Text(
                      station.vietnameseName,
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        fontWeight:
                            isCurrent ? FontWeight.w700 : FontWeight.w500,
                        color: isCurrent
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Tuyến 1 • ${station.code}',
                      style: AppTypography.textTheme.bodySmall,
                    ),
                    trailing: isCurrent
                        ? const PhosphorIcon(
                            PhosphorIconsRegular.check,
                            color: AppColors.primary,
                            size: 18,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        if (isOrigin) {
                          _originStation = station.vietnameseName;
                        } else {
                          _destinationStation = station.vietnameseName;
                        }
                      });
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickParkingStation() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppRadius.xl),
            topRight: Radius.circular(AppRadius.xl),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                'Chọn nhà ga gửi xe',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: TransitData.line1Stations.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final station = TransitData.line1Stations[index];
                  final isCurrent = _parkingStation == station.vietnameseName;

                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? AppColors.primaryLight
                            : AppColors.surfaceSecondary,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: PhosphorIcon(
                        PhosphorIconsRegular.car,
                        size: 18,
                        color: isCurrent
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                    title: Text(
                      'Ga ${station.vietnameseName}',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        fontWeight:
                            isCurrent ? FontWeight.w700 : FontWeight.w500,
                        color: isCurrent
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Bãi giữ xe ${index < 3 ? "ngầm" : "nổi"} • Sức chứa 500+ xe',
                      style: AppTypography.textTheme.bodySmall,
                    ),
                    trailing: isCurrent
                        ? const PhosphorIcon(
                            PhosphorIconsRegular.check,
                            color: AppColors.primary,
                            size: 18,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        _parkingStation = station.vietnameseName;
                      });
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _proceedToParkingPayment() {
    if (_parkingOwnerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập họ tên chủ xe để đặt chỗ giữ xe'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_parkingPlateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập biển số xe để đặt chỗ giữ xe'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.of(context).pushNamed(
      '/payment',
      arguments: {
        'ticketType': TicketType.singleRide,
        'title': 'Đăng ký giữ xe: Ga $_parkingStation',
        'origin': 'Ga $_parkingStation',
        'destination': 'Bãi giữ xe Ga $_parkingStation',
        'validity': 'Gói $_parkingPackage • Xe $_parkingVehicleType',
        'unitPrice': _parkingFee,
        'quantity': 1,
        'ticketTotal': 0,
        'totalPrice': _parkingFee,
        'hasParking': true,
        'isParkingOnly': true,
        'parkingStation': _parkingStation,
        'parkingOwner': _parkingOwnerController.text.trim(),
        'parkingPlate': _parkingPlateController.text.trim().toUpperCase(),
        'parkingVehicle': _parkingVehicleType,
        'parkingPackage': _parkingPackage,
        'parkingFee': _parkingFee,
      },
    );
  }

  void _proceedToTicketPayment() {
    String summaryTitle;
    String validityLabel;

    switch (_selectedType) {
      case TicketType.singleRide:
        summaryTitle = 'Vé lượt: $_originStation → $_destinationStation';
        validityLabel = 'Hiệu lực 4 giờ kể từ khi vào ga';
        break;
      case TicketType.dayPass:
        summaryTitle = 'Vé ngày: $_selectedDayPassDays ngày không giới hạn';
        validityLabel = '$_selectedDayPassDays ngày từ lượt quét đầu';
        break;
      case TicketType.monthlyPass:
        summaryTitle =
            'Vé tháng $_selectedMonthlyDurationDays ngày${_isStudentDiscount ? ' (Học sinh/Sinh viên)' : ''}';
        validityLabel = '$_selectedMonthlyDurationDays ngày không giới hạn lượt đi';
        break;
    }

    Navigator.of(context).pushNamed(
      '/payment',
      arguments: {
        'ticketType': _selectedType,
        'title': summaryTitle,
        'origin': _selectedType == TicketType.singleRide ? _originStation : null,
        'destination':
            _selectedType == TicketType.singleRide ? _destinationStation : null,
        'validity': validityLabel,
        'unitPrice': _unitPrice,
        'quantity': _quantity,
        'ticketTotal': _ticketTotal,
        'totalPrice': _ticketTotal,
        'hasParking': false,
        'isParkingOnly': false,
      },
    );
  }

  void _proceedToPayment() {
    if (_currentMode == BookingPageMode.parking) {
      _proceedToParkingPayment();
    } else {
      _proceedToTicketPayment();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MetroAppBar(
        title: 'Đặt vé Metro',
        actions: const [
          ScreenSwitcherButton(),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 0. TWO PARALLEL MODE SWITCHER BUTTONS (ABOVE TICKET TYPES)
                    _buildParallelModeSwitcher(),
                    const SizedBox(height: AppSpacing.lg),

                    if (_currentMode == BookingPageMode.ticket) ...[
                      // 1. TICKET TYPE SEGMENTED CONTROL
                      Text(
                        'CHỌN LOẠI VÉ',
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: AppColors.borderSubtle),
                          boxShadow: AppShadows.subtle,
                        ),
                        child: Row(
                          children: [
                            _buildSegmentTab(
                              TicketType.singleRide,
                              'Vé lượt',
                              PhosphorIconsRegular.ticket,
                            ),
                            _buildSegmentTab(
                              TicketType.dayPass,
                              'Vé ngày',
                              PhosphorIconsRegular.calendarCheck,
                            ),
                            _buildSegmentTab(
                              TicketType.monthlyPass,
                              'Vé tháng',
                              PhosphorIconsRegular.creditCard,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // 2. DYNAMIC SUB-OPTIONS
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: _buildSubOptionsForType(),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // 3. QUANTITY SELECTOR
                      Text(
                        'SỐ LƯỢNG HÀNH KHÁCH',
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      MetroCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Số vé',
                                  style: AppTypography.textTheme.titleSmall
                                      ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${_formatVnd(_unitPrice)}/vé',
                                  style: AppTypography.textTheme.bodySmall
                                      ?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            // Stepper +/-
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.surfaceSecondary,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.pill),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  _stepperButton(
                                    icon: PhosphorIconsRegular.minus,
                                    onPressed: _quantity > 1
                                        ? () => setState(() => _quantity--)
                                        : null,
                                  ),
                                  Container(
                                    constraints:
                                        const BoxConstraints(minWidth: 38),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '$_quantity',
                                      style: AppTypography.textTheme.titleMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  _stepperButton(
                                    icon: PhosphorIconsRegular.plus,
                                    onPressed: _quantity < 10
                                        ? () => setState(() => _quantity++)
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      // Tóm tắt tiền vé Metro (hoàn tất phần cấu hình vé tàu)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const PhosphorIcon(
                                  PhosphorIconsBold.ticket,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Tiền vé tàu Metro ($_quantity vé)',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              _formatVnd(_ticketTotal),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xxl),
                      _buildSectionDivider(
                        tag: 'DỊCH VỤ TẠI NHÀ GA',
                        title: 'Tiện ích & Kết nối hành trình',
                        icon: PhosphorIconsBold.squaresFour,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // LIÊN KẾT XE BUÝT TRUNG CHUYỂN
                      _buildBusConnectionsSection(),

                      const SizedBox(height: AppSpacing.xxl),

                      // KHU VỰC GIẢI TRÍ & ĐIỂM ĐẾN QUANH GA
                      _buildStationDestinationsSection(),

                      const SizedBox(height: AppSpacing.xl),
                    ] else ...[
                      // PARKING RESERVATION SECTION (PARALLEL DEDICATED SERVICE)
                      _buildParkingSection(),

                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ],
                ),
              ),
            ),

            // BOTTOM BAR: Live Price & Confirm Button
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: const Border(
                  top: BorderSide(color: AppColors.borderSubtle, width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A1D29).withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentMode == BookingPageMode.parking
                                ? 'Phí giữ xe ($_parkingPackage)'
                                : 'Tổng tiền ($_quantity vé)',
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatVnd(_totalPrice),
                            style:
                                AppTypography.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: PrimaryButton(
                        text: _currentMode == BookingPageMode.parking
                            ? 'Thanh toán giữ xe (QR)'
                            : 'Tiếp tục thanh toán (QR)',
                        trailingIcon: PhosphorIconsRegular.arrowRight,
                        onPressed: _proceedToPayment,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParallelModeSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildModeTabButton(
              mode: BookingPageMode.ticket,
              title: 'Đặt vé tàu Metro',
              icon: PhosphorIconsFill.ticket,
              subtitle: 'Vé lượt • Vé ngày • Tháng',
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildModeTabButton(
              mode: BookingPageMode.parking,
              title: 'Đăng ký giữ xe ga',
              icon: PhosphorIconsFill.car,
              subtitle: 'Bãi xe 14 nhà ga',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTabButton({
    required BookingPageMode mode,
    required String title,
    required PhosphorIconData icon,
    required String subtitle,
  }) {
    final isSelected = _currentMode == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentMode = mode;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderSubtle,
          ),
          boxShadow: isSelected ? AppShadows.subtle : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PhosphorIcon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.85)
                          : AppColors.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentTab(
      TicketType type, String label, PhosphorIconData icon) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = type;
            _quantity = 1; // Reset quantity on type change
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: isSelected ? AppShadows.subtle : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PhosphorIcon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.textTheme.labelMedium?.copyWith(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubOptionsForType() {
    switch (_selectedType) {
      case TicketType.singleRide:
        return _buildSingleRideOptions();
      case TicketType.dayPass:
        return _buildDayPassOptions();
      case TicketType.monthlyPass:
        return _buildMonthlyPassOptions();
    }
  }

  // Single Ride: Station pickers with swap
  Widget _buildSingleRideOptions() {
    return Column(
      key: const ValueKey('single_ride'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LỘ TRÌNH DI CHUYỂN',
          style: AppTypography.textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 1.1,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        MetroCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              Column(
                children: [
                  _stationSelectorRow(
                    label: 'Ga đi',
                    stationName: _originStation,
                    iconColor: AppColors.success,
                    onTap: () => _pickStation(true),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Divider(height: 1),
                  ),
                  _stationSelectorRow(
                    label: 'Ga đến',
                    stationName: _destinationStation,
                    iconColor: AppColors.primary,
                    onTap: () => _pickStation(false),
                  ),
                ],
              ),
              // Swap Button
              Positioned(
                right: 8,
                child: GestureDetector(
                  onTap: _swapStations,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: const PhosphorIcon(
                      PhosphorIconsRegular.arrowsDownUp,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Row(
            children: const [
              PhosphorIcon(
                PhosphorIconsRegular.info,
                size: 14,
                color: AppColors.textMuted,
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Có hiệu lực trên Tuyến 1 trong 4 giờ kể từ khi quét thẻ vào cổng.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stationSelectorRow({
    required String label,
    required String stationName,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Text(
                    stationName,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
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
            const SizedBox(width: 36), // Spacing for swap button
          ],
        ),
      ),
    );
  }

  // Day Pass: 1-Day vs 3-Day
  Widget _buildDayPassOptions() {
    return Column(
      key: const ValueKey('day_pass'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'THỜI HẠN VÉ',
          style: AppTypography.textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 1.1,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _optionSelectCard(
                title: 'Vé 1 ngày',
                price: _formatVnd(_dayPass1DayPrice),
                subtitle: '24h không giới hạn',
                badge: 'PHỔ BIẾN',
                isSelected: _selectedDayPassDays == 1,
                onTap: () => setState(() => _selectedDayPassDays = 1),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _optionSelectCard(
                title: 'Vé 3 ngày',
                price: _formatVnd(_dayPass3DayPrice),
                subtitle: '72h khám phá TP',
                isSelected: _selectedDayPassDays == 3,
                onTap: () => setState(() => _selectedDayPassDays = 3),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Monthly Pass: 30 vs 90 days, student concession
  Widget _buildMonthlyPassOptions() {
    return Column(
      key: const ValueKey('monthly_pass'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'THỜI HẠN SỬ DỤNG',
          style: AppTypography.textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 1.1,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _optionSelectCard(
                title: '30 ngày',
                price: _formatVnd(_monthly30DayPrice),
                subtitle: 'Đi làm thường xuyên',
                isSelected: _selectedMonthlyDurationDays == 30,
                onTap: () =>
                    setState(() => _selectedMonthlyDurationDays = 30),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _optionSelectCard(
                title: '90 ngày',
                price: _formatVnd(_monthly90DayPrice),
                subtitle: 'Tiết kiệm theo quý',
                isSelected: _selectedMonthlyDurationDays == 90,
                onTap: () =>
                    setState(() => _selectedMonthlyDurationDays = 90),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Student Concession toggle
        MetroCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const PhosphorIcon(
                  PhosphorIconsRegular.graduationCap,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ưu đãi HSSV (Giảm 50%)',
                      style: AppTypography.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Xuất trình thẻ HSSV hợp lệ khi qua cổng',
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isStudentDiscount,
                activeTrackColor: AppColors.primary,
                activeThumbColor: Colors.white,
                onChanged: (val) {
                  setState(() => _isStudentDiscount = val);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _optionSelectCard({
    required String title,
    required String price,
    required String subtitle,
    String? badge,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return MetroCard(
      onTap: onTap,
      backgroundColor:
          isSelected ? AppColors.primarySubtle : AppColors.surface,
      border: Border.all(
        color: isSelected ? AppColors.primary : AppColors.borderSubtle,
        width: isSelected ? 1.6 : 1.0,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (badge != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 6),
          ],
          Text(
            title,
            style: AppTypography.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: isSelected ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            price,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTypography.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepperButton({
    required PhosphorIconData icon,
    required VoidCallback? onPressed,
  }) {
    final isEnabled = onPressed != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: PhosphorIcon(
            icon,
            size: 16,
            color: isEnabled ? AppColors.primary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  // --- 4. PARKING RESERVATION SECTION ---
  // --- 4. PARKING RESERVATION SECTION (DEDICATED PARALLEL FLOW) ---
  Widget _buildParkingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const PhosphorIcon(
                  PhosphorIconsBold.car,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'ĐẶT CHỖ GIỮ XE TẠI GA',
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: const Text(
                '14 nhà ga sẵn sàng',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'Bảo đảm có chỗ đỗ xe tại nhà ga, quét biển số nhận diện tự động khi vào/ra cổng.',
          style: AppTypography.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Active Parking Form Card
        MetroCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Station selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bãi giữ xe tại ga:',
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  InkWell(
                    onTap: _pickParkingStation,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const PhosphorIcon(PhosphorIconsFill.mapPin, size: 13, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Ga $_parkingStation',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 3),
                          const PhosphorIcon(PhosphorIconsRegular.caretDown, size: 12, color: AppColors.primary),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // 2. Vehicle Owner Name
              Text(
                'Họ tên chủ xe',
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _parkingOwnerController,
                decoration: InputDecoration(
                  hintText: 'Nhập họ tên chủ xe',
                  prefixIcon: const PhosphorIcon(PhosphorIconsRegular.user, size: 18),
                  filled: true,
                  fillColor: AppColors.surfaceSecondary,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: const BorderSide(color: AppColors.borderSubtle),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // 3. License Plate Number
              Text(
                'Biển số xe',
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _parkingPlateController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'VD: 59-A1 123.45 hoặc 51F-888.88',
                  prefixIcon: const PhosphorIcon(PhosphorIconsRegular.identificationBadge, size: 18),
                  filled: true,
                  fillColor: AppColors.surfaceSecondary,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: const BorderSide(color: AppColors.borderSubtle),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: AppSpacing.md),

              // 4. Vehicle Type Selection
              Text(
                'Loại phương tiện',
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _buildVehicleTypeChip(
                      type: 'Xe máy',
                      icon: PhosphorIconsRegular.motorcycle,
                      isSelected: _parkingVehicleType == 'Xe máy',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _buildVehicleTypeChip(
                      type: 'Ô tô',
                      icon: PhosphorIconsRegular.car,
                      isSelected: _parkingVehicleType == 'Ô tô',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // 5. Parking Package Selection (1 buổi 5k, 1 ngày 10k, Qua đêm 15k)
              Text(
                'Gói thời gian giữ xe',
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _buildParkingPackageCard(
                      title: '1 buổi',
                      subtitle: 'Dưới 6 tiếng',
                      priceVnd: _parkingVehicleType == 'Xe máy' ? 5000 : 25000,
                      isSelected: _parkingPackage == '1 buổi',
                      badge: 'Phổ biến',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: _buildParkingPackageCard(
                      title: '1 ngày',
                      subtitle: '05:00 - 23:00',
                      priceVnd: _parkingVehicleType == 'Xe máy' ? 10000 : 50000,
                      isSelected: _parkingPackage == '1 ngày',
                      badge: 'Tiết kiệm',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: _buildParkingPackageCard(
                      title: 'Qua đêm',
                      subtitle: '24 giờ',
                      priceVnd: _parkingVehicleType == 'Xe máy' ? 15000 : 70000,
                      isSelected: _parkingPackage == 'Qua đêm',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // 6. Parking Payment Amount Box ("sau đó hiện ra số tiền thanh toán")
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const PhosphorIcon(PhosphorIconsFill.checkCircle, color: AppColors.primary, size: 18),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Số tiền giữ xe ($_parkingPackage)',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'Bảo đảm có chỗ tại Ga $_parkingStation',
                              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      _formatVnd(_parkingFee),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // 7. Security & Facilities Card
        MetroCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          backgroundColor: AppColors.surfaceSecondary,
          child: Column(
            children: [
              _parkingAmenityRow(
                icon: PhosphorIconsFill.shieldCheck,
                title: 'Bảo đảm an ninh tuyệt đối',
                desc: 'Camera AI giám sát 24/7 và nhân viên bảo vệ thường trực tại các cửa bãi xe.',
              ),
              const SizedBox(height: 10),
              _parkingAmenityRow(
                icon: PhosphorIconsFill.lightning,
                title: 'Hỗ trợ trạm sạc xe điện EV',
                desc: 'Trang bị trụ sạc nhanh cho xe máy điện và ô tô điện tại Ga Bến Thành & Suối Tiên.',
              ),
              const SizedBox(height: 10),
              _parkingAmenityRow(
                icon: PhosphorIconsFill.qrCode,
                title: 'Thanh toán & Vào bãi bằng QR',
                desc: 'Mã QR giữ xe được phát hành ngay sau khi thanh toán, tự động mở barie khi quét.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _parkingAmenityRow({
    required PhosphorIconData icon,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PhosphorIcon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 1),
              Text(
                desc,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleTypeChip({
    required String type,
    required PhosphorIconData icon,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _parkingVehicleType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderSubtle,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PhosphorIcon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              type,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParkingPackageCard({
    required String title,
    required String subtitle,
    required int priceVnd,
    required bool isSelected,
    String? badge,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _parkingPackage = title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderSubtle,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (badge != null)
              Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.borderSubtle,
                  ),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              )
            else
              const SizedBox(height: 15),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatVnd(priceVnd),
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- SECTION DIVIDER ---
  Widget _buildSectionDivider({
    required String tag,
    required String title,
    required PhosphorIconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.border)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PhosphorIcon(icon, size: 13, color: AppColors.primary),
                    const SizedBox(width: 5),
                    Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Expanded(child: Divider(color: AppColors.border)),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          title,
          style: AppTypography.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _stationTogglePill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          boxShadow: isSelected ? AppShadows.subtle : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  // --- 5. BUS CONNECTIONS SECTION ---
  Widget _buildBusConnectionsSection() {
    final currentStationName = _selectedType == TicketType.singleRide
        ? (_selectedBusStationIndex == 0 ? _originStation : _destinationStation)
        : _originStation;

    final busList = StationConnectionsData.getBusConnections(currentStationName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const PhosphorIcon(
                  PhosphorIconsBold.bus,
                  size: 18,
                  color: Color(0xFF0284C7),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'LIÊN KẾT XE BUÝT TRUNG CHUYỂN',
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                '${busList.length} tuyến buýt',
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0284C7),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'Xe buýt đón/trả khách trực tiếp tại nhà ga, kết nối đa phương thức tới mọi điểm đến.',
          style: AppTypography.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Station switcher pills (if single ride: Ga đi vs Ga đến)
        if (_selectedType == TicketType.singleRide)
          Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _stationTogglePill(
                    label: 'Tại Ga đi: $_originStation',
                    isSelected: _selectedBusStationIndex == 0,
                    onTap: () => setState(() => _selectedBusStationIndex = 0),
                  ),
                ),
                Expanded(
                  child: _stationTogglePill(
                    label: 'Tại Ga đến: $_destinationStation',
                    isSelected: _selectedBusStationIndex == 1,
                    onTap: () => setState(() => _selectedBusStationIndex = 1),
                  ),
                ),
              ],
            ),
          ),

        // Bus cards list
        ...busList.map((bus) => _buildBusRouteCard(bus)),
      ],
    );
  }

  Widget _buildBusRouteCard(BusConnection bus) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: MetroCard(
        onTap: () => _showBusDetailSheet(context, bus),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Route Number Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: bus.isElectric ? const Color(0xFF10B981) : const Color(0xFF0284C7),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    bus.routeNumber.startsWith('Tuyến') || bus.routeNumber.startsWith('VinBus') || bus.routeNumber.startsWith('Water')
                        ? bus.routeNumber
                        : 'Tuyến ${bus.routeNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    bus.routeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (bus.isElectric)
                  Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                    ),
                    child: const Text(
                      'Xe điện',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const PhosphorIcon(
                        PhosphorIconsRegular.clock,
                        size: 13,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          bus.operatingHours,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const PhosphorIcon(
                        PhosphorIconsRegular.timer,
                        size: 13,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          bus.frequency,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  bus.fare,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const PhosphorIcon(PhosphorIconsFill.mapPin, size: 13, color: Color(0xFF0284C7)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    bus.busStopLocation,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const PhosphorIcon(PhosphorIconsRegular.caretRight, size: 14, color: AppColors.textMuted),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showBusDetailSheet(BuildContext context, BusConnection bus) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.75,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: bus.isElectric ? const Color(0xFF10B981) : const Color(0xFF0284C7),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Text(
                      'Tuyến ${bus.routeNumber}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bus.routeName,
                          style: AppTypography.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Kết nối trực tiếp Ga ${bus.connectingStation}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const PhosphorIcon(PhosphorIconsRegular.x, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  // Transit Info Grid
                  Row(
                    children: [
                      Expanded(
                        child: _busInfoBox('Giờ chạy', bus.operatingHours, PhosphorIconsRegular.clock),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _busInfoBox('Tần suất', bus.frequency, PhosphorIconsRegular.timer),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _busInfoBox('Giá vé', bus.fare, PhosphorIconsRegular.ticket),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Stop Location Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const PhosphorIcon(PhosphorIconsFill.mapPin, size: 18, color: Color(0xFF0284C7)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Vị trí đón xe tại nhà ga',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0284C7)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                bus.busStopLocation,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  Text(
                    'CÁC ĐIỂM TRUNG CHUYỂN CHÍNH',
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  ...bus.keyStops.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final stopName = entry.value;
                    final isFirst = idx == 0;
                    final isLast = idx == bus.keyStops.length - 1;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (isFirst || isLast) ? const Color(0xFF0284C7) : AppColors.surfaceSecondary,
                                border: Border.all(color: const Color(0xFF0284C7), width: 2),
                              ),
                            ),
                            if (!isLast)
                              Container(
                                width: 2,
                                height: 24,
                                color: AppColors.border,
                              ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              stopName,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: (isFirst || isLast) ? FontWeight.w700 : FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _busInfoBox(String label, String value, PhosphorIconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          PhosphorIcon(icon, size: 16, color: const Color(0xFF0284C7)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  // --- 6. STATION DESTINATIONS & ENTERTAINMENT SECTION ---
  Widget _buildStationDestinationsSection() {
    final currentStationName = _selectedType == TicketType.singleRide
        ? (_selectedDestStationIndex == 1 ? _destinationStation : _originStation)
        : _destinationStation;

    final allDestinations = StationConnectionsData.getDestinations(currentStationName);
    final filteredDestinations = _selectedDestCategory == null
        ? allDestinations
        : allDestinations.where((d) => d.category == _selectedDestCategory).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const PhosphorIcon(
                  PhosphorIconsBold.sparkle,
                  size: 18,
                  color: Color(0xFFDB2777),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'ĐIỂM ĐẾN & KHU VỰC GIẢI TRÍ QUANH GA',
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFCE7F3),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: const Text(
                'Khám phá',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFDB2777),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'Gợi ý các địa điểm vui chơi, mua sắm, ẩm thực và văn hóa nổi tiếng gần ga tàu.',
          style: AppTypography.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Station switcher (defaults to destination station where passenger gets off)
        if (_selectedType == TicketType.singleRide)
          Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _stationTogglePill(
                    label: 'Quanh Ga đến: $_destinationStation',
                    isSelected: _selectedDestStationIndex == 1,
                    onTap: () => setState(() => _selectedDestStationIndex = 1),
                  ),
                ),
                Expanded(
                  child: _stationTogglePill(
                    label: 'Quanh Ga đi: $_originStation',
                    isSelected: _selectedDestStationIndex == 0,
                    onTap: () => setState(() => _selectedDestStationIndex = 0),
                  ),
                ),
              ],
            ),
          ),

        // Category filter chips: [Tất cả] [Vui chơi] [Mua sắm] [Ẩm thực] [Văn hóa]
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _destFilterChip(label: 'Tất cả', category: null),
              const SizedBox(width: 6),
              _destFilterChip(label: 'Vui chơi & Giải trí', category: DestinationCategory.entertainment),
              const SizedBox(width: 6),
              _destFilterChip(label: 'Mua sắm', category: DestinationCategory.shopping),
              const SizedBox(width: 6),
              _destFilterChip(label: 'Ẩm thực & Cafe', category: DestinationCategory.dining),
              const SizedBox(width: 6),
              _destFilterChip(label: 'Văn hóa & Di tích', category: DestinationCategory.culture),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Destination Cards
        if (filteredDestinations.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Text(
              'Chưa có điểm đến cho danh mục này tại Ga $currentStationName',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          )
        else
          ...filteredDestinations.map((dest) => _buildDestinationCard(dest)),
      ],
    );
  }

  Widget _destFilterChip({required String label, required DestinationCategory? category}) {
    final isSelected = _selectedDestCategory == category;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedDestCategory = category),
      selectedColor: AppColors.primaryLight,
      checkmarkColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.borderSubtle,
        ),
      ),
      labelStyle: TextStyle(
        fontSize: 11.5,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
    );
  }

  Widget _buildDestinationCard(StationDestination dest) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: MetroCard(
        onTap: () => _showDestinationDetailSheet(context, dest),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Category Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: dest.category.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: PhosphorIcon(
                    dest.icon,
                    size: 20,
                    color: dest.category.color,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dest.name,
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: dest.category.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
                            child: Text(
                              dest.category.label,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: dest.category.color,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const PhosphorIcon(PhosphorIconsFill.star, size: 12, color: Color(0xFFF59E0B)),
                          const SizedBox(width: 2),
                          Text(
                            dest.rating.toString(),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Distance & Walk time pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Row(
                    children: [
                      const PhosphorIcon(PhosphorIconsRegular.personSimpleWalk, size: 12, color: AppColors.primary),
                      const SizedBox(width: 3),
                      Text(
                        dest.walkTime,
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              dest.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const PhosphorIcon(PhosphorIconsFill.door, size: 13, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    dest.exitGate,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ),
                Text(
                  'Cách ${dest.distance}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDestinationDetailSheet(BuildContext context, StationDestination dest) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.75,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: dest.category.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: PhosphorIcon(dest.icon, size: 24, color: dest.category.color),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dest.name,
                          style: AppTypography.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Gần Ga ${dest.stationName} • Cách ${dest.distance} (${dest.walkTime})',
                          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const PhosphorIcon(PhosphorIconsRegular.x, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  // Highlights pills
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: dest.highlights.map((h) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          h,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  Text(
                    dest.description,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Route guide from station gate
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            PhosphorIcon(PhosphorIconsFill.navigationArrow, size: 16, color: AppColors.primary),
                            SizedBox(width: 6),
                            Text(
                              'HƯỚNG DẪN ĐI BỘ TỪ GA METRO',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '1. Xuống tàu tại Ga ${dest.stationName}, di chuyển theo biển chỉ dẫn ra: ${dest.exitGate}.',
                          style: const TextStyle(fontSize: 12.5, height: 1.4),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '2. Đi bộ khoảng ${dest.distance} (${dest.walkTime}) dọc theo lối đi bộ an toàn có mái che.',
                          style: const TextStyle(fontSize: 12.5, height: 1.4),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '3. Điểm đến nằm ngay phía trước, có thể kết nối thuận tiện bằng xe buýt hoặc buýt sông lân cận.',
                          style: TextStyle(fontSize: 12.5, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
