import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';

class TicketFilterState {
  final String dateRange;
  final String ticketType;
  final String status;

  const TicketFilterState({
    this.dateRange = 'Tất cả',
    this.ticketType = 'Tất cả',
    this.status = 'Tất cả',
  });

  TicketFilterState copyWith({
    String? dateRange,
    String? ticketType,
    String? status,
  }) {
    return TicketFilterState(
      dateRange: dateRange ?? this.dateRange,
      ticketType: ticketType ?? this.ticketType,
      status: status ?? this.status,
    );
  }
}

/// HistoryFilterSheet:
/// Modal bottom sheet allowing passengers to filter their ticket history
/// by date range, ticket type, and status using pill-shaped filter chips.
class HistoryFilterSheet extends StatefulWidget {
  final TicketFilterState initialFilters;
  final ValueChanged<TicketFilterState> onApply;

  const HistoryFilterSheet({
    super.key,
    required this.initialFilters,
    required this.onApply,
  });

  static void show(
    BuildContext context, {
    required TicketFilterState currentFilters,
    required ValueChanged<TicketFilterState> onApply,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HistoryFilterSheet(
        initialFilters: currentFilters,
        onApply: onApply,
      ),
    );
  }

  @override
  State<HistoryFilterSheet> createState() => _HistoryFilterSheetState();
}

class _HistoryFilterSheetState extends State<HistoryFilterSheet> {
  late String _dateRange;
  late String _ticketType;
  late String _status;

  final List<String> _dateOptions = [
    'Tất cả',
    'Tuần này',
    'Tháng này',
    '3 tháng qua',
    'Năm 2026',
  ];

  final List<String> _typeOptions = [
    'Tất cả',
    'Vé lượt',
    'Vé ngày',
    'Vé tháng',
  ];

  final List<String> _statusOptions = [
    'Tất cả',
    'Đã sử dụng',
    'Hết hạn',
    'Đã hủy',
  ];

  @override
  void initState() {
    super.initState();
    _dateRange = widget.initialFilters.dateRange;
    _ticketType = widget.initialFilters.ticketType;
    _status = widget.initialFilters.status;
  }

  void _reset() {
    setState(() {
      _dateRange = 'Tất cả';
      _ticketType = 'Tất cả';
      _status = 'Tất cả';
    });
  }

  void _apply() {
    widget.onApply(
      TicketFilterState(
        dateRange: _dateRange,
        ticketType: _ticketType,
        status: _status,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xl),
          topRight: Radius.circular(AppRadius.xl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const PhosphorIcon(
                        PhosphorIconsRegular.funnel,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Bộ lọc lịch sử vé',
                        style: AppTypography.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _reset,
                    child: Text(
                      'Đặt lại',
                      style: AppTypography.textTheme.labelMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Date Range
                    _sectionTitle('KHOẢNG THỜI GIAN'),
                    const SizedBox(height: AppSpacing.sm),
                    _chipGroup(
                      options: _dateOptions,
                      selected: _dateRange,
                      onSelected: (val) => setState(() => _dateRange = val),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Section 2: Ticket Type
                    _sectionTitle('LOẠI VÉ'),
                    const SizedBox(height: AppSpacing.sm),
                    _chipGroup(
                      options: _typeOptions,
                      selected: _ticketType,
                      onSelected: (val) => setState(() => _ticketType = val),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Section 3: Status
                    _sectionTitle('TRẠNG THÁI'),
                    const SizedBox(height: AppSpacing.sm),
                    _chipGroup(
                      options: _statusOptions,
                      selected: _status,
                      onSelected: (val) => setState(() => _status = val),
                    ),

                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),

            // Bottom CTAs
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: PrimaryButton(
                text: 'Áp dụng bộ lọc',
                trailingIcon: PhosphorIconsRegular.check,
                onPressed: _apply,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.textTheme.labelSmall?.copyWith(
        color: AppColors.textSecondary,
        letterSpacing: 1.1,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _chipGroup({
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelected,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSelected = selected == opt;
        return GestureDetector(
          onTap: () => onSelected(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryLight
                  : AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.borderSubtle,
                width: isSelected ? 1.4 : 1.0,
              ),
            ),
            child: Text(
              opt,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textPrimary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
