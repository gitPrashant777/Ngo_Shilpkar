import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shilpkar/features/admin/presentation/screens/select_employee_role_screen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/main_navigation.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/utils/storage_service.dart';

import '../../../../shared/widgets/dashboard_section.dart';
import '../../../../shared/widgets/dashboard_info_box.dart';
import '../../../ecommerce/presentation/screens/public/product_list_screen.dart';
import '../../../jobs/presentation/screens/admin_job_management_screen.dart';
import '../../../schemes/presentation/screens/Superadmin_scheme_management_screen.dart';
import 'MakeAdminScreen.dart';
import 'SuperMakeEmployeeScreen.dart';
import 'beneficiary_list_screen.dart';
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
import '../../../status/presentation/screens/status_viewer_screen.dart';
import '../../../status/presentation/screens/status_management_screen.dart';
import '../../../status/presentation/providers/status_provider.dart';
import 'package:shilpkar/features/notifications/presentation/widgets/notification_bell.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

                    // ─── User Management ──────────────────────────────────────
                    DashboardSection(
                      title: l10n.userManagement ?? "User Management",
                      icon: Icons.people_alt_outlined,
                      color: const Color(0xFF55789A),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: DashboardInfoBox(
                                  title: l10n.makeOthersAdmin,
                                  subtitle: l10n.makeOthersAdminSub,
                                  buttonLabel: l10n.makeAdmin,
                                  icon: Icons.admin_panel_settings,
                                  iconColor: const Color(0xFF5176A2),
                                  buttonColor: const Color(0xFF5176A2),
                                  bgColor: const Color(0xFFEFF1F5),
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MakeAdminScreen())),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: DashboardInfoBox(
                                  title: l10n.makeEmployee,
                                  subtitle: l10n.makeEmployeeSub,
                                  buttonLabel: l10n.makeEmployee,
                                  icon: Icons.person_add,
                                  iconColor: const Color(0xFF71A46F),
                                  buttonColor: const Color(0xFF71A46F),
                                  bgColor: const Color(0xFFEFF1F5),
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SelectEmployeeRoleScreen())),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: DashboardInfoBox(
                                  title: l10n.makeBeneficiary,
                                  subtitle: l10n.makeBeneficiarySub,
                                  buttonLabel: l10n.create,
                                  icon: Icons.group_add,
                                  iconColor: const Color(0xFF3475D7),
                                  buttonColor: const Color(0xFF3475D7),
                                  bgColor: const Color(0xFFEFF1F5),
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateBeneficiaryScreen())),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Expanded(child: SizedBox()),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ─── Operations & Finance ─────────────────────────────────
                    DashboardSection(
                      title: l10n.operationsFinance ?? "Operations & Finance",
                      icon: Icons.account_balance_wallet_outlined,
                      color: const Color(0xFFD9A05B),
                      child: Column(
                        children: [
                          _buildFullWidthAction(
                            l10n.onboardingConfig,
                            l10n.onboardingConfigSub,
                            Icons.settings_applications_outlined,
                            const Color(0xFFD69E50),
                                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OnboardingAdminScreen())),
                          ),
                          const SizedBox(height: 12),
                          _buildFullWidthAction(
                            l10n.paymentHistory,
                            l10n.paymentHistorySub,
                            Icons.history,
                            const Color(0xFFA1C6A1),
                                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GlobalPaymentsScreen())),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ─── Programs & Attendance ────────────────────────────────
                    DashboardSection(
                      title: l10n.programsAttendance ?? "Programs & Attendance",
                      icon: Icons.assignment_turned_in_outlined,
                      color: const Color(0xFF4A78B0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: DashboardInfoBox(
                                  title: l10n.manageSchemes,
                                  subtitle: l10n.manageSchemeSub,
                                  buttonLabel: 'View Details',
                                  icon: Icons.assignment_outlined,
                                  bgColor: const Color(0xFFE3F2FD),
                                  iconColor: const Color(0xFF1976D2),
                                  buttonColor: const Color(0xFF1976D2),
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SuperAdminSchemeManagementScreen())),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DashboardInfoBox(
                                  title: l10n.jobRequests,
                                  subtitle: l10n.jobRequestsSub,
                                  buttonLabel: 'View Details',
                                  icon: Icons.work_history_outlined,
                                  bgColor: const Color(0xFFFFF3E0),
                                  iconColor: const Color(0xFFF57C00),
                                  buttonColor: const Color(0xFFF57C00),
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminJobManagementScreen())),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: DashboardInfoBox(
                                  title: l10n.attendanceRecords,
                                  subtitle: l10n.attendanceSub,
                                  buttonLabel: 'View Details',
                                  icon: Icons.fingerprint_rounded,
                                  bgColor: const Color(0xFFF3E5F5),
                                  iconColor: const Color(0xFF7B1FA2),
                                  buttonColor: const Color(0xFF7B1FA2),
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceListScreen())),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(child: SizedBox()), // Empty space to maintain uniformity
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ─── E-Commerce ───────────────────────────────────────────
                    DashboardSection(
                      title: l10n.ecommerceManagement,
                      icon: Icons.storefront_outlined,
                      color: const Color(0xFFE57373),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: DashboardInfoBox(
                                  title: l10n.products,
                                  subtitle: l10n.manageInventory,
                                  buttonLabel: 'View Details',
                                  icon: Icons.inventory_2_outlined,
                                  bgColor: const Color(0xFFFFEBEE),
                                  iconColor: const Color(0xFFE53935),
                                  buttonColor: const Color(0xFFE53935),
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminProductManagementScreen())),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DashboardInfoBox(
                                  title: l10n.categories,
                                  subtitle: l10n.manageCategories,
                                  buttonLabel: 'View Details',
                                  icon: Icons.category_outlined,
                                  bgColor: const Color(0xFFF3E5F5),
                                  iconColor: const Color(0xFF8E24AA),
                                  buttonColor: const Color(0xFF8E24AA),
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCategoryManagementScreen())),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: DashboardInfoBox(
                                  title: l10n.exploreProducts,
                                  subtitle: l10n.exploreProductsSub,
                                  buttonLabel: 'View Details',
                                  icon: Icons.shopping_bag_outlined,
                                  bgColor: const Color(0xFFE8F5E9),
                                  iconColor: const Color(0xFF4CAF50),
                                  buttonColor: const Color(0xFF4CAF50),
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductListScreen())),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DashboardInfoBox(
                                  title: l10n.manageOrders,
                                  subtitle: l10n.manageOrdersSub,
                                  buttonLabel: 'View Details',
                                  icon: Icons.local_shipping_outlined,
                                  bgColor: const Color(0xFFFFF8E1),
                                  iconColor: const Color(0xFFFFA000),
                                  buttonColor: const Color(0xFFFFA000),
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminOrderManagementScreen())),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: DashboardInfoBox(
                                  title: l10n.refundRequests,
                                  subtitle: l10n.refundRequestsSub,
                                  buttonLabel: 'View Details',
                                  icon: Icons.assignment_return_outlined,
                                  bgColor: const Color(0xFFE0F7FA),
                                  iconColor: const Color(0xFF00BCD4),
                                  buttonColor: const Color(0xFF00BCD4),
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminRefundManagementScreen())),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(child: SizedBox()), // Empty space to maintain uniformity
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ─── Communication & Quick Access ─────────────────────────
                    DashboardSection(
                      title: l10n.communication ?? "Communication",
                      icon: Icons.forum_outlined,
                      color: const Color(0xFF5C6BC0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: DashboardInfoBox(
                                  title: l10n.chatRequests,
                                  subtitle: l10n.chatRequestsSub,
                                  buttonLabel: 'View Details',
                                  icon: Icons.chat_bubble_outline,
                                  bgColor: const Color(0xFFE8EAF6),
                                  iconColor: const Color(0xFF5C6BC0),
                                  buttonColor: const Color(0xFF5C6BC0),
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const shilpkar.ChatListScreen())),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DashboardInfoBox(
                                  title: l10n.systemBroadcasts,
                                  subtitle: l10n.systemBroadcastsSub,
                                  buttonLabel: 'View Details',
                                  icon: Icons.campaign_outlined,
                                  bgColor: const Color(0xFFFFF3E0),
                                  iconColor: const Color(0xFFFF9800),
                                  buttonColor: const Color(0xFFFF9800),
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminBroadcastScreen())),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // ─── Info Boxes Row ──────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: DashboardInfoBox(
                            icon: Icons.diversity_3_rounded,
                            iconColor: AppColors.primaryBlue,
                            title: l10n.joinUsSocialMission,
                            subtitle: l10n.bePartOfChange,
                            buttonLabel: l10n.joinNow,
                            buttonColor: AppColors.primaryBlue,
                            bgColor: AppColors.joinUsBg,
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DashboardInfoBox(
                            icon: Icons.volunteer_activism_rounded,
                            iconColor: AppColors.accentRed,
                            title: l10n.purposeDrivenProducts,
                            subtitle: l10n.everyProductCreatesImpact,
                            buttonLabel: l10n.exploreProducts,
                            buttonColor: AppColors.secondaryGreen,
                            bgColor: AppColors.productsBg,
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const ProductListScreen()));
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                )
            )
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
                        ? CachedNetworkImage(
                      imageUrl: bannerUrl,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) {
                        return Image.asset(
                          'assets/Images/Frame2.png',
                          fit: BoxFit.cover,
                        );
                      },
                      placeholder: (context, url) {
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

  // Kept this one untouched as it's meant to span the full width (unlike the 2-column grids)
  Widget _buildFullWidthAction(String title, String sub, IconData icon,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4, offset: const Offset(0,2)
              )
            ]
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black87, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text(sub, style: const TextStyle(
                      fontSize: 12, color: Colors.black87)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}