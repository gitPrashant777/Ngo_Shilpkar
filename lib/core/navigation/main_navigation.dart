import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shilpkar/l10n/app_localizations.dart';
import 'package:shilpkar/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:shilpkar/features/onboarding/presentation/screens/onboarding_screen.dart';

import 'package:shilpkar/features/auth/presentation/providers/auth_provider.dart';
import 'package:shilpkar/features/auth/presentation/screens/public_home_screen.dart';
import 'package:shilpkar/features/jobs/presentation/screens/job_list_screen.dart';
import 'package:shilpkar/features/schemes/presentation/screens/scheme_list_screen.dart';
import 'package:shilpkar/features/schemes/presentation/screens/public_scheme_login_gate.dart';
import 'package:shilpkar/features/schemes/presentation/screens/Superadmin_scheme_management_screen.dart';
import 'package:shilpkar/features/admin/presentation/screens/superAdmin_dashboard.dart';
import 'package:shilpkar/features/admin/presentation/screens/admin_dashboard.dart';
import 'package:shilpkar/features/auth/presentation/screens/profile_screen.dart';
import 'package:shilpkar/features/jobs/presentation/screens/admin_job_management_screen.dart';

import '../../features/beneficiary/presentation/screens/my_application_screen.dart';
import '../../features/dashboard/presentation/screens/beneficiary_dashboard.dart';
import '../../features/employee/presentation/screens/employee_dashboard.dart';
import '../../features/jobs/presentation/screens/user_job_list_screen.dart';
import '../../features/schemes/presentation/screens/user_scheme_list_screen.dart';
import '../../features/attendance/presentation/screens/attendance_screen.dart';
import '../../features/chat/presentation/screens/chat_list_screen.dart' as shilpkar;

// Simple helper class to hold navigation data
class NavItem {
  final IconData icon;
  final String label;

  NavItem({required this.icon, required this.label});
}

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  // Defaulting to 1, which is the "Home" tab for all roles.
  const MainNavigationScreen({super.key, this.initialIndex = 1});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
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

    // Define pages based on role
    List<Widget> pages = [];
    if (role == "SUPER_ADMIN") {
      pages = [
        const AdminJobManagementScreen(),
        const SuperAdminDashboard(),
        const SuperAdminSchemeManagementScreen(),
        const ProfileScreen(),
      ];
    } else if (role == "ADMIN") {
      pages = [
        const AdminJobManagementScreen(),
        const AdminDashboard(),
        const SuperAdminSchemeManagementScreen(),
        const ProfileScreen(),
      ];
    } else if (role == "BENEFICIARY") {
      pages = [
        const JobListScreen(),
        const BeneficiaryDashboard(),
        const SchemeListScreen(),
        const ProfileScreen(),
      ];
    } else if (role == "FIELD" || role == "COORDINATOR" || role == "EMPLOYEE") {
      pages = [
        const shilpkar.ChatListScreen(),
        const EmployeeDashboard(),
        const AttendanceScreen(),
        const ProfileScreen(),
      ];
    } else {
      // Default / Guest
      pages = [
        const JobListScreen(),
        const PublicHomeScreen(),
        const PublicSchemeLoginGate(),
        const ProfileScreen(),
      ];
    }

    // Safety check for index
    if (_selectedIndex >= pages.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      extendBody: true,
      // Remove the manual Padding — extendBody:true + correct nav bar height
      // means MediaQuery.padding.bottom inside child screens == barHeight + systemInset,
      // which is exactly what SafeArea needs. No manual padding required.
      body: SafeArea(
        top: false,
        bottom: true,
        child: IndexedStack(
          index: _selectedIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: _buildBottomNav(role),
    );
  }

  List<NavItem> _getNavItemsData(String? role) {
    final l10n = AppLocalizations.of(context)!;
    if (role == "BENEFICIARY") {
      return [
        NavItem(icon: Icons.work, label: l10n.navJobs),
        NavItem(icon: Icons.home, label: l10n.navHome),
        NavItem(icon: Icons.assignment, label: l10n.navSchemes),
        NavItem(icon: Icons.person, label: l10n.navProfile),
      ];
    } else if (role == "FIELD" || role == "COORDINATOR" || role == "EMPLOYEE") {
      return [
        NavItem(icon: Icons.chat, label: l10n.navChat),
        NavItem(icon: Icons.dashboard, label: l10n.navDashboard),
        NavItem(icon: Icons.history, label: l10n.navAttendance),
        NavItem(icon: Icons.person, label: l10n.navProfile),
      ];
    } else {
      // Admin / Super Admin and Guest
      return [
        NavItem(icon: Icons.work_outline_rounded, label: l10n.navJobs),
        NavItem(icon: Icons.home_rounded, label: l10n.navHome),
        NavItem(icon: Icons.assignment_outlined, label: l10n.navSchemes),
        NavItem(icon: Icons.person_outline_rounded, label: l10n.navProfile),
      ];
    }
  }

  Widget _buildBottomNav(String? role) {
    final items = _getNavItemsData(role);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    const double barHeight = 65.0;
    // floatingHeight is only visual overflow — the Container only reports barHeight
    // so MediaQuery.padding.bottom in child screens = barHeight + systemInset (correct!)
    const double floatingHeight = 55.0;

    // Report only the solid bar height to Flutter's layout system.
    // The floating icon will overflow upward via Clip.none — it's purely visual.
    return SizedBox(
      height: barHeight + bottomPadding,
      child: Stack(
        clipBehavior: Clip.none, // allow floating icon to overflow above the bar
        alignment: Alignment.bottomCenter,
        children: [
          // 1. Solid Blue Background (fills the full SizedBox)
          Positioned.fill(
            child: Container(
              color: const Color(0xFF55789A),
            ),
          ),

          // 2. Interaction & Animation Layer — extends upward by floatingHeight
          //    via negative bottom so it overflows above the bar visually
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: barHeight + floatingHeight + bottomPadding,
            child: Row(
              children: List.generate(items.length, (index) {
                final isSelected = _selectedIndex == index;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      height: barHeight + floatingHeight + bottomPadding,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        clipBehavior: Clip.none,
                        children: [
                          // UNSELECTED STATE
                          Positioned(
                            bottom: bottomPadding + 12,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: isSelected ? 0.0 : 1.0,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    items[index].icon,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    items[index].label,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // SELECTED STATE (Bouncing Icon)
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutBack,
                            bottom: isSelected
                                ? bottomPadding + 40
                                : bottomPadding,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: isSelected ? 1.0 : 0.0,
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(4),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF55789A),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    items[index].icon,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}