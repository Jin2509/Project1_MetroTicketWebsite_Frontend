import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../models/ticket_model.dart';
import '../../models/transit_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/metro_app_bar.dart';
import '../../widgets/metro_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/screen_switcher_sheet.dart';

/// Screen: Booking Flow Screen
/// Step 1: Segmented ticket type selection (Single ride / Day pass / Monthly pass)
/// Step 2: Dynamic sub-options (stations / durations / discounts)
/// Step 3: Quantity selector (+/- stepper) with live-updating total price
class BookingFlowScreen extends StatefulWidget {
  final TicketType initialType;

  const BookingFlowScreen({
    super.key,
    this.initialType = TicketType.singleRide,
  });

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
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

  // Parking Reservation state
  bool _addParking = false;
  late String _parkingStation;
  late final TextEditingController _parkingOwnerController;
  late final TextEditingController _parkingPlateController;
  String _parkingVehicleType = 'Xe máy'; // 'Xe máy' or 'Ô tô'
  String _parkingPackage = '1 buổi'; // '1 buổi', '1 ngày', 'Qua đêm'

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _parkingStation = _originStation;
    _parkingOwnerController = TextEditingController(text: 'Alex Nguyễn');
    _parkingPlateController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _parkingOwnerController.dispose();
    _parkingPlateController.dispose();
    super.dispose();
  }

  int get _parkingFee {
    if (!_addParking) return 0;
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
  int get _totalPrice => _ticketTotal + _parkingFee;

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

  void _proceedToPayment() {
    if (_addParking) {
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
    }

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
        'totalPrice': _totalPrice,
        // Parking reservation details
        'hasParking': _addParking,
        'parkingStation': _addParking ? _parkingStation : null,
        'parkingOwner': _addParking ? _parkingOwnerController.text.trim() : null,
        'parkingPlate': _addParking ? _parkingPlateController.text.trim().toUpperCase() : null,
        'parkingVehicle': _addParking ? _parkingVehicleType : null,
        'parkingPackage': _addParking ? _parkingPackage : null,
        'parkingFee': _parkingFee,
      },
    );
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

                    const SizedBox(height: AppSpacing.xl),

                    // 4. DỊCH VỤ GIỮ XE TẠI GA (TÙY CHỌN)
                    _buildParkingSection(),

                    const SizedBox(height: AppSpacing.xl),
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
                            _addParking
                                ? 'Tổng ($_quantity vé + Giữ xe)'
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
                        text: 'Tiếp tục',
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
            Switch.adaptive(
              value: _addParking,
              activeTrackColor: AppColors.primary,
              onChanged: (val) {
                setState(() {
                  _addParking = val;
                  if (val && _parkingStation.isEmpty) {
                    _parkingStation = _originStation;
                  }
                });
              },
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
        const SizedBox(height: AppSpacing.sm),

        // Inactive Preview Card
        if (!_addParking)
          MetroCard(
            onTap: () => setState(() => _addParking = true),
            backgroundColor: AppColors.surfaceSecondary,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const PhosphorIcon(
                    PhosphorIconsRegular.carProfile,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chưa chọn giữ xe tại ga',
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Chỉ từ 5.000 đ/buổi (10.000 đ/ngày) • Chạm để thêm',
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: AppColors.primaryText,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () => setState(() => _addParking = true),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                  ),
                  child: const Text('Thêm giữ xe', style: TextStyle(fontSize: 11, color: AppColors.primary)),
                ),
              ],
            ),
          )
        else
          // Active Parking Form Card
          MetroCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            border: Border.all(color: AppColors.primaryLight, width: 1.5),
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const PhosphorIcon(PhosphorIconsFill.mapPin, size: 12, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              'Ga $_parkingStation',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 2),
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
}
