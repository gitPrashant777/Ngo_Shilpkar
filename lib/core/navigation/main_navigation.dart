import 'package:flutter/material.dart';
import 'package:shilpkar/features/auth/presentation/screens/public_home_screen.dart';
import 'package:shilpkar/features/jobs/presentation/screens/job_list_screen.dart';
import 'package:shilpkar/features/schemes/presentation/screens/scheme_list_screen.dart';
import 'package:shilpkar/features/admin/presentation/screens/superAdmin_dashboard.dart';
import 'package:shilpkar/core/utils/storage_service.dart';
import 'package:shilpkar/core/constants/app_colors.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState
    extends State<MainNavigationScreen> {

  int _selectedIndex = 1;
  String? _role;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final storage = StorageService();
    final role = await storage.getRole();

    if (!mounted) return;

    setState(() {
      _role = role;
    });
  }

  List<Widget> get _pages {
    return [
      const JobListScreen(),

      // 👇 Home changes depending on role
      _role == "ADMIN" || _role == "SUPER_ADMIN"
          ? const SuperAdminDashboard()
          : const PublicHomeScreen(),

      const SchemeListScreen(),

      const SizedBox(), // Profile later
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.appBarBlue,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.work_outline),
              label: "Jobs"),
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              label: "Schemes"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: "Profile"),
        ],
      ),
    );
  }
}
