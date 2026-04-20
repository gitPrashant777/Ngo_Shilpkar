import 'dart:async';


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shilpkar/core/navigation/main_navigation.dart';
import '../../../../core/utils/storage_service.dart';
import '../../../ecommerce/presentation/providers/customer_auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final StorageService _storage = StorageService();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    // Animation setup: 1-second fade in
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _animController.forward();
    _navigateToNext();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _navigateToNext() async {
    // Artificial delay for branding visibility
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // Check auth status via provider
    await context.read<CustomerAuthProvider>().checkAuthStatus();
    await _storage.getToken();

    if (!mounted) return;

    // Move to Main Navigation (which usually handles role-based routing)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Center( // Ensures everything is dead-center
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Foundation Logo ──────────────────────────────────────────
                Image.asset(
                  'assets/Images/home.jpeg',
                  width: 280,
                  height: 280,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 12),

                // ── Registration Badge ───────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8730A), // Foundation Orange
                    borderRadius: BorderRadius.circular(12), // Smoother corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    'F-0028565 (LTR)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Optional: Loading indicator to show the app is working
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE8730A)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
