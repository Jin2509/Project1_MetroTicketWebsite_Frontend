import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/news_model.dart';
import 'models/ticket_model.dart';
import 'models/transit_models.dart';
import 'screens/ai/ai_assistant_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/booking/booking_flow_screen.dart';
import 'screens/booking/payment_screen.dart';
import 'screens/booking/payment_success_screen.dart';
import 'screens/main_shell.dart';
import 'screens/map/live_map_screen.dart';
import 'screens/news/article_detail_screen.dart';
import 'screens/news/news_feed_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/search/fare_table_screen.dart';
import 'screens/search/route_detail_screen.dart';
import 'screens/search/schedule_lookup_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/tickets/my_tickets_screen.dart';
import 'screens/tickets/ticket_detail_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MetroGoApp());
}

class MetroGoApp extends StatelessWidget {
  const MetroGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MetroGo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/main': (context) => const MainShell(initialTab: 0),
        '/search': (context) => const SearchScreen(),
        '/my-tickets': (context) => const MyTicketsScreen(),
        '/profile': (context) => const MainShell(initialTab: 4),
        '/edit-profile': (context) => const EditProfileScreen(),
        '/booking': (context) => const BookingFlowScreen(),
        '/schedule-lookup': (context) => const ScheduleLookupScreen(),
        '/fare-table': (context) => const FareTableScreen(),
        '/route-detail': (context) => RouteDetailScreen(line: TransitData.lines[0]),
        '/live-map': (context) => const LiveMapScreen(showBackButton: true),
        '/ai-assistant': (context) => const AiAssistantScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/news': (context) => const NewsFeedScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/article-detail') {
          final article =
              settings.arguments as NewsArticle? ?? NewsData.articles.first;
          return MaterialPageRoute(
            builder: (context) => ArticleDetailScreen(article: article),
          );
        }
        if (settings.name == '/otp') {
          final target = settings.arguments as String?;
          return MaterialPageRoute(
            builder: (context) => OtpScreen(contactTarget: target),
          );
        }
        if (settings.name == '/payment') {
          final bookingData = settings.arguments as Map<String, dynamic>? ?? {
            'ticketType': TicketType.singleRide,
            'title': 'Single Ride: Bến Thành → Suối Tiên',
            'validity': 'Valid for 4 hours',
            'quantity': 1,
            'totalPrice': 15000,
          };
          return MaterialPageRoute(
            builder: (context) => PaymentScreen(bookingData: bookingData),
          );
        }
        if (settings.name == '/payment-success') {
          final ticket = settings.arguments as Ticket? ??
              TicketStore.instance.activeTickets.first;
          return MaterialPageRoute(
            builder: (context) => PaymentSuccessScreen(ticket: ticket),
          );
        }
        if (settings.name == '/ticket-detail') {
          final ticket = settings.arguments as Ticket? ??
              TicketStore.instance.activeTickets.first;
          return MaterialPageRoute(
            builder: (context) => TicketDetailScreen(ticket: ticket),
          );
        }
        if (settings.name == '/main') {
          final initialTab = settings.arguments as int? ?? 0;
          return MaterialPageRoute(
            builder: (context) => MainShell(initialTab: initialTab),
          );
        }
        return null;
      },
    );
  }
}
