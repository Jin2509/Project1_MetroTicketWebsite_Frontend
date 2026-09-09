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

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
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

  int get _totalPrice => _unitPrice * _quantity;

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

  void _proceedToPayment() {
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
        'totalPrice': _totalPrice,
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
                            'Tổng tiền ($_quantity vé)',
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
}
