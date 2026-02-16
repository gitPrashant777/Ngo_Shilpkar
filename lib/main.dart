import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/splash_screen.dart';

void main() {
  // Production-grade initialization [cite: 1]
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [

        ChangeNotifierProvider(create: (_) => AuthProvider()),
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

      // App Entry point [cite: 57, 1827]
      home: const SplashScreen(),
    );
  }
}