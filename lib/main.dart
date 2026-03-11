import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:shilpkar/core/navigation/main_navigation.dart';
import 'package:shilpkar/features/admin/presentation/screens/superAdmin_dashboard.dart';
import 'package:shilpkar/features/jobs/presentation/screens/user_job_list_screen.dart';
import 'core/constants/app_colors.dart';
import 'core/providers/language_provider.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/public_home_screen.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/jobs/presentation/providers/job_provider.dart';
import 'features/schemes/presentation/providers/scheme_provider.dart';
import 'features/home/presentation/providers/homepage_provider.dart';
import 'features/ecommerce/presentation/providers/category_provider.dart';
import 'features/ecommerce/presentation/providers/product_provider.dart';
import 'features/ecommerce/presentation/providers/order_provider.dart';
import 'features/ecommerce/presentation/providers/review_provider.dart';
import 'features/ecommerce/presentation/providers/customer_auth_provider.dart';
import 'features/chat/presentation/providers/chat_provider.dart';
import 'features/chat/presentation/providers/broadcast_provider.dart';
import 'features/onboarding/presentation/providers/onboarding_provider.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'features/status/presentation/providers/status_provider.dart';
import 'features/notifications/presentation/providers/notification_provider.dart';
import 'features/attendance/presentation/providers/attendance_provider.dart';
import 'features/notifications/presentation/providers/notification_provider.dart';
import 'features/attendance/presentation/providers/attendance_provider.dart';
import 'features/attendance/presentation/screens/attendance_list_screen.dart';
import 'features/dashboard/presentation/screens/my_applications_screen.dart';
import 'features/ecommerce/presentation/screens/public/my_orders_screen.dart';
import 'features/notifications/presentation/screens/notification_screen.dart';
import 'features/dashboard/presentation/providers/dashboard_provider.dart';
import 'core/utils/device_manager.dart';
import 'l10n/app_localizations.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Initialize Firebase
  await Firebase.initializeApp();

  // Register background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize persistent device UUID for anonymous status view tracking
  await DeviceManager.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => JobProvider()),
        ChangeNotifierProvider(create: (_) => SchemeProvider()),
        ChangeNotifierProvider(create: (_) => HomepageProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => CustomerAuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => BroadcastProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => StatusProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _printFCMToken();
  }

  Future<void> _printFCMToken() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      // Request permission (important for Android 13+ & iOS)
      await messaging.requestPermission();

      String? token = await messaging.getToken();

      print("🔥 ================================");
      print("🔥 FCM TOKEN:");
      print(token);
      print("🔥 ================================");

      // Listen for token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        print("🔄 ================================");
        print("🔄 FCM TOKEN REFRESHED:");
        print(newToken);
        print("🔄 ================================");

        if (navigatorKey.currentContext != null) {
          final authProvider = navigatorKey.currentContext!.read<AuthProvider>();
          final customerAuthProvider = navigatorKey.currentContext!.read<CustomerAuthProvider>();
          
          if (authProvider.isAuthenticated || customerAuthProvider.isAuthenticated) {
            navigatorKey.currentContext!.read<NotificationProvider>().registerFcmToken(newToken);
          }
        }
      });

      // Handle App Open via Notification
      _setupPushNotificationRouting();
    } catch (e) {
      print("❌ Error getting FCM token: $e");
    }
  }

  void _setupPushNotificationRouting() async {
    // 1. Terminated state tap
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handlePushTap(initialMessage);
    }

    // 2. Background state tap
    FirebaseMessaging.onMessageOpenedApp.listen(_handlePushTap);

    // 3. Foreground state receive
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (navigatorKey.currentContext != null) {
        navigatorKey.currentContext!.read<NotificationProvider>().fetchUnreadCount();
      }
    });
  }

  void _handlePushTap(RemoteMessage message) {
    if (message.data.containsKey('type')) {
      final type = message.data['type'];
      print("🚀 Routing push notification tap to type: $type");
      
      if (navigatorKey.currentState != null) {
        final context = navigatorKey.currentState!.context;
        
        switch (type) {
          case 'ATTENDANCE_MARKED':
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceListScreen()));
            break;
          case 'JOB_APPLIED':
            Navigator.push(context, MaterialPageRoute(builder: (_) => const UserJobListScreen()));
            break;
          case 'SCHEME_APPROVED':
            Navigator.push(context, MaterialPageRoute(builder: (_) => const MyApplicationsScreen()));
            break;
          case 'ORDER_DELIVERED':
          case 'ORDER_CONFIRMED':
            Navigator.push(context, MaterialPageRoute(builder: (_) => const MyOrdersScreen()));
            break;
          case 'BROADCAST':
            Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
            break;
          default:
            Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
        }
      }
    } else {
       // Fallback directly to Notifications if no type specified
       if (navigatorKey.currentState != null) {
          Navigator.push(navigatorKey.currentState!.context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
       }
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shilpkar Foundation',
      navigatorKey: navigatorKey,

      // ── Localization ───────────────────────────────────────────────────────
      locale: languageProvider.locale,
      supportedLocales: const [
        Locale('en'),
        Locale('mr'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.appBarBlue,
        scaffoldBackgroundColor: AppColors.backgroundGrey,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.appBarBlue,
          primary: AppColors.appBarBlue,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.appBarBlue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      builder: (context, child) =>
          _BroadcastListenerWrapper(child: child!),
      home: const SplashScreen(),
      routes: {
        "/home": (context) => const PublicHomeScreen(),
        "/admin-dashboard": (context) => const SuperAdminDashboard(),
        "/login": (context) => PublicHomeScreen(),
        "/onboarding": (context) => const OnboardingScreen(),
      },
    );
  }
}

class _BroadcastListenerWrapper extends StatefulWidget {
  final Widget child;
  const _BroadcastListenerWrapper({required this.child});

  @override
  State<_BroadcastListenerWrapper> createState() =>
      _BroadcastListenerWrapperState();
}

class _BroadcastListenerWrapperState
    extends State<_BroadcastListenerWrapper> {
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = context.read<ChatProvider>();
      _subscription = chatProvider.broadcastStream.listen((message) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "📢 System Broadcast: $message",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: AppColors.broadcastOrange,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}