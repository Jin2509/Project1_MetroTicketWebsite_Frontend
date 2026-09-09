import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_go/main.dart';
import 'package:metro_go/models/live_train_model.dart';
import 'package:metro_go/models/news_model.dart';
import 'package:metro_go/models/ticket_model.dart';
import 'package:metro_go/screens/ai/ai_assistant_screen.dart';
import 'package:metro_go/screens/ai/compact_ai_chat_sheet.dart';
import 'package:metro_go/screens/main_shell.dart';
import 'package:metro_go/screens/map/live_map_screen.dart';
import 'package:metro_go/screens/news/article_detail_screen.dart';
import 'package:metro_go/screens/news/news_feed_screen.dart';
import 'package:metro_go/screens/notifications/notifications_screen.dart';
import 'package:metro_go/widgets/metro_ticket_card.dart';
import 'package:metro_go/widgets/status_badge.dart';

void main() {
  testWidgets('MetroGo smoke test - renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MetroGoApp());
    await tester.pump();

    // Verify brand text is displayed on Splash
    expect(find.byType(RichText), findsWidgets);
    expect(find.text('Di chuyển đô thị thông minh'), findsOneWidget);

    // Advance past splash delayed navigation timer
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('StatusBadge displays correct labels', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: StatusBadge(status: TicketStatus.paid),
      ),
    );
    expect(find.text('Đã thanh toán'), findsOneWidget);
  });

  testWidgets('MetroTicketCard renders ticket stub with title and route', (WidgetTester tester) async {
    final sampleTicket = TicketStore.instance.activeTickets.first;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MetroTicketCard(ticket: sampleTicket),
        ),
      ),
    );

    expect(find.text('Vé điện tử MetroGo'), findsOneWidget);
    expect(find.text('MÃ VÉ'), findsOneWidget);
    expect(find.text(sampleTicket.id), findsOneWidget);
  });

  test('LiveTrainService initializes and returns line trains', () {
    final service = LiveTrainService();
    final l1Trains = service.getTrainsForLine('line_1');
    final l2Trains = service.getTrainsForLine('line_2');

    expect(l1Trains.length, greaterThanOrEqualTo(4));
    expect(l2Trains.length, greaterThanOrEqualTo(2));
    expect(l1Trains.first.code, contains('Tàu #'));
    service.dispose();
  });

  testWidgets('NotificationsScreen renders categories, filter chips and list', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: NotificationsScreen(),
      ),
    );
    await tester.pump();

    expect(find.text('Thông báo'), findsOneWidget);
    expect(find.text('Tất cả'), findsOneWidget);
    expect(find.text('Thông báo trễ tuyến Line 1'), findsOneWidget);
    expect(find.text('Vé tháng sắp hết hạn'), findsOneWidget);
    expect(find.text('HÔM NAY'), findsOneWidget);
  });

  testWidgets('NewsFeedScreen renders featured article and categories', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: NewsFeedScreen(),
      ),
    );
    await tester.pump();

    expect(find.text('Tin tức & Thông báo'), findsOneWidget);
    expect(find.text('Tất cả'), findsOneWidget);
    expect(find.text('NỔI BẬT'), findsOneWidget);
    expect(find.text('Tin mới nhất'), findsOneWidget);
    expect(find.text('Cập nhật tuyến'), findsWidgets);
  });

  testWidgets('ArticleDetailScreen renders article content and commuter tips', (WidgetTester tester) async {
    final article = NewsData.articles.first;
    await tester.pumpWidget(
      MaterialApp(
        home: ArticleDetailScreen(article: article),
      ),
    );
    await tester.pump();

    expect(find.text(article.title), findsOneWidget);
    expect(find.text('ĐIỂM TIN NỔI BẬT'), findsOneWidget);
    expect(find.text('Mẹo hữu ích cho hành khách'), findsOneWidget);
    expect(find.text('Chia sẻ bài viết này'), findsOneWidget);
  });

  testWidgets('AiAssistantScreen renders header, quick replies, and input field', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AiAssistantScreen(),
      ),
    );
    await tester.pump();

    expect(find.text('MetroGo Assistant'), findsOneWidget);
    expect(find.textContaining('Trực tuyến'), findsOneWidget);
    expect(find.text('Ga nào gần tôi nhất?'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('LiveMapScreen renders segmented toggle, tracking glance, and floating AI button', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LiveMapScreen(),
      ),
    );
    await tester.pump();

    // Segmented toggle pills
    expect(find.text('Bản đồ thật'), findsOneWidget);
    expect(find.text('Lịch trình'), findsOneWidget);

    // Floating glance info panel
    expect(find.text('ĐANG THEO DÕI · TUYẾN 1'), findsOneWidget);
    expect(find.text('Tàu đến: Ga Ba Son'), findsOneWidget);
    expect(find.text('Đúng giờ'), findsWidgets);
    expect(find.text('Ga 3/14'), findsOneWidget);

    // Floating AI button unread badge
    expect(find.text('1'), findsOneWidget);

    // Toggle to "Lịch trình" view
    await tester.tap(find.text('Lịch trình'));
    await tester.pump();

    expect(find.text('Tuyến 1: Bến Thành – Suối Tiên'), findsOneWidget);
    expect(find.text('Đến sau 2p'), findsOneWidget);
  });

  testWidgets('CompactAiChatSheet renders header, messages, and quick replies', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CompactAiChatSheet(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('MetroGo Assistant'), findsOneWidget);
    expect(find.text('Trực tuyến • Hỗ trợ AI'), findsOneWidget);
    expect(find.text('Ga nào gần tôi nhất?'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('MainShell Home tab renders Payment QR card, action buttons, and news', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MainShell(),
      ),
    );
    await tester.pump();

    // 1. VietQR Payment Card
    expect(find.text('Thanh toán bằng QR'), findsOneWidget);
    expect(find.text('Chuyển khoản VietQR / Napas247'), findsOneWidget);
    expect(find.text('VietQR 24/7'), findsOneWidget);
    expect(find.text('Phóng to mã QR'), findsOneWidget);

    // 2. Action Buttons Row
    expect(find.text('Mua vé'), findsOneWidget);
    expect(find.text('Quét vé đi tàu'), findsOneWidget);

    // 3. Quick Route Card
    expect(find.text('Tìm hành trình nhanh'), findsOneWidget);
    expect(find.text('Ga Trung tâm Bến Thành'), findsOneWidget);
    expect(find.text('Công viên Suối Tiên'), findsOneWidget);

    // 4. News Section
    expect(find.text('Tin tức & Cập nhật'), findsOneWidget);
    expect(find.text('Xem tất cả'), findsOneWidget);

    // 5. Test opening VietQR enlargement modal
    await tester.tap(find.text('Phóng to mã QR'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Mã QR Thanh toán VietQR'), findsOneWidget);
    expect(find.text('1900 8888 68'), findsOneWidget);
    expect(find.text('Vietcombank - CN TP. Hồ Chí Minh'), findsOneWidget);

    // Close modal via Navigator pop
    Navigator.of(tester.element(find.text('Mã QR Thanh toán VietQR'))).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 6. Test opening Turnstile ticket sheet
    await tester.tap(find.text('Quét vé đi tàu'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('VÉ QUÉT CỔNG SOÁT VÉ'), findsOneWidget);
    expect(find.text('Đưa mã QR trước mắt quét tại cổng tự động nhà ga (cách 10cm)'), findsOneWidget);
  });
}

