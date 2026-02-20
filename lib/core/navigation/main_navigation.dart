import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shilpkar/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:shilpkar/features/onboarding/presentation/screens/onboarding_screen.dart';

import 'package:shilpkar/features/auth/presentation/providers/auth_provider.dart';
import 'package:shilpkar/features/auth/presentation/screens/public_home_screen.dart';
import 'package:shilpkar/features/jobs/presentation/screens/job_list_screen.dart';
import 'package:shilpkar/features/schemes/presentation/screens/scheme_list_screen.dart';
import 'package:shilpkar/features/admin/presentation/screens/superAdmin_dashboard.dart';
import 'package:shilpkar/features/admin/presentation/screens/admin_dashboard.dart';
import 'package:shilpkar/features/auth/presentation/screens/profile_screen.dart';
import 'package:shilpkar/features/jobs/presentation/screens/admin_job_management_screen.dart';
import 'package:shilpkar/features/schemes/presentation/screens/Superadmin_scheme_management_screen.dart';

import '../../features/beneficiary/presentation/screens/my_application_screen.dart';
import '../../features/dashboard/presentation/screens/beneficiary_dashboard.dart';
import '../../features/employee/presentation/screens/employee_dashboard.dart';
import '../../features/jobs/presentation/screens/user_job_list_screen.dart';
import '../../features/schemes/presentation/screens/user_scheme_list_screen.dart';
import '../../features/attendance/presentation/screens/attendance_screen.dart';
import '../../features/chat/presentation/screens/chat_list_screen.dart' as shilpkar;

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  // Defaulting to 1, which is the "Home" tab for all roles.
  const MainNavigationScreen({super.key, this.initialIndex = 1});

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _selectedIndex;
  bool _onboardingChecked = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().role;
    final onboarding = context.watch<OnboardingProvider>();

    // Global Guard for Beneficiaries
    if (role == "BENEFICIARY") {
      final status = onboarding.status?.status;

      // Trigger check only once per session
      if (status == null && !onboarding.isLoading && !_onboardingChecked) {
        _onboardingChecked = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) context.read<OnboardingProvider>().checkStatus();
        });
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      // Still loading
      if (status == null && onboarding.isLoading) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      // Block access if not paid
      if (status == 'PENDING' || status == 'WAIVER_PENDING') {
        return const OnboardingScreen();
      }
      
      // Reset flag if status changes to allow re-check after login
      if (status == 'PAID' || status == 'WAIVER_APPROVED') {
        // Pass through to normal app
      }
    }

    // Define pages based on role - Swapped Home and Jobs
    List<Widget> pages = [];
    if (role == "SUPER_ADMIN") {
      pages = [
        const AdminJobManagementScreen(), // Index 0: Jobs
        const SuperAdminDashboard(), // Index 1: Home
        const SuperAdminSchemeManagementScreen(),
        const ProfileScreen(),
      ];
    } else if (role == "ADMIN") {
      pages = [
        const AdminJobManagementScreen(), // Index 0: Jobs
        const AdminDashboard(),      // Index 1: Home
        const SuperAdminSchemeManagementScreen(),
        const ProfileScreen(),
      ];
    } else if (role == "BENEFICIARY") {
      pages = [
        const JobListScreen(),        // Index 0: Jobs
        const BeneficiaryDashboard(), // Index 1: Home
        const UserSchemeListScreen(),
        const ProfileScreen(),
      ];
    } else if (role == "FIELD" || role == "COORDINATOR" || role == "EMPLOYEE") {
      pages = [
        const shilpkar.ChatListScreen(), // Index 0: Chat
        const EmployeeDashboard(),       // Index 1: Dashboard
        const AttendanceScreen(),
        const ProfileScreen(),
      ];
    } else {
      // Default / Guest
      pages = [
        const JobListScreen(),     // Index 0: Jobs
        const PublicHomeScreen(),  // Index 1: Home
        const SchemeListScreen(),
        const ProfileScreen(),
      ];
    }

    // Safety check for index
    if (_selectedIndex >= pages.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      extendBody: false,
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: _buildBottomNav(role),
    );
  }

  Widget _buildBottomNav(String? role) {
    return Container(
      height: 100,
      color: const Color(0xFF55789A),
      child: SafeArea(
        top: false,
        child: Row(
          children: _getNavItems(role),
        ),
      ),
    );
  }

  List<Widget> _getNavItems(String? role) {
    if (role == "BENEFICIARY") {
      return [
        _buildNavItem(0, Icons.work, "Jobs"),        // Swapped
        _buildNavItem(1, Icons.home, "Home"),        // Swapped
        _buildNavItem(2, Icons.assignment, "Schemes"),
        _buildNavItem(3, Icons.person, "Profile"),
      ];
    } else if (role == "FIELD" || role == "COORDINATOR" || role == "EMPLOYEE") {
      return [
        _buildNavItem(0, Icons.chat, "Chat"),        // Swapped
        _buildNavItem(1, Icons.dashboard, "Dashboard"), // Swapped
        _buildNavItem(2, Icons.history, "History"),
        _buildNavItem(3, Icons.person, "Profile"),
      ];
    } else {
      // Admin / Super Admin
      return [
        _buildNavItem(0, Icons.work_outline_rounded, "Jobs"), // Swapped
        _buildNavItem(1, Icons.home_rounded, "Home"),        // Swapped
        _buildNavItem(2, Icons.assignment_outlined, "Schemes"),
        _buildNavItem(3, Icons.person_outline_rounded, "Profile"),
      ];
    }
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isSelected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 60,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              // Floating Animated Icon
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                bottom: isSelected ? 26 : 12,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: isSelected
                      ? BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  )
                      : const BoxDecoration(),
                  child: Icon(
                    icon,
                    color: isSelected ? const Color(0xFF4373AD) : Colors.white,
                    size: isSelected ? 28 : 24,
                  ),
                ),
              ),

              // Label (only for unselected)
              if (!isSelected)
                Positioned(
                  bottom: 2,
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}