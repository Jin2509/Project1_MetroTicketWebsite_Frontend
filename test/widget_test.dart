import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_go/main.dart';
import 'package:metro_go/models/live_train_model.dart';
import 'package:metro_go/models/news_model.dart';
import 'package:metro_go/models/ticket_model.dart';
import 'package:metro_go/screens/ai/ai_assistant_screen.dart';
import 'package:metro_go/screens/ai/compact_ai_chat_sheet.dart';
import 'package:metro_go/screens/booking/booking_flow_screen.dart';
import 'package:metro_go/screens/booking/payment_screen.dart';
import 'package:metro_go/screens/booking/payment_success_screen.dart';
import 'package:metro_go/screens/main_shell.dart';
import 'package:metro_go/screens/map/live_map_screen.dart';
import 'package:metro_go/screens/map/search_map_screen.dart';
import 'package:metro_go/screens/news/article_detail_screen.dart';
import 'package:metro_go/screens/news/news_feed_screen.dart';
import 'package:metro_go/screens/notifications/notifications_screen.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:metro_go/screens/profile/profile_screen.dart';
import 'package:metro_go/screens/tickets/my_tickets_screen.dart';
import 'package:metro_go/theme/app_theme.dart';
import 'package:metro_go/widgets/global_floating_ai_button.dart';
import 'package:metro_go/widgets/metro_ticket_card.dart';
import 'package:metro_go/widgets/status_badge.dart';
import 'package:metro_go/widgets/vietnam_map_background.dart';

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

  testWidgets('MainShell Home tab renders Active Ticket card, Check-in/Check-out section, and news', (WidgetTester tester) async {
    TicketStore.instance.resetDefaultsForTesting();

    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: MainShell(),
      ),
    );
    await tester.pump();

    // 1. Active Ticket Card
    expect(find.text('Vé tháng không giới hạn'), findsOneWidget);
    expect(find.text('Vé hiệu lực'), findsOneWidget);
    expect(find.text('Mã QR lên tàu'), findsWidgets);

    // 2. Quick 7 Shortcuts Cluster (In exact requested order)
    expect(find.text('Đặt vé'), findsOneWidget);
    expect(find.text('Kiểm tra vé'), findsOneWidget);
    expect(find.text('Tra cứu map'), findsOneWidget);
    expect(find.text('Tra cứu ga'), findsOneWidget);
    expect(find.text('Tiện ích quanh ga'), findsOneWidget);
    expect(find.text('Chatbot'), findsOneWidget);
    expect(find.text('Check-in'), findsOneWidget);

    // 3. Quick Route Card & News Section (Film app style)
    expect(find.text('Tìm hành trình nhanh'), findsOneWidget);
    expect(find.text('Ga Trung tâm Bến Thành'), findsOneWidget);
    expect(find.text('Tin tức & Sự kiện'), findsOneWidget);
    expect(find.text('Xem tất cả'), findsOneWidget);

    // 4. Test opening Turnstile QR code sheet from button
    await tester.tap(find.text('Mã QR lên tàu').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('VÉ QUÉT CỔNG SOÁT VÉ'), findsOneWidget);
    expect(find.text('Đưa mã QR trước mắt quét tại cổng tự động nhà ga (cách 10cm)'), findsOneWidget);

    // Close QR sheet
    Navigator.of(tester.element(find.text('VÉ QUÉT CỔNG SOÁT VÉ'))).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // 5. Test Check-in vào ga via quick shortcut
    await tester.ensureVisible(find.text('Check-in'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Check-in'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Turnstile QR sheet auto-opens on check-in
    expect(find.text('VÉ QUÉT CỔNG SOÁT VÉ'), findsOneWidget);

    // Close QR sheet
    Navigator.of(tester.element(find.text('VÉ QUÉT CỔNG SOÁT VÉ'))).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // State is now checked-in
    expect(find.text('ĐÃ CHECK-IN'), findsOneWidget);
    expect(find.text('Hành trình đang diễn ra'), findsOneWidget);
    expect(find.text('Check-out ra ga'), findsOneWidget);

    // 6. Test Check-out ra ga
    await tester.ensureVisible(find.text('Check-out ra ga'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Check-out ra ga'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Check-out thành công!'), findsOneWidget);
    expect(find.text('Bạn đã hoàn thành chuyến đi và qua cổng kiểm soát an toàn.'), findsOneWidget);

    // Dismiss completion modal
    await tester.tap(find.text('Hoàn tất'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // State is back to ready to check in
    expect(find.text('Chưa vào ga'), findsOneWidget);
  });

  testWidgets('MainShell Home tab shows notice when no active tickets exist', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    TicketStore.instance.clearActiveTicketsForTesting();

    await tester.pumpWidget(
      const MaterialApp(
        home: MainShell(),
      ),
    );
    await tester.pump();

    // Expect empty / expired ticket notice
    expect(find.text('Chưa có vé để lên tàu'), findsOneWidget);
    expect(find.text('Tất cả vé đã hết hạn hoặc chưa đặt vé'), findsOneWidget);
    expect(find.text('Mua vé ngay'), findsWidgets);

    // Tap QR button when having no ticket
    await tester.tap(find.text('Mã QR lên tàu'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Bạn chưa có vé hiệu lực'), findsOneWidget);

    // Dismiss dialog
    Navigator.of(tester.element(find.text('Bạn chưa có vé hiệu lực'))).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Tap Check-in shortcut without ticket
    await tester.ensureVisible(find.text('Check-in'));
    await tester.tap(find.text('Check-in'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Bạn chưa có vé hiệu lực'), findsOneWidget);

    // Reset store
    TicketStore.instance.resetDefaultsForTesting();
  });

  testWidgets('SearchMapScreen renders search bar, line filters, and station list', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: SearchMapScreen(),
      ),
    );
    await tester.pump();

    // 1. Floating address search bar
    expect(find.text('Tìm địa chỉ, địa điểm xung quanh, tên ga...'), findsOneWidget);

    // 2. Surrounding amenities filter chips
    expect(find.text('Tất cả tiện ích'), findsOneWidget);
    expect(find.text('Bãi giữ xe'), findsOneWidget);
    expect(find.text('Xe buýt kết nối'), findsOneWidget);
    expect(find.text('Ăn uống & Cà phê'), findsOneWidget);
    expect(find.text('ATM & Tiện ích'), findsOneWidget);

    // 3. Line filter and station directory
    expect(find.textContaining('Tuyến 1'), findsWidgets);
    expect(find.text('Danh sách các ga'), findsOneWidget);

    // 4. Test search autocomplete query filtering
    await tester.enterText(find.byType(TextField), 'Landmark 81');
    await tester.pump();

    expect(find.textContaining('Landmark 81'), findsWidgets);
  });

  testWidgets('MyTicketsScreen renders active tickets section followed by new ticket booking section', (WidgetTester tester) async {
    TicketStore.instance.resetDefaultsForTesting();
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: MyTicketsScreen(),
      ),
    );
    await tester.pump();

    // 1. Active tickets section
    expect(find.text('VÉ ĐÃ ĐẶT (CÒN HOẠT ĐỘNG)'), findsOneWidget);
    expect(find.textContaining('vé khả dụng'), findsOneWidget);

    // 2. New ticket booking section
    await tester.scrollUntilVisible(
      find.text('ĐẶT VÉ MỚI'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('ĐẶT VÉ MỚI'), findsOneWidget);
    expect(find.text('Vé lượt (Single Ride)'), findsOneWidget);
    expect(find.text('Vé ngày (Day Pass)'), findsOneWidget);
    expect(find.text('Vé tháng (Monthly Pass)'), findsOneWidget);
    expect(find.text('Đặt vé mới ngay'), findsOneWidget);
  });

  testWidgets('PaymentScreen opens payment QR modal and shows celebration on completion', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final bookingData = {
      'ticketType': TicketType.singleRide,
      'title': 'Vé lượt: Bến Thành → Ba Son',
      'origin': 'Bến Thành',
      'destination': 'Ba Son',
      'validity': 'Hiệu lực 4 giờ',
      'quantity': 1,
      'totalPrice': 15000,
    };

    await tester.pumpWidget(
      MaterialApp(
        home: PaymentScreen(bookingData: bookingData),
        routes: {
          '/payment-success': (context) => const Scaffold(body: Text('Success Page Mock')),
        },
      ),
    );
    await tester.pump();

    // 1. Check order summary
    expect(find.text('THÔNG TIN ĐƠN HÀNG'), findsOneWidget);
    expect(find.text('Vé lượt: Bến Thành → Ba Son'), findsOneWidget);
    expect(find.text('PHƯƠNG THỨC THANH TOÁN'), findsOneWidget);

    // 2. Tap Confirm Payment to open QR Modal
    await tester.tap(find.textContaining('Xác nhận thanh toán'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 3. QR Modal is shown
    expect(find.text('Quét mã QR thanh toán'), findsOneWidget);
    expect(find.textContaining('9823 4812 3840'), findsOneWidget);
    expect(find.text('Tôi đã thanh toán thành công'), findsOneWidget);

    // 4. Tap "Tôi đã thanh toán thành công"
    await tester.tap(find.text('Tôi đã thanh toán thành công'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // 5. Celebration dialog is shown
    expect(find.text('Thanh toán thành công!'), findsOneWidget);
    expect(find.textContaining('Đang phát hành mã QR vé cho bạn...'), findsOneWidget);

    // Finish celebration delay
    await tester.pump(const Duration(seconds: 3));
  });

  test('Proton Dark Theme colors and tokens are correctly defined', () {
    expect(AppColors.primary, const Color(0xFF6D4AFF));
    expect(AppColors.background, const Color(0xFF13111C));
    expect(AppColors.surface, const Color(0xFF1E1A2B));
    expect(AppColors.surfaceSecondary, const Color(0xFF272238));
    expect(AppColors.textPrimary, const Color(0xFFFFFFFF));
    expect(AppColors.textSecondary, const Color(0xFFCECAE3));
    expect(AppColors.primaryText, const Color(0xFFB59DFF));
    expect(AppColors.success, const Color(0xFF00D492));
    expect(AppTheme.darkTheme.brightness, Brightness.dark);
  });

  testWidgets('VietnamMapBackground renders child and custom paint canvas', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: VietnamMapBackground(
            opacity: 0.09,
            child: Text('Map Content'),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Map Content'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
    expect(find.byType(VietnamMapBackground), findsOneWidget);
  });

  testWidgets('MainShell renders GlobalFloatingAiButton across all screens', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MainShell(),
      ),
    );
    await tester.pump();

    expect(find.byType(GlobalFloatingAiButton), findsOneWidget);
    expect(find.byType(VietnamMapBackground), findsWidgets);
  });

  testWidgets('SearchMapScreen renders fullscreen map and station bottom sheet', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: SearchMapScreen(),
      ),
    );
    await tester.pump();

    // Verify fullscreen map is rendered
    expect(find.byType(FlutterMap), findsOneWidget);
    expect(find.text('Tìm địa chỉ, địa điểm xung quanh, tên ga...'), findsOneWidget);
    expect(find.text('Danh sách các ga'), findsOneWidget);

    // Open station directory modal
    await tester.tap(find.text('Danh sách các ga'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('Danh sách các ga Metro'), findsOneWidget);
    expect(find.text('Ga Bến Thành'), findsWidgets);
  });

  testWidgets('ProfileScreen renders minimalist essential settings only', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileScreen(),
      ),
    );
    await tester.pump();

    // 1. Header & User info
    expect(find.text('Cài đặt'), findsOneWidget);
    expect(find.text('Alex Nguyễn'), findsOneWidget);
    expect(find.text('+84 987 654 321'), findsOneWidget);
    expect(find.text('XÁC THỰC'), findsOneWidget);

    // 2. Essential System settings
    expect(find.text('HỆ THỐNG'), findsOneWidget);
    expect(find.text('Thông báo chuyến tàu'), findsOneWidget);
    expect(find.text('Ngôn ngữ (Language)'), findsOneWidget);
    expect(find.text('Chế độ giao diện'), findsOneWidget);

    // 3. Essential Support & Rules
    expect(find.text('HỖ TRỢ & QUY ĐỊNH'), findsOneWidget);
    expect(find.text('Hỗ trợ & Hotline 24/7'), findsOneWidget);
    expect(find.text('Điều khoản & An toàn Metro'), findsOneWidget);
    expect(find.text('Đăng xuất'), findsOneWidget);

    // 4. Verify bloatware is removed (No fake monthly pass card, no MoMo wallet list)
    expect(find.text('Thẻ tháng đang hoạt động'), findsNothing);
    expect(find.textContaining('Ví MoMo'), findsNothing);
  });

  test('ParkingBooking model calculates formattedPrice correctly', () {
    const booking = ParkingBooking(
      station: 'Bến Thành',
      ownerName: 'Nguyễn Văn A',
      licensePlate: '59-P1 123.45',
      packageType: '1 buổi (5.000đ)',
      vehicleType: 'Xe máy',
      price: 5000,
    );

    expect(booking.formattedPrice, '5.000 đ');
    expect(booking.ownerName, 'Nguyễn Văn A');
    expect(booking.licensePlate, '59-P1 123.45');
    expect(booking.station, 'Bến Thành');
  });

  testWidgets('BookingFlowScreen toggles parking reservation and calculates fees', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: BookingFlowScreen(),
      ),
    );
    await tester.pump();

    // Verify parking section toggle is displayed
    expect(find.text('ĐẶT CHỖ GIỮ XE TẠI GA'), findsOneWidget);
    expect(find.textContaining('Bảo đảm có chỗ đỗ xe tại nhà ga'), findsOneWidget);

    // Initially inputs are hidden
    expect(find.text('Họ tên chủ xe'), findsNothing);

    // Toggle parking switch on
    final switchFinder = find.byType(Switch);
    expect(switchFinder, findsOneWidget);
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    // Verify fields are now visible
    expect(find.text('Họ tên chủ xe'), findsOneWidget);
    expect(find.text('Biển số xe'), findsOneWidget);
    expect(find.text('Loại phương tiện'), findsOneWidget);
    expect(find.text('Xe máy'), findsOneWidget);
    expect(find.text('Ô tô'), findsOneWidget);
    expect(find.text('Gói thời gian giữ xe'), findsOneWidget);
    expect(find.text('1 buổi'), findsOneWidget);
    expect(find.text('1 ngày'), findsOneWidget);
    expect(find.text('Qua đêm'), findsOneWidget);
    expect(find.text('Số tiền giữ xe (1 buổi)'), findsOneWidget);
    expect(find.text('5.000 đ'), findsWidgets);

    // Select '1 ngày' package
    await tester.tap(find.text('1 ngày'));
    await tester.pumpAndSettle();
    expect(find.text('Số tiền giữ xe (1 ngày)'), findsOneWidget);
    expect(find.text('10.000 đ'), findsWidgets);
  });

  testWidgets('PaymentScreen displays parking reservation itemization in order summary', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final bookingData = {
      'ticketType': TicketType.singleRide,
      'title': 'Vé lượt: Ga Bến Thành → Ga Ba Son',
      'origin': 'Ga Bến Thành',
      'destination': 'Ga Ba Son',
      'validity': 'Hiệu lực 4 giờ kể từ khi vào ga',
      'unitPrice': 15000,
      'quantity': 1,
      'ticketTotal': 15000,
      'totalPrice': 20000,
      'hasParking': true,
      'parkingStation': 'Bến Thành',
      'parkingOwner': 'Alex Nguyễn',
      'parkingPlate': '59-A1 999.99',
      'parkingVehicle': 'Xe máy',
      'parkingPackage': '1 buổi',
      'parkingFee': 5000,
    };

    await tester.pumpWidget(
      MaterialApp(
        home: PaymentScreen(bookingData: bookingData),
      ),
    );
    await tester.pump();

    expect(find.text('THÔNG TIN ĐƠN HÀNG'), findsOneWidget);
    expect(find.text('Tiền vé Metro'), findsOneWidget);
    expect(find.text('15.000 đ'), findsWidgets);
    expect(find.text('Giữ xe (Xe máy - 1 buổi)'), findsOneWidget);
    expect(find.text('5.000 đ'), findsWidgets);
    expect(find.textContaining('BS: 59-A1 999.99'), findsOneWidget);
    expect(find.text('20.000 đ'), findsWidgets);
  });

  testWidgets('PaymentSuccessScreen displays dedicated parking confirmation card', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    const parkingBooking = ParkingBooking(
      station: 'Bến Thành',
      ownerName: 'Nguyễn Văn Minh',
      licensePlate: '51-F2 888.88',
      packageType: '1 ngày',
      vehicleType: 'Xe máy',
      price: 10000,
    );

    final ticketWithParking = Ticket(
      id: 'MG-TEST-PARKING-01',
      title: 'Vé lượt: Ga Bến Thành → Ga Suối Tiên',
      type: TicketType.singleRide,
      originStation: 'Ga Bến Thành',
      destinationStation: 'Ga Suối Tiên',
      validityText: 'Hiệu lực 4 giờ',
      status: TicketStatus.paid,
      priceVnd: 30000,
      purchaseDate: DateTime.now(),
      qrCodeData: 'METROGO:TICKET:TEST',
      parking: parkingBooking,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: PaymentSuccessScreen(ticket: ticketWithParking),
      ),
    );
    await tester.pump();

    expect(find.text('Thanh toán thành công!'), findsOneWidget);
    expect(find.text('CHỖ GIỮ XE ĐÃ XÁC NHẬN'), findsOneWidget);
    expect(find.text('Đã giữ chỗ'), findsOneWidget);
    expect(find.text('Ga Bến Thành'), findsWidgets);
    expect(find.text('51-F2 888.88'), findsOneWidget);
    expect(find.text('Nguyễn Văn Minh'), findsOneWidget);
    expect(find.text('10.000 đ'), findsOneWidget);
  });

  testWidgets('MetroTicketCard displays parking badge when parking is reserved', (WidgetTester tester) async {
    const parkingBooking = ParkingBooking(
      station: 'Bến Thành',
      ownerName: 'Nguyễn Văn A',
      licensePlate: '59-B1 777.77',
      packageType: '1 buổi',
      vehicleType: 'Xe máy',
      price: 5000,
    );

    final ticket = Ticket(
      id: 'MG-CARD-PARK-01',
      title: 'Vé lượt',
      type: TicketType.singleRide,
      validityText: 'Hiệu lực 4 giờ',
      status: TicketStatus.paid,
      priceVnd: 20000,
      purchaseDate: DateTime.now(),
      qrCodeData: 'METROGO:TEST',
      parking: parkingBooking,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MetroTicketCard(ticket: ticket),
        ),
      ),
    );
    await tester.pump();

    expect(find.textContaining('Giữ xe: Ga Bến Thành (59-B1 777.77)'), findsOneWidget);
  });
}



