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

void main() {
  // Production-grade initialization [cite: 1]
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [

        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => JobProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SchemeProvider(),
        ),

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

      home: const MainNavigationScreen(),
      routes: {
        "/home": (context) => const PublicHomeScreen(),
        "/admin-dashboard": (context) => const SuperAdminDashboard(),
      },

    );
  }
}