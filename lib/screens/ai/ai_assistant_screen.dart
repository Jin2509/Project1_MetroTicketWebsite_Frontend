import 'dart:async';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../models/ticket_model.dart';
import '../../models/transit_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/metro_card.dart';
import '../../widgets/screen_switcher_sheet.dart';
import '../booking/booking_flow_screen.dart';
import '../search/route_detail_screen.dart';

enum RichCardType {
  none,
  routeSuggestion,
  fareComparison,
  stationGuide,
}

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final RichCardType richCardType;
  final Map<String, dynamic>? cardData;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.richCardType = RichCardType.none,
    this.cardData,
  });
}

/// Screen: AI Assistant Screen (Chat-style)
/// Header with bot avatar & active status, distinct message bubbles (blue for user, gray for bot),
/// rich interactive cards, quick-reply suggestion chips, voice mic input, and animated 3-dot typing indicator.
class AiAssistantScreen extends StatefulWidget {
  final bool showBackButton;

  const AiAssistantScreen({super.key, this.showBackButton = true});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  final List<ChatMessage> _messages = [
    ChatMessage(
      id: 'm1',
      text:
          'Xin chào Alex! Tôi là Trợ lý AI MetroGo. Bạn cần hỗ trợ gì về lộ trình, tra cứu giờ tàu hay vé đi lại hôm nay?',
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  final List<String> _quickReplies = [
    'Ga nào gần tôi nhất?',
    'Giá vé tháng bao nhiêu?',
    'Ga Bến Thành ở đâu?',
    'Tuyến 1 có trễ giờ không?',
    'Mua vé sinh viên giảm 50%',
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isTyping = true;
    });
    _textController.clear();
    _scrollToBottom();

    // Simulate AI response with typing delay
    Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;

      ChatMessage botReply;
      final lower = text.toLowerCase();

      if (lower.contains('gần') || lower.contains('tuyến') || lower.contains('nearest') || lower.contains('line')) {
        botReply = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text:
              'Dựa trên vị trí hiện tại của bạn tại Quận 1, Ga Bến Thành (Tuyến 1) cách bạn chỉ 250m. Gợi ý chuyến tàu phù hợp nhất:',
          isUser: false,
          timestamp: DateTime.now(),
          richCardType: RichCardType.routeSuggestion,
          cardData: {
            'route': 'Bến Thành → Suối Tiên',
            'line': 'Tuyến 1 (Tốc hành)',
            'time': '32 phút • 14 nhà ga',
            'fare': '15.000 đ',
            'departure': 'Chuyến tiếp theo sau 2 phút (Ga đón số 2)',
          },
        );
      } else if (lower.contains('giá') || lower.contains('tháng') || lower.contains('vé') || lower.contains('price')) {
        botReply = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text:
              'Vé tháng đi lại không giới hạn có giá 260.000 đ/tháng. Học sinh, sinh viên được giảm 50% chỉ còn 130.000 đ:',
          isUser: false,
          timestamp: DateTime.now(),
          richCardType: RichCardType.fareComparison,
          cardData: {
            'title': 'Vé Tháng 30 Ngày',
            'standardPrice': '260.000 đ',
            'studentPrice': '130.000 đ (-50%)',
            'benefit': 'Không giới hạn chuyến trên toàn bộ các tuyến trong 30 ngày',
          },
        );
      } else if (lower.contains('bến thành') || lower.contains('ở đâu') || lower.contains('ga')) {
        botReply = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text:
              'Ga Bến Thành là ga ngầm trung tâm tại Quảng trường Quách Thị Trang, kết nối trực tiếp Tuyến 1, Tuyến 2 và trạm xe buýt trung tâm.',
          isUser: false,
          timestamp: DateTime.now(),
          richCardType: RichCardType.stationGuide,
          cardData: {
            'name': 'Ga Trung Tâm Bến Thành',
            'code': 'L1-01 / L2-01',
            'gates': '6 Cửa ra vào có đầy đủ thang máy & thang cuốn',
            'interchange': 'Chuyển tiếp Tuyến 1, Tuyến 2 & Xe buýt',
          },
        );
      } else if (lower.contains('trễ') || lower.contains('delay') || lower.contains('tình hình')) {
        botReply = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text:
              'Tuyến 1 (Bến Thành – Suối Tiên) đang hoạt động bình thường với tỷ lệ đúng giờ 100%. Các chuyến tàu khởi hành mỗi 4.5 phút trong giờ cao điểm.',
          isUser: false,
          timestamp: DateTime.now(),
        );
      } else {
        botReply = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text:
              'Tôi có thể hỗ trợ bạn kiểm tra lịch trình, tính giá vé, tìm nhà ga và theo dõi vị trí tàu trực tiếp thời gian thực. Hãy thử bấm vào các gợi ý bên dưới nhé!',
          isUser: false,
          timestamp: DateTime.now(),
        );
      }

      setState(() {
        _isTyping = false;
        _messages.add(botReply);
      });
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: const Border(
              bottom: BorderSide(color: AppColors.borderSubtle, width: 1),
            ),
            boxShadow: AppShadows.subtle,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  if (widget.showBackButton) ...[
                    IconButton(
                      icon: const PhosphorIcon(
                        PhosphorIconsRegular.arrowLeft,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                  ],

                  // Bot Avatar with Stylized Robot Icon on Circular Light Blue
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                    child: const Center(
                      child: PhosphorIcon(
                        PhosphorIconsFill.sparkle,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),

                  // Name & Active Status
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MetroGo Assistant',
                          style: AppTypography.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Trực tuyến • Hỗ trợ AI',
                              style: AppTypography.textTheme.bodySmall?.copyWith(
                                color: AppColors.successText,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const ScreenSwitcherButton(),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // CHAT MESSAGES AREA
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.lg,
                ),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isTyping) {
                    return const _TypingIndicatorBubble();
                  }
                  final msg = _messages[index];
                  return _buildMessageBubble(msg);
                },
              ),
            ),

            // QUICK-REPLY SUGGESTION CHIPS
            Container(
              height: 40,
              margin: const EdgeInsets.only(bottom: 6),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                itemCount: _quickReplies.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: AppSpacing.xs),
                itemBuilder: (context, index) {
                  final reply = _quickReplies[index];
                  return ActionChip(
                    label: Text(
                      reply,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    backgroundColor: AppColors.primaryLight,
                    side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    onPressed: () => _sendMessage(reply),
                  );
                },
              ),
            ),

            // INPUT BAR AT BOTTOM
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs + 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: const Border(
                  top: BorderSide(color: AppColors.borderSubtle, width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A1D29).withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Voice input mic icon placeholder
                  IconButton(
                    icon: const PhosphorIcon(
                      PhosphorIconsRegular.microphone,
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đang lắng nghe giọng nói...'),
                          backgroundColor: AppColors.primary,
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),

                  // Text Field
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _sendMessage,
                      decoration: InputDecoration(
                        hintText: 'Hỏi bất cứ điều gì về MetroGo...',
                        hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceSecondary,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: AppSpacing.xs),

                  // Send Button
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: AppShadows.buttonPrimary,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        onTap: () => _sendMessage(_textController.text),
                        child: const Center(
                          child: PhosphorIcon(
                            PhosphorIconsFill.paperPlaneRight,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
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

  Widget _buildMessageBubble(ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment:
            msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!msg.isUser) ...[
                Container(
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.only(right: 8, bottom: 4),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: PhosphorIcon(
                      PhosphorIconsFill.sparkle,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: msg.isUser
                        ? AppColors.primary
                        : AppColors.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(AppRadius.xl),
                      topRight: const Radius.circular(AppRadius.xl),
                      bottomLeft: Radius.circular(msg.isUser ? AppRadius.xl : AppRadius.sm),
                      bottomRight: Radius.circular(msg.isUser ? AppRadius.sm : AppRadius.xl),
                    ),
                    border: msg.isUser
                        ? null
                        : Border.all(color: AppColors.borderSubtle),
                    boxShadow: AppShadows.subtle,
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: msg.isUser ? Colors.white : AppColors.textPrimary,
                      fontWeight:
                          msg.isUser ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // RICH EMBEDDED CARDS
          if (msg.richCardType != RichCardType.none && msg.cardData != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 36, top: 8),
              child: _buildRichCard(msg.richCardType, msg.cardData!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRichCard(RichCardType type, Map<String, dynamic> data) {
    switch (type) {
      case RichCardType.routeSuggestion:
        return MetroCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      data['line'],
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Text(
                    data['fare'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                data['route'],
                style: AppTypography.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                data['time'],
                style: AppTypography.textTheme.bodySmall,
              ),
              const SizedBox(height: 2),
              Text(
                data['departure'],
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: AppColors.successText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => RouteDetailScreen(
                              line: TransitData.lines[0],
                            ),
                          ),
                        );
                      },
                      icon: const PhosphorIcon(
                        PhosphorIconsRegular.gitBranch,
                        size: 14,
                      ),
                      label: const Text('Danh sách ga'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const BookingFlowScreen(
                              initialType: TicketType.singleRide,
                            ),
                          ),
                        );
                      },
                      icon: const PhosphorIcon(
                        PhosphorIconsRegular.ticket,
                        size: 14,
                      ),
                      label: const Text('Đặt vé ngay'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

      case RichCardType.fareComparison:
        return MetroCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data['title'],
                style: AppTypography.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'Tiêu chuẩn: ${data['standardPrice']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    data['studentPrice'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.successText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                data['benefit'],
                style: AppTypography.textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const BookingFlowScreen(
                        initialType: TicketType.monthlyPass,
                      ),
                    ),
                  );
                },
                icon: const PhosphorIcon(
                  PhosphorIconsRegular.shoppingBag,
                  size: 14,
                ),
                label: const Text('Mua vé tháng ngay'),
              ),
            ],
          ),
        );

      case RichCardType.stationGuide:
        return MetroCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data['name'],
                style: AppTypography.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                data['gates'],
                style: AppTypography.textTheme.bodySmall,
              ),
              const SizedBox(height: 2),
              Text(
                data['interchange'],
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed('/live-map');
                },
                icon: const PhosphorIcon(
                  PhosphorIconsRegular.navigationArrow,
                  size: 14,
                ),
                label: const Text('Xem ga trên bản đồ'),
              ),
            ],
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

/// Animated 3-dot typing indicator bubble
class _TypingIndicatorBubble extends StatefulWidget {
  const _TypingIndicatorBubble();

  @override
  State<_TypingIndicatorBubble> createState() => _TypingIndicatorBubbleState();
}

class _TypingIndicatorBubbleState extends State<_TypingIndicatorBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 8, bottom: 4),
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: PhosphorIcon(
                PhosphorIconsFill.sparkle,
                size: 14,
                color: AppColors.primary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.xl),
                topRight: Radius.circular(AppRadius.xl),
                bottomRight: Radius.circular(AppRadius.xl),
                bottomLeft: Radius.circular(AppRadius.sm),
              ),
              border: Border.all(color: AppColors.borderSubtle),
              boxShadow: AppShadows.subtle,
            ),
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final delay = index * 0.2;
                    final progress = (_animController.value - delay) % 1.0;
                    final bounce = (progress < 0.5)
                        ? (progress * 2)
                        : (1.0 - (progress - 0.5) * 2);

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2.5),
                      width: 7,
                      height: 7,
                      transform: Matrix4.translationValues(
                        0,
                        -6 * bounce,
                        0,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(
                          alpha: 0.3 + (0.7 * bounce),
                        ),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
