import 'dart:async';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../theme/app_theme.dart';
import '../../widgets/metro_card.dart';
import '../booking/booking_flow_screen.dart';

enum CompactRichCardType {
  none,
  routeSuggestion,
  fareComparison,
  stationGuide,
}

class CompactChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final CompactRichCardType richCardType;
  final Map<String, dynamic>? cardData;

  CompactChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.richCardType = CompactRichCardType.none,
    this.cardData,
  });
}

/// Compact Floating AI Chat Widget / Modal Sheet:
/// Displays a compact floating chat box occupying ~65-70% screen height over the live map.
/// Includes header with bot avatar and close button, message bubbles,
/// animated 3-dot typing indicator, interactive rich cards, quick-reply chips,
/// and bottom input bar with send and voice mic buttons.
class CompactAiChatSheet extends StatefulWidget {
  final VoidCallback? onClose;
  final void Function(String routeName)? onSelectRoute;

  const CompactAiChatSheet({
    super.key,
    this.onClose,
    this.onSelectRoute,
  });

  static void show(
    BuildContext context, {
    void Function(String routeName)? onSelectRoute,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CompactAiChatSheet(
        onSelectRoute: onSelectRoute,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  State<CompactAiChatSheet> createState() => _CompactAiChatSheetState();
}

class _CompactAiChatSheetState extends State<CompactAiChatSheet> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  final List<CompactChatMessage> _messages = [
    CompactChatMessage(
      id: 'c1',
      text:
          'Xin chào Alex! Tôi là Trợ lý AI MetroGo. Bạn cần hỗ trợ gì về lộ trình, tra cứu giờ tàu hay vé đi lại hôm nay?',
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
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
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final userMsg = CompactChatMessage(
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

    Timer(const Duration(milliseconds: 1100), () {
      if (!mounted) return;

      CompactChatMessage botReply;
      final lower = text.toLowerCase();

      if (lower.contains('gần') || lower.contains('tuyến') || lower.contains('nearest') || lower.contains('line')) {
        botReply = CompactChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text:
              'Dựa trên vị trí hiện tại của bạn tại Quận 1, Ga Bến Thành (Tuyến 1) cách bạn chỉ 250m. Gợi ý chuyến tàu phù hợp nhất:',
          isUser: false,
          timestamp: DateTime.now(),
          richCardType: CompactRichCardType.routeSuggestion,
          cardData: {
            'route': 'Bến Thành → Suối Tiên',
            'line': 'Tuyến 1 (Line 1)',
            'time': '32 phút • 14 ga',
            'fare': '15.000 đ',
            'departure': 'Chuyến kế tiếp: 2 phút (Ke ga số 2)',
          },
        );
      } else if (lower.contains('giá') || lower.contains('tháng') || lower.contains('vé') || lower.contains('price')) {
        botReply = CompactChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text:
              'Vé tháng không giới hạn lượt đi là 260.000 đ/tháng. Học sinh, sinh viên được ưu đãi giảm 50% chỉ còn 130.000 đ:',
          isUser: false,
          timestamp: DateTime.now(),
          richCardType: CompactRichCardType.fareComparison,
          cardData: {
            'title': 'Vé Tháng 30 Ngày',
            'standardPrice': '260.000 đ',
            'studentPrice': '130.000 đ (-50%)',
            'benefit': 'Không giới hạn chuyến trên Tuyến 1 & Tuyến 2',
          },
        );
      } else if (lower.contains('bến thành') || lower.contains('ở đâu') || lower.contains('ga')) {
        botReply = CompactChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text:
              'Ga Bến Thành là ga ngầm trung tâm dưới Quảng trường Quách Thị Trang, kết nối trực tiếp Tuyến 1, Tuyến 2 và trạm trung chuyển xe buýt Hàm Nghi.',
          isUser: false,
          timestamp: DateTime.now(),
          richCardType: CompactRichCardType.stationGuide,
          cardData: {
            'name': 'Ga Trung Tâm Bến Thành',
            'code': 'L1-01 / L2-01',
            'gates': '6 Cửa ra vào với thang máy & thang cuốn',
            'interchange': 'Chuyển tuyến Line 1 & Line 2',
          },
        );
      } else if (lower.contains('trễ') || lower.contains('delay')) {
        botReply = CompactChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text:
              'Hiện tại Tuyến 1 đang hoạt động ổn định với 6 đoàn tàu. Tàu #104 đang đến ga Ba Son đúng lịch trình (tốc độ 58 km/h). Không có cảnh báo sự cố kỹ thuật.',
          isUser: false,
          timestamp: DateTime.now(),
        );
      } else {
        botReply = CompactChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text:
              'Tôi đã ghi nhận câu hỏi của bạn. Hệ thống MetroGo đang cập nhật liên tục tọa độ GPS và lịch trình tàu. Bạn có thể xem vị trí tàu thời gian thực ngay trên bản đồ nền phía sau.',
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
    final mediaQuery = MediaQuery.of(context);
    final sheetHeight = mediaQuery.size.height * 0.70;

    return Container(
      height: sheetHeight,
      margin: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xl),
          topRight: Radius.circular(AppRadius.xl),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x221A1D29),
            blurRadius: 30,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 4),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),

          // Compact Header
          _buildHeader(context),

          const Divider(height: 1, color: AppColors.borderSubtle),

          // Chat message list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _messages.length) {
                  return _buildMessageBubble(_messages[index]);
                }
                return _buildTypingIndicator();
              },
            ),
          ),

          // Quick Replies
          _buildQuickReplyChips(),

          // Input Bar
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          // Bot Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            child: const Center(
              child: PhosphorIcon(
                PhosphorIconsFill.sparkle,
                size: 18,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Assistant Info
          Expanded(
            child: Column(
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

          // Close button
          IconButton(
            onPressed: () {
              if (widget.onClose != null) {
                widget.onClose!();
              } else {
                Navigator.of(context).pop();
              }
            },
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: const PhosphorIcon(
                PhosphorIconsRegular.x,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(CompactChatMessage message) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              margin: const EdgeInsets.only(top: 2, right: 8),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: PhosphorIcon(
                  PhosphorIconsFill.sparkle,
                  size: 13,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.primary : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(AppRadius.xl),
                      topRight: const Radius.circular(AppRadius.xl),
                      bottomLeft: Radius.circular(isUser ? AppRadius.xl : AppRadius.sm),
                      bottomRight: Radius.circular(isUser ? AppRadius.sm : AppRadius.xl),
                    ),
                    boxShadow: isUser
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    message.text,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: isUser ? Colors.white : AppColors.textPrimary,
                      height: 1.4,
                      fontSize: 13,
                    ),
                  ),
                ),

                // Embedded Rich Card if any
                if (message.richCardType != CompactRichCardType.none)
                  _buildEmbeddedRichCard(message),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmbeddedRichCard(CompactChatMessage message) {
    switch (message.richCardType) {
      case CompactRichCardType.routeSuggestion:
        final data = message.cardData ?? {};
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: MetroCard(
            padding: const EdgeInsets.all(AppSpacing.sm),
            backgroundColor: AppColors.surface,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      data['route'] ?? 'Bến Thành → Suối Tiên',
                      style: AppTypography.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      data['fare'] ?? '15.000 đ',
                      style: AppTypography.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${data['line']} • ${data['time']}',
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F9EE),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    data['departure'] ?? '',
                    style: const TextStyle(
                      color: AppColors.successText,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onSelectRoute?.call(data['route'] ?? '');
                        },
                        icon: const PhosphorIcon(
                          PhosphorIconsRegular.mapPin,
                          size: 14,
                        ),
                        label: const Text('Xem trên Bản đồ', style: TextStyle(fontSize: 11)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const BookingFlowScreen(),
                            ),
                          );
                        },
                        icon: const PhosphorIcon(
                          PhosphorIconsRegular.ticket,
                          size: 14,
                          color: Colors.white,
                        ),
                        label: const Text('Đặt vé ngay', style: TextStyle(fontSize: 11)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );

      case CompactRichCardType.fareComparison:
        final data = message.cardData ?? {};
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: MetroCard(
            padding: const EdgeInsets.all(AppSpacing.sm),
            backgroundColor: AppColors.surface,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title'] ?? 'Vé Tháng 30 Ngày',
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Học sinh: ${data['studentPrice']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.successText,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Chuẩn: ${data['standardPrice']}',
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const BookingFlowScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: const Text('Mua vé tháng ngay', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        );

      case CompactRichCardType.stationGuide:
        final data = message.cardData ?? {};
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: MetroCard(
            padding: const EdgeInsets.all(AppSpacing.sm),
            backgroundColor: AppColors.surface,
            border: Border.all(color: AppColors.borderSubtle),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['name'] ?? '',
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data['gates'] ?? '',
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    data['interchange'] ?? '',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

      case CompactRichCardType.none:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _BouncingDot(delay: 0),
                SizedBox(width: 4),
                _BouncingDot(delay: 150),
                SizedBox(width: 4),
                _BouncingDot(delay: 300),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickReplyChips() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        scrollDirection: Axis.horizontal,
        itemCount: _quickReplies.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final reply = _quickReplies[index];
          return ActionChip(
            label: Text(reply),
            labelStyle: AppTypography.textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            backgroundColor: AppColors.primaryLight,
            side: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.2),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            onPressed: () => _sendMessage(reply),
          );
        },
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        6,
        AppSpacing.md,
        AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Chức năng nhập liệu giọng nói (đang phát triển)'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 1),
                ),
              );
            },
            icon: const PhosphorIcon(
              PhosphorIconsRegular.microphone,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: TextField(
                controller: _textController,
                onSubmitted: _sendMessage,
                textInputAction: TextInputAction.send,
                decoration: const InputDecoration(
                  hintText: 'Hỏi Trợ lý MetroGo...',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => _sendMessage(_textController.text),
              icon: const PhosphorIcon(
                PhosphorIconsFill.paperPlaneRight,
                color: Colors.white,
                size: 17,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BouncingDot extends StatefulWidget {
  final int delay;

  const _BouncingDot({required this.delay});

  @override
  State<_BouncingDot> createState() => _BouncingDotState();
}

class _BouncingDotState extends State<_BouncingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _animation = Tween<double>(begin: 0, end: -4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
