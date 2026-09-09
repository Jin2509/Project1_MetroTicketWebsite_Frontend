import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../models/ticket_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/metro_app_bar.dart';
import '../../widgets/metro_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/screen_switcher_sheet.dart';
import '../booking/booking_flow_screen.dart';

class FarePlan {
  final String title;
  final String price;
  final String period;
  final String description;
  final List<String> features;
  final bool isPopular;
  final TicketType type;

  const FarePlan({
    required this.title,
    required this.price,
    required this.period,
    required this.description,
    required this.features,
    this.isPopular = false,
    required this.type,
  });
}

/// Screen: Fare Table Screen
/// Comparison cards for ticket types (Single ride, Day pass, Monthly pass),
/// showing name, price, short description, features, and "Book now" button.
class FareTableScreen extends StatelessWidget {
  const FareTableScreen({super.key});

  static const List<FarePlan> plans = [
    FarePlan(
      title: 'Vé lượt từng chặng',
      price: '15.000 – 20.000 đ',
      period: 'lượt',
      description: 'Vé tính giá theo cự ly di chuyển thực tế.',
      type: TicketType.singleRide,
      features: [
        'Hiệu lực 4 giờ kể từ khi quét thẻ qua cổng vào',
        'Quét mã QR trực tiếp tại cửa kiểm soát',
        'Áp dụng trên toàn bộ các tuyến metro đang vận hành',
      ],
    ),
    FarePlan(
      title: 'Vé 1 ngày không giới hạn',
      price: '40.000 đ',
      period: '24 giờ',
      isPopular: true,
      description: 'Đi lại không giới hạn trên toàn hệ thống trong 24 giờ.',
      type: TicketType.dayPass,
      features: [
        'Không giới hạn số lượt ra vào cổng trong 24 giờ',
        'Lựa chọn tối ưu cho du khách và đi lại trong ngày',
        'Bao gồm trung chuyển xe buýt gom và Waterbus',
      ],
    ),
    FarePlan(
      title: 'Vé 3 ngày khám phá',
      price: '90.000 đ',
      period: '72 giờ',
      description: 'Di chuyển thuận tiện 3 ngày liên tục khắp đô thị.',
      type: TicketType.dayPass,
      features: [
        'Hiệu lực trong 72 giờ liên tục từ lần chạm đầu',
        'Toàn quyền tiếp cận mạng lưới tuyến không cần nạp tiền',
        'Hỗ trợ ưu tiên tại quầy thông tin nhà ga',
      ],
    ),
    FarePlan(
      title: 'Vé tháng đi lại',
      price: '260.000 đ',
      period: 'tháng',
      description: 'Đi lại không giới hạn cả tháng dành cho người đi học, đi làm.',
      type: TicketType.monthlyPass,
      features: [
        'Không giới hạn lượt đi trong 30 ngày dương lịch',
        'Giảm 50% cho học sinh, sinh viên (130.000 đ)',
        'Vé điện tử tích hợp mã QR và sao lưu thẻ cứng',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MetroAppBar(
        title: 'Bảng giá vé Metro',
        actions: const [
          ScreenSwitcherButton(),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CHÍNH SÁCH GIÁ VÉ CHÍNH THỨC',
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Biểu phí di chuyển minh bạch, tiết kiệm cho mọi hành khách.',
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // COMPARISON CARDS
              ...plans.map((plan) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _buildFareCard(context, plan),
                );
              }),

              const SizedBox(height: AppSpacing.md),

              // CONCESSION NOTES CARD
              MetroCard(
                backgroundColor: AppColors.primarySubtle,
                border: Border.all(
                  color: AppColors.primaryLight,
                  width: 1.2,
                ),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        PhosphorIcon(
                          PhosphorIconsRegular.info,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Text(
                          'Chính sách miễn giảm vé',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '• Miễn phí cho trẻ em dưới 6 tuổi (hoặc cao dưới 1,3m đi cùng người lớn).\n'
                      '• Giảm 50% cho học sinh, sinh viên và người cao tuổi từ 60 tuổi trở lên khi xuất trình giấy tờ hợp lệ.\n'
                      '• Miễn phí cho người khuyết tật và người có công với cách mạng.',
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFareCard(BuildContext context, FarePlan plan) {
    return MetroCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      border: Border.all(
        color: plan.isPopular ? AppColors.primary : AppColors.borderSubtle,
        width: plan.isPopular ? 1.6 : 1.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                plan.title,
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (plan.isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: const Text(
                    'PHỔ BIẾN NHẤT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                plan.price,
                style: AppTypography.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '/ ${plan.period}',
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            plan.description,
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Divider(height: 1),
          ),
          ...plan.features.map(
            (feat) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const PhosphorIcon(
                    PhosphorIconsRegular.checkCircle,
                    size: 16,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      feat,
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            text: 'Đặt vé ngay',
            height: 44,
            trailingIcon: PhosphorIconsRegular.arrowRight,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => BookingFlowScreen(
                    initialType: plan.type,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
