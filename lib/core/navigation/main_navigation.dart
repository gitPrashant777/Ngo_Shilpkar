import 'package:flutter/material.dart';
import 'package:shilpkar/features/auth/presentation/screens/public_home_screen.dart';
import 'package:shilpkar/features/jobs/presentation/screens/job_list_screen.dart';
import 'package:shilpkar/features/schemes/presentation/screens/scheme_list_screen.dart';
import 'package:shilpkar/features/admin/presentation/screens/superAdmin_dashboard.dart';
import 'package:shilpkar/features/admin/presentation/screens/admin_dashboard.dart';
import 'package:shilpkar/features/auth/presentation/screens/profile_screen.dart';
import 'package:provider/provider.dart'; // import provider
import 'package:shilpkar/features/auth/presentation/providers/auth_provider.dart';
import 'package:shilpkar/core/constants/app_colors.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  const MainNavigationScreen({super.key, this.initialIndex = 1});

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState
    extends State<MainNavigationScreen> {

  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  // Helper to get role from Provider
  String? get _role => context.watch<AuthProvider>().role; 


  List<Widget> get _pages {
    return [
      const JobListScreen(),

      // 👇 Home changes depending on role
      if (_role == "SUPER_ADMIN") 
        const SuperAdminDashboard()
      else if (_role == "ADMIN")
         const AdminDashboard() 
      else 
        const PublicHomeScreen(),

      const SchemeListScreen(),

      const ProfileScreen(),
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
