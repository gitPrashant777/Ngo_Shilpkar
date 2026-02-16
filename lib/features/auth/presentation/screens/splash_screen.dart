import 'package:flutter/material.dart';
import 'package:shilpkar/features/auth/presentation/screens/public_home_screen.dart';
import '../../../../core/utils/storage_service.dart';
import 'role_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final StorageService _storage = StorageService();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() async {
    // Artificial delay for splash effect
    await Future.delayed(const Duration(seconds: 3));
    final token = await _storage.getToken();

    if (!mounted) return;

    if (token != null) {
      // TODO: Navigate to Home/Dashboard once implemented
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PublicHomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Matches the logo placement in Android Compact - 57.png
            Image.asset(
              'assets/Images/logoSk.png',
              width: 250,
              height: 250,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 60),
            const Text(
              "Shilpkar Foundation ",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}