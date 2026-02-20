import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shilpkar/core/navigation/main_navigation.dart';
import 'package:shilpkar/features/admin/presentation/screens/superAdmin_dashboard.dart';
import 'core/constants/app_colors.dart';
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
import 'features/chat/presentation/providers/chat_provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  // Production-grade initialization [cite: 1]
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => JobProvider()),
        ChangeNotifierProvider(create: (_) => SchemeProvider()),
        ChangeNotifierProvider(create: (_) => HomepageProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shilpkar Foundation',
      navigatorKey: navigatorKey,
      // Setting Global Theme based on Figma styles [cite: 1, 30]
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
        // Matching rounded button style from Figma
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      builder: (context, child) => _BroadcastListenerWrapper(child: child!),
      home: const MainNavigationScreen(),
      routes: {
        "/home": (context) => const PublicHomeScreen(),
        "/admin-dashboard": (context) => const SuperAdminDashboard(),
      },
    );
  }
}

class _BroadcastListenerWrapper extends StatefulWidget {
  final Widget child;
  const _BroadcastListenerWrapper({required this.child});

  @override
  State<_BroadcastListenerWrapper> createState() => _BroadcastListenerWrapperState();
}

class _BroadcastListenerWrapperState extends State<_BroadcastListenerWrapper> {
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
            backgroundColor: Colors.orange,
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