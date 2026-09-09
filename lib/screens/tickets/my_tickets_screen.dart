import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../models/ticket_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/metro_app_bar.dart';
import '../../widgets/metro_card.dart';
import '../../widgets/metro_ticket_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/screen_switcher_sheet.dart';
import '../../widgets/status_badge.dart';
import 'history_filter_sheet.dart';
import 'ticket_detail_screen.dart';

/// Screen: My Tickets Screen
/// Two tabs: "Active" (large digital-ticket cards with perforated detail)
/// and "History" (filterable list of used/expired/cancelled tickets).
class MyTicketsScreen extends StatefulWidget {
  final int initialTabIndex;

  const MyTicketsScreen({super.key, this.initialTabIndex = 0});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TicketFilterState _filterState = const TicketFilterState();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openDetail(Ticket ticket) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TicketDetailScreen(ticket: ticket),
      ),
    );
  }

  void _openFilter() {
    HistoryFilterSheet.show(
      context,
      currentFilters: _filterState,
      onApply: (newFilters) {
        setState(() => _filterState = newFilters);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TicketStore.instance,
      builder: (context, _) {
        final activeList = TicketStore.instance.activeTickets;
        final historyList = _filterHistory(TicketStore.instance.historyTickets);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: MetroAppBar(
            showBackButton: false,
            title: 'Vé của tôi',
            actions: const [
              ScreenSwitcherButton(),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Top Custom Pill Tab Selector
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.xs,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.borderSubtle),
                      boxShadow: AppShadows.subtle,
                    ),
                    child: Row(
                      children: [
                        _tabButton(
                          index: 0,
                          title: 'Đang hoạt động (${activeList.length})',
                          icon: PhosphorIconsRegular.ticket,
                        ),
                        _tabButton(
                          index: 1,
                          title: 'Lịch sử (${TicketStore.instance.historyTickets.length})',
                          icon: PhosphorIconsRegular.clockCounterClockwise,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildActiveTab(activeList),
                      _buildHistoryTab(historyList),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _tabButton({
    required int index,
    required String title,
    required PhosphorIconData icon,
  }) {
    final isSelected = _tabController.index == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.animateTo(index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.sm),
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
                title,
                style: AppTypography.textTheme.labelMedium?.copyWith(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Active Tab: Large digital-ticket cards with perforated detail
  Widget _buildActiveTab(List<Ticket> activeTickets) {
    if (activeTickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const PhosphorIcon(
                PhosphorIconsRegular.ticket,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Không có vé đang hoạt động',
              style: AppTypography.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Mua vé lượt hoặc vé ngày, vé tháng để di chuyển nhanh chóng.',
              style: AppTypography.textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: 180,
              child: PrimaryButton(
                text: 'Đặt vé ngay',
                onPressed: () => Navigator.of(context).pushNamed('/booking'),
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        ...activeTickets.map((ticket) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: MetroTicketCard(
              ticket: ticket,
              onTap: () => _openDetail(ticket),
            ),
          );
        }),

        // Quick CTA to book another ticket
        MetroCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          onTap: () {
            Navigator.of(context).pushNamed('/booking');
          },
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const PhosphorIcon(
                  PhosphorIconsRegular.plus,
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
                      'Đặt thêm vé',
                      style: AppTypography.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Vé lượt, vé ngày hoặc gói vé tháng tiện lợi',
                      style: AppTypography.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const PhosphorIcon(
                PhosphorIconsRegular.caretRight,
                size: 16,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  // History Tab: Filterable list of used/expired/cancelled tickets
  Widget _buildHistoryTab(List<Ticket> historyTickets) {
    final hasActiveFilters = _filterState.status != 'Tất cả' ||
        _filterState.ticketType != 'Tất cả' ||
        _filterState.dateRange != 'Tất cả';

    return Column(
      children: [
        // Filter bar
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hiển thị ${historyTickets.length} chuyến đi',
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              InkWell(
                onTap: _openFilter,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: hasActiveFilters
                        ? AppColors.primaryLight
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(
                      color: hasActiveFilters
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      PhosphorIcon(
                        PhosphorIconsRegular.funnel,
                        size: 14,
                        color: hasActiveFilters
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        hasActiveFilters ? 'Đã lọc' : 'Bộ lọc',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: hasActiveFilters
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.xs),

        // History items
        Expanded(
          child: historyTickets.isEmpty
              ? Center(
                  child: Text(
                    'Không có chuyến đi phù hợp với bộ lọc.',
                    style: AppTypography.textTheme.bodySmall,
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: historyTickets.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final ticket = historyTickets[index];
                    return MetroCard(
                      onTap: () => _openDetail(ticket),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSecondary,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: const PhosphorIcon(
                              PhosphorIconsRegular.ticket,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        ticket.title,
                                        style: AppTypography
                                            .textTheme.titleSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    StatusBadge(status: ticket.status),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  ticket.validityText,
                                  style: AppTypography.textTheme.bodySmall
                                      ?.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  ticket.formattedPrice,
                                  style: AppTypography.textTheme.labelMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          const PhosphorIcon(
                            PhosphorIconsRegular.caretRight,
                            size: 16,
                            color: AppColors.textMuted,
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  List<Ticket> _filterHistory(List<Ticket> list) {
    return list.where((t) {
      if (_filterState.status != 'Tất cả') {
        if (_filterState.status == 'Đã sử dụng' && t.status != TicketStatus.used) {
          return false;
        }
        if (_filterState.status == 'Hết hạn' &&
            t.status != TicketStatus.expired) {
          return false;
        }
      }
      if (_filterState.ticketType != 'Tất cả') {
        if (_filterState.ticketType == 'Vé lượt' &&
            t.type != TicketType.singleRide) {
          return false;
        }
        if (_filterState.ticketType == 'Vé ngày' &&
            t.type != TicketType.dayPass) {
          return false;
        }
        if (_filterState.ticketType == 'Vé tháng' &&
            t.type != TicketType.monthlyPass) {
          return false;
        }
      }
      return true;
    }).toList();
  }
}
