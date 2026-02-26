import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shilpkar/features/admin/presentation/screens/select_employee_role_screen.dart';
import 'package:shilpkar/features/auth/presentation/screens/public_home_screen.dart';
import 'package:shilpkar/features/jobs/presentation/screens/job_list_screen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/main_navigation.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/utils/storage_service.dart';
import '../../../../shared/widgets/action_card.dart';
import '../../../ecommerce/presentation/screens/public/product_list_screen.dart';
import '../../../jobs/presentation/screens/admin_job_management_screen.dart';
import '../../../schemes/presentation/screens/Superadmin_scheme_management_screen.dart';
import 'MakeAdminScreen.dart';
import 'SuperMakeEmployeeScreen.dart';
import 'beneficiary_list_screen.dart';
import '../../../home/presentation/screens/homepage_management_screen.dart';
import '../../../home/presentation/providers/homepage_provider.dart';
import '../../../ecommerce/presentation/screens/admin/admin_product_management_screen.dart';
import '../../../ecommerce/presentation/screens/admin/admin_product_management_screen.dart';
import '../../../ecommerce/presentation/screens/admin/admin_category_management_screen.dart';
import '../../../ecommerce/presentation/screens/admin/admin_order_management_screen.dart';
import '../../../ecommerce/presentation/screens/admin/admin_refund_management_screen.dart';
import '../../../chat/presentation/screens/chat_list_screen.dart' as shilpkar;
import '../../../chat/presentation/screens/admin_broadcast_screen.dart';
import 'create_beneficiary_screen.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../onboarding/presentation/screens/onboarding_admin_screen.dart';
import '../../../status/presentation/screens/status_viewer_screen.dart';
import '../../../status/presentation/screens/status_management_screen.dart';
import '../../../status/presentation/providers/status_provider.dart';
import 'package:shilpkar/features/notifications/presentation/widgets/notification_bell.dart';
import '../../../schemes/presentation/screens/global_payments_screen.dart';
import '../../../attendance/presentation/screens/attendance_list_screen.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {

  @override
  void initState() {
    super.initState();
    // Fetch homepage data for the banner
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomepageProvider>().fetchHomepage();
      context.read<StatusProvider>().fetchStatuses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  // ─── Our Vision / Our Work / Our Impact ──────
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Container(width: 4, height: 18, decoration: BoxDecoration(color: const Color(0xFF1E5799), borderRadius: BorderRadius.circular(2))),
                        const SizedBox(width: 10),
                        Text(l10n.ourVisionWork,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatusManagementScreen())),
                          child: Text(l10n.manage, style: const TextStyle(fontSize: 12, color: Color(0xFF1E5799), fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                  const StatusRingRow(),
                  const SizedBox(height: 10),
                  // Row for User Management
                  // lib/features/admin/presentation/screens/admin_dashboard.dart

                  Row(
                    children: [
                      Expanded(
                        child: _buildAdminFeatureBox(
                          l10n.makeOthersAdmin,
                          l10n.makeOthersAdminSub,
                          l10n.makeAdmin,
                          Icons.admin_panel_settings,
                          const Color(0xFF638FB4),
                              () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const MakeAdminScreen()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildAdminFeatureBox(
                          l10n.makeEmployee,
                          l10n.makeEmployeeSub,
                          l10n.makeEmployee,
                          Icons.person_add,
                          const Color(0xFF7A9E6F),
                              () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SelectEmployeeRoleScreen(),
                              ),
                            );
                          },
                        ),

                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildAdminFeatureBox(
                          l10n.makeBeneficiary,
                          l10n.makeBeneficiarySub,
                          l10n.create,
                          Icons.group_add,
                          const Color(0xFFE57373),
                              () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CreateBeneficiaryScreen()),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Payment Fixture Bar
                  _buildFullWidthAction(
                    l10n.paymentFixture,
                    l10n.paymentFixtureSub,
                    Icons.currency_rupee,
                    const Color(0xFFD9A05B),
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OnboardingAdminScreen())),
                  ),
                  const SizedBox(height: 16),

                  // Management Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildAdminFeatureBox(
                          l10n.exploreProducts,
                          l10n.exploreProductsSub,
                          l10n.explore,
                          Icons.shopping_bag_outlined,
                          const Color(0xFF4CAF50),
                              () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProductListScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildAdminFeatureBox(
                          l10n.jobRequests,
                          l10n.jobRequestsSub,
                          l10n.see,
                          Icons.work_history,
                          const Color(0xFF638FB4),
                              () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AdminJobManagementScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Payment History Bar
                  _buildFullWidthAction(
                    l10n.paymentHistory,
                    l10n.paymentHistorySub,
                    Icons.history,
                    const Color(0xFFB4C8B4),
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const GlobalPaymentsScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Attendance Bar
                  _buildFullWidthAction(
                    l10n.attendanceRecords,
                    l10n.attendanceSub,
                    Icons.fingerprint_rounded,
                    const Color(0xFFE0F2F1),
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceListScreen())),
                  ),
                  const SizedBox(height: 16),

                  // Schemes Management
                  _buildFullWidthAction(
                    l10n.manageSchemes,
                    l10n.manageSchemeSub,
                    Icons.assignment,
                    const Color(0xFF4A78B0),
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SuperAdminSchemeManagementScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // E-COMMERCE MANAGEMENT HEADER
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
                      child: Text(
                        l10n.ecommerceManagement,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey),
                      ),
                    ),
                  ),

                  // E-COMMERCE ROW
                  Row(
                    children: [
                      Expanded(
                        child: _buildAdminFeatureBox(
                          l10n.products,
                          l10n.manageInventory,
                          l10n.manage,
                          Icons.inventory_2_outlined,
                          const Color(0xFFE57373),
                              () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AdminProductManagementScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildAdminFeatureBox(
                          l10n.categories,
                          l10n.manageCategories,
                          l10n.manage,
                          Icons.category_outlined,
                          const Color(0xFFBA68C8),
                              () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AdminCategoryManagementScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- Quick Access Grid (2x2, light pastel cards) ---
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
                      child: Text(
                        l10n.quickAccess,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey),
                      ),
                    ),
                  ),
                  Row(
                    children: [

                      Expanded(
                        child: _buildLightCardAction(
                          l10n.chatRequests,
                          l10n.chatRequestsSub,
                          Icons.chat_bubble_outline,
                          const Color(0xFFE8EAF6),
                          const Color(0xFF5C6BC0),
                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const shilpkar.ChatListScreen())),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildLightCardAction(
                          l10n.systemBroadcasts,
                          l10n.systemBroadcastsSub,
                          Icons.campaign_outlined,
                          const Color(0xFFFFF3E0),
                          const Color(0xFFFF9800),
                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminBroadcastScreen())),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildLightCardAction(
                          l10n.onboardingConfig,
                          l10n.onboardingConfigSub,
                          Icons.account_balance_wallet_outlined,
                          const Color(0xFFE0F2F1),
                          const Color(0xFF009688),
                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OnboardingAdminScreen())),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildLightCardAction(
                          l10n.manageOrders,
                          l10n.manageOrdersSub,
                          Icons.local_shipping_outlined,
                          const Color(0xFFF3E5F5),
                          const Color(0xFF9C27B0),
                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminOrderManagementScreen())),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildLightCardAction(
                          l10n.refundRequests,
                          l10n.refundRequestsSub,
                          Icons.assignment_return_outlined,
                          const Color(0xFFFFEBEE),
                          const Color(0xFFE53935),
                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminRefundManagementScreen())),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
        ]
              ),
            ),
          ],
        ),
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
          Image.asset('assets/Images/logoSk.png', height: 40),
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
              // Call provider logout to clear state
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

  // ... (build methods)

  // ... (build methods)

  Widget _buildHeroSection() {
    return Consumer<HomepageProvider>(
      builder: (context, provider, _) {
         String? bannerUrl;
         if (provider.homepage != null && provider.homepage!.coverImages.isNotEmpty) {
           bannerUrl = provider.homepage!.coverImages.first.url;
         }

        return Stack(
          children: [
            Container(
              height: 180,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background Image
                  bannerUrl != null
                      ? Image.network(
                          bannerUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/Images/Frame2.png',
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Image.asset(
                          'assets/Images/Frame2.png',
                          fit: BoxFit.cover,
                        ),
                  // Dark Overlay
                  Container(
                    color: Colors.black45,
                  ),
                  // Text Content
                  Center(
                    child: Consumer<LanguageProvider>(
                      builder: (context, _, __) {
                        final l10n = AppLocalizations.of(context)!;
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(l10n.welcomeShilpkar,
                                style: const TextStyle(color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            Text(l10n.empoweringCommunities,
                                style: const TextStyle(color: Colors.white, fontSize: 12)),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Edit Button Overlay
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
      }
    );
  }

  Widget _buildAdminFeatureBox(String title, String sub, String btn,
      IconData icon, Color color, VoidCallback onTap) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 14)),
          Text(sub, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                  backgroundColor: color, elevation: 0),
              child: Text(btn,
                  style: const TextStyle(fontSize: 10, color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLightCardAction(String title, String sub, IconData icon,
      Color bgColor, Color iconColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 10),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: iconColor)),
            const SizedBox(height: 2),
            Text(sub, style: const TextStyle(fontSize: 11, color: Colors.black45)),
          ],
        ),
      ),
    );
  }

  Widget _buildFullWidthAction(String title, String sub, IconData icon,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, color: Colors.black54, size: 32),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
                Text(sub, style: const TextStyle(
                    fontSize: 12, color: Colors.black45)),
              ],
            )
          ],
        ),
      ),
    );
  }

}
