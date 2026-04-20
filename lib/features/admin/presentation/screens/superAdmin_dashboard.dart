import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shilpkar/features/admin/presentation/screens/select_employee_role_screen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/main_navigation.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../ecommerce/presentation/screens/public/product_list_screen.dart';
import '../../../jobs/presentation/screens/admin_job_management_screen.dart';
import '../../../schemes/presentation/screens/Superadmin_scheme_management_screen.dart';
import 'MakeAdminScreen.dart';
import 'employee_list_admin_screen.dart';
import '../../../home/presentation/screens/homepage_management_screen.dart';
import '../../../home/presentation/providers/homepage_provider.dart';
import '../../../ecommerce/presentation/screens/admin/admin_product_management_screen.dart';
import '../../../ecommerce/presentation/screens/admin/admin_category_management_screen.dart';
import '../../../ecommerce/presentation/screens/admin/admin_order_management_screen.dart';
import '../../../ecommerce/presentation/screens/admin/admin_refund_management_screen.dart';
import '../../../chat/presentation/screens/chat_list_screen.dart' as shilpkar;
import '../../../chat/presentation/screens/admin_broadcast_screen.dart';
import 'create_beneficiary_screen.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../onboarding/presentation/screens/onboarding_admin_screen.dart';
import '../../../status/presentation/screens/status_management_screen.dart';
import '../../../status/presentation/screens/status_viewer_screen.dart';
import '../../../status/presentation/providers/status_provider.dart';
import 'package:shilpkar/features/notifications/presentation/widgets/notification_bell.dart';
import '../../../schemes/presentation/screens/global_payments_screen.dart';
import '../../../attendance/presentation/screens/attendance_list_screen.dart';
import '../../../../features/dashboard/presentation/screens/foundation_dashboard_screen.dart';
import '../../../../features/dashboard/presentation/screens/transaction_screen.dart';
import '../../../../features/dashboard/presentation/screens/about_us_screen.dart';
import '../../../../features/dashboard/presentation/screens/manual_payment_screen.dart';
import '../../../../features/dashboard/presentation/screens/parcel_screen.dart';
import '../../../../features/employee/presentation/screens/employee_payment_screens.dart';
import 'beneficiary_pending_payments_screen.dart';
import 'cash_settlement_screen.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../../../../shared/widgets/homepage_cover_media.dart';
import '../../../../shared/widgets/dashboard_section.dart';
import '../../../../shared/widgets/dashboard_info_box.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomepageProvider>().fetchHomepage();
      context.read<StatusProvider>().fetchStatuses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final chatProvider = context.watch<ChatProvider>();
    final showChatDot = chatProvider.unreadCount > 0 ||
        chatProvider.requests.any((r) => r.status == 'PENDING');

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // ─── Our Vision / Our Work ──────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6, left: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 18,
                          decoration: BoxDecoration(
                            color: AppColors.appBarBlue,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          l10n.ourVisionWork,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const StatusManagementScreen(),
                            ),
                          ),
                          child: Text(
                            l10n.manage,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF1E5799),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  StatusRingRow(),
                  const SizedBox(height: 8),

                  // ─── User Management ──────────────────────────────────────
                  _buildActionSection(
                    context,
                    l10n.userManagement,
                    Icons.people_alt_outlined,
                    AppColors.appBarBlue,
                    [
                      _ActionData(
                        l10n.makeOthersAdmin,
                        "Assign admin privileges to other users",
                        Icons.admin_panel_settings_outlined,
                        AppColors.appBarBlue,
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MakeAdminScreen())),
                      ),
                      _ActionData(
                        'Create Coordinator',
                        "Register and approve new coordinators",
                        Icons.badge_outlined,
                        AppColors.createEmployeeBtnGreen,
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SelectEmployeeRoleScreen())),
                      ),
                      _ActionData(
                        l10n.makeBeneficiary,
                        "Onboard new community beneficiaries",
                        Icons.person_add_outlined,
                        const Color(0xFFE67E22),
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateBeneficiaryScreen())),
                      ),
                      _ActionData(
                        'View Community',
                        "Search and manage all registered members",
                        Icons.people_outline,
                        const Color(0xFF2980B9),
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmployeeListAdminScreen())),
                      ),
                    ],
                  ),

                  // ─── Communication ───────────────────────────────────────────
                  _buildActionSection(
                    context,
                    l10n.communication,
                    Icons.forum_outlined,
                    AppColors.communicationPurple,
                    [
                      _ActionData(
                        'Live Chat',
                        "Communicate directly with community members",
                        Icons.chat_bubble_outline,
                        AppColors.communicationPurple,
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const shilpkar.ChatListScreen())),
                        showDot: showChatDot,
                      ),
                      _ActionData(
                        l10n.systemBroadcasts,
                        "Send announcements and news to all users",
                        Icons.campaign_outlined,
                        const Color(0xFFD35400),
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminBroadcastScreen())),
                      ),
                    ],
                  ),

                  // ─── Operations & Finance ──────────────────────────────────
                  _buildActionSection(
                    context,
                    l10n.paymentsLogistics,
                    Icons.local_shipping_outlined,
                    const Color(0xFFF39C12),
                    [
                      _ActionData(
                        l10n.onboardingConfig,
                        "Configure app onboarding steps and content",
                        Icons.settings_suggest_outlined,
                        AppColors.secondaryGreen,
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OnboardingAdminScreen())),
                      ),
                      _ActionData(
                        l10n.paymentHistory,
                        "View all processed payments and logs",
                        Icons.history_outlined,
                        const Color(0xFF27AE60),
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GlobalPaymentsScreen())),
                      ),
                      _ActionData(
                        l10n.createParcel,
                        "Book and manage logistics parcel shipments",
                        Icons.inventory_2_outlined,
                        const Color(0xFF2C3E50),
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ParcelScreen())),
                      ),
                    ],
                  ),

                  // ─── Payments & Logistics ──────────────────────────────────
                  

                  // ─── Programs & Attendance ─────────────────────────────────
                  _buildActionSection(
                    context,
                    l10n.programsAttendance,
                    Icons.assignment_turned_in_outlined,
                    AppColors.lightBlueScheme,
                    [
                      _ActionData(
                        l10n.manageSchemes,
                        "Oversee government and NGO welfare schemes",
                        Icons.assignment_outlined,
                        AppColors.lightBlueScheme,
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SuperAdminSchemeManagementScreen())),
                      ),
                      _ActionData(
                        l10n.jobRequests,
                        "Review and manage pending job applications",
                        Icons.work_history_outlined,
                        const Color(0xFF16A085),
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminJobManagementScreen())),
                      ),
                      _ActionData(
                        l10n.attendanceRecords,
                        "Monitor staff and coordinator daily attendance",
                        Icons.fingerprint_rounded,
                        const Color(0xFF2980B9),
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceListScreen())),
                      ),
                    ],
                  ),

                  // ─── E-Commerce Management ─────────────────────────────────
                  _buildActionSection(
                    context,
                    l10n.ecommerceManagement,
                    Icons.storefront_outlined,
                    AppColors.sectionEcommerceRed,
                    [
                      _ActionData(
                        l10n.products,
                        "Manage storefront inventory and pricing",
                        Icons.category_outlined,
                        AppColors.sectionEcommerceRed,
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminProductManagementScreen())),
                      ),
                      _ActionData(
                        l10n.exploreProducts,
                        "View the product catalog as a customer",
                        Icons.shopping_bag_outlined,
                        const Color(0xFF27AE60),
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductListScreen())),
                      ),
                    ],
                  ),

                  // ─── Analytics & More ──────────────────────────────────────
                  _buildActionSection(
                    context,
                    l10n.analyticsAndMore,
                    Icons.analytics_outlined,
                    const Color(0xFF34495E),
                    [
                      _ActionData(
                        l10n.foundationDashboard,
                        "High-level metrics and impact analytics",
                        Icons.dashboard_customize_outlined,
                        const Color(0xFF34495E),
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FoundationDashboardScreen())),
                      ),
                      _ActionData(
                        l10n.aboutFoundation,
                        "Manage foundation info and contact details",
                        Icons.info_outline,
                        const Color(0xFF1E5799),
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutUsScreen())),
                      ),
                      _ActionData(
                        'Manage Homepage',
                        "Customize banners and dashboard settings",
                        Icons.home_work_outlined,
                        const Color(0xFF7A9E6F),
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HomepageManagementScreen())),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActionSection(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    List<_ActionData> items,
  ) {
    return DashboardSection(
      title: title,
      icon: icon,
      color: color,
      child: Column(
        children: items.map((item) {
          return InkWell(
            onTap: item.onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              decoration: BoxDecoration(
                border: Border(
                  bottom: items.last == item 
                      ? BorderSide.none 
                      : BorderSide(color: Colors.grey.shade100, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Icon(item.icon, size: 18, color: item.color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  if (item.showDot)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: CircleAvatar(radius: 3, backgroundColor: Colors.red),
                    ),
                  Icon(Icons.arrow_forward_ios_rounded, 
                      size: 12, color: Colors.grey.shade400),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
      backgroundColor: const Color(0xFF55789A),
      elevation: 0,
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          Image.asset('assets/Images/home.jpeg', height: 40),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              l10n.shilpkarSuperAdmin,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        Consumer<LanguageProvider>(
          builder: (context, langProvider, _) => langProvider.buildToggleWidget(),
        ),
        const NotificationBell(iconColor: Colors.white),
        const SizedBox(width: 2),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () async {
            try {
              debugPrint("SuperAdminDashboard: Calling logout...");
              await context.read<AuthProvider>().logout();
            } catch (e) {
              debugPrint("SuperAdminDashboard: Logout error: $e");
            }

            if (context.mounted) {
              debugPrint("SuperAdminDashboard: Navigating to MainNavigationScreen...");
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const MainNavigationScreen(initialIndex: 1),
                ),
                (route) => false,
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Consumer<HomepageProvider>(
      builder: (context, provider, _) {
        if (!provider.welcomeVisible) {
          return const SizedBox.shrink();
        }
        String? bannerUrl;
        String? bannerVideo;
        if (provider.homepage != null) {
          if (provider.homepage!.coverImages.isNotEmpty) {
            bannerUrl = provider.homepage!.coverImages.first.url;
          }
          if (provider.homepage!.coverVideos.isNotEmpty) {
            bannerVideo = provider.homepage!.coverVideos.first.url;
          }
        }

        return Stack(
          children: [
            Stack(
              children: [
                HomepageCoverMedia(
                  fallbackAsset: 'assets/Images/Frame2.png',
                  imageUrl: bannerUrl,
                  videoUrl: bannerVideo,
                  height: 180,
                ),
                Positioned.fill(
                  child: Container(color: Colors.black45),
                ),
                Positioned.fill(
                  child: Center(
                    child: Consumer<LanguageProvider>(
                      builder: (context, _, __) {
                        final l10n = AppLocalizations.of(context)!;
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.welcomeShilpkar,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              l10n.empoweringCommunities,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const HomepageManagementScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: AppColors.appBarBlue,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ActionData {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool showDot;

  _ActionData(
    this.label,
    this.subtitle,
    this.icon,
    this.color,
    this.onTap, {
    this.showDot = false,
  });
}
