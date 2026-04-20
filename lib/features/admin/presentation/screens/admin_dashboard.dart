import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/navigation/main_navigation.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart' show AuthProvider;
import '../../../chat/presentation/screens/chat_list_screen.dart' as chat;
import '../../../chat/presentation/screens/admin_broadcast_screen.dart';
import '../../../jobs/presentation/screens/admin_job_management_screen.dart';
import '../../../schemes/presentation/screens/Superadmin_scheme_management_screen.dart';
import 'select_employee_role_screen.dart';
import 'employee_list_admin_screen.dart';
import '../../../../features/ecommerce/presentation/screens/admin/admin_category_management_screen.dart';
import '../../../../features/ecommerce/presentation/screens/admin/admin_product_management_screen.dart';
import '../../../../features/ecommerce/presentation/screens/admin/admin_order_management_screen.dart';
import '../../../../features/ecommerce/presentation/screens/admin/admin_refund_management_screen.dart';
import '../../../../features/ecommerce/presentation/screens/public/product_list_screen.dart';
import '../../../../features/home/presentation/providers/homepage_provider.dart';
import '../../../../features/home/presentation/screens/homepage_management_screen.dart';
import '../../../../features/status/presentation/screens/status_viewer_screen.dart';
import '../../../../features/status/presentation/providers/status_provider.dart';
import '../../../../features/attendance/presentation/screens/attendance_list_screen.dart';
import '../../../../shared/widgets/dashboard_section.dart';
import '../../../../shared/widgets/dashboard_info_box.dart';
import 'package:shilpkar/features/notifications/presentation/widgets/notification_bell.dart';
import '../../../../shared/widgets/homepage_cover_media.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomepageProvider>().fetchHomepage();
      context.read<StatusProvider>().fetchStatuses();
    });
  }

  void _go(Widget screen) => AppRouter.push(context, screen);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  // ─── Our Vision / Our Work / Our Impact ────────────────
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Container(width: 4, height: 18, decoration: BoxDecoration(color: AppColors.appBarBlue, borderRadius: BorderRadius.circular(2))),
                        const SizedBox(width: 10),
                        Text(l10n.ourVisionWork,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                      ],
                    ),
                  ),
                  const StatusRingRow(),
                  const SizedBox(height: 10),

                  // ─── User Management ──────────────────────────────────────
                  DashboardSection(
                    title: l10n.userManagement,
                    icon: Icons.people_alt_outlined,
                    color: AppColors.appBarBlue,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: DashboardInfoBox(
                                title: l10n.createEmployee,
                                subtitle: l10n.createEmployeeSub,
                                buttonLabel: l10n.createNow,
                                icon: Icons.person_add,
                                iconColor: AppColors.createEmployeeBtnGreen,
                                buttonColor: AppColors.createEmployeeBtnGreen,
                                bgColor: AppColors.actionCardBgDefault,
                                onTap: () => _go(const SelectEmployeeRoleScreen()),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DashboardInfoBox(
                                title: 'View Community',
                                subtitle: 'Search, filter, profile, and message everyone in one place',
                                buttonLabel: l10n.viewList,
                                icon: Icons.people_outline,
                                iconColor: const Color(0xFFE67E22),
                                buttonColor: const Color(0xFFE67E22),
                                bgColor: AppColors.actionCardBgDefault,
                                onTap: () => _go(const EmployeeListAdminScreen()),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ─── Programs & Attendance ────────────────────────────────
                  DashboardSection(
                    title: l10n.programsAttendance,
                    icon: Icons.assignment_turned_in_outlined,
                    color: AppColors.lightBlueScheme,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: DashboardInfoBox(
                                title: l10n.manageJobs,
                                subtitle: l10n.manageJobsSub,
                                buttonLabel: 'View Details',
                                icon: Icons.work_outline,
                                bgColor: AppColors.actionCardBlueBg,
                                iconColor: AppColors.actionCardBlueIcon,
                                buttonColor: AppColors.actionCardBlueIcon,
                                onTap: () => _go(const AdminJobManagementScreen()),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DashboardInfoBox(
                                title: l10n.manageSchemes,
                                subtitle: l10n.manageSchemeSub,
                                buttonLabel: 'View Details',
                                icon: Icons.assignment_outlined,
                                bgColor: AppColors.actionCardGreenBg,
                                iconColor: AppColors.actionCardGreenIcon,
                                buttonColor: AppColors.actionCardGreenIcon,
                                onTap: () => _go(const SuperAdminSchemeManagementScreen()),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: DashboardInfoBox(
                                title: l10n.jobRequests,
                                subtitle: l10n.jobRequestsAdminSub,
                                buttonLabel: 'View Details',
                                icon: Icons.work_history_outlined,
                                bgColor: AppColors.actionCardDeepOrangeBg,
                                iconColor: AppColors.actionCardDeepOrangeIcon,
                                buttonColor: AppColors.actionCardDeepOrangeIcon,
                                onTap: () => _go(const AdminJobManagementScreen()),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DashboardInfoBox(
                                title: l10n.attendance,
                                subtitle: l10n.attendanceSub,
                                buttonLabel: 'View Details',
                                icon: Icons.fingerprint_rounded,
                                bgColor: AppColors.actionCardPurpleBg,
                                iconColor: AppColors.myApplicationsPurple,
                                buttonColor: AppColors.myApplicationsPurple,
                                onTap: () => _go(const AttendanceListScreen()),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ─── E-Commerce ───────────────────────────────────────────
                  DashboardSection(
                    title: l10n.ecommerceManagement,
                    icon: Icons.storefront_outlined,
                    color: AppColors.sectionEcommerceRed,
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
                                bgColor: AppColors.actionCardRedBg,
                                iconColor: AppColors.actionCardRedIcon,
                                buttonColor: AppColors.actionCardRedIcon,
                                onTap: () => _go(const AdminProductManagementScreen()),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DashboardInfoBox(
                                title: l10n.categories,
                                subtitle: l10n.manageCategories,
                                buttonLabel: 'View Details',
                                icon: Icons.category_outlined,
                                bgColor: AppColors.actionCardPurpleBg,
                                iconColor: AppColors.actionCardPurpleIcon,
                                buttonColor: AppColors.actionCardPurpleIcon,
                                onTap: () => _go(const AdminCategoryManagementScreen()),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: DashboardInfoBox(
                                title: l10n.exploreProducts,
                                subtitle: l10n.exploreProductsSub,
                                buttonLabel: 'View Details',
                                icon: Icons.shopping_bag_outlined,
                                bgColor: AppColors.actionCardGreenBg,
                                iconColor: AppColors.actionCardGreenIcon,
                                buttonColor: AppColors.actionCardGreenIcon,
                                onTap: () => _go(const ProductListScreen()),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DashboardInfoBox(
                                title: l10n.manageOrders,
                                subtitle: l10n.manageOrdersSub,
                                buttonLabel: 'View Details',
                                icon: Icons.local_shipping_outlined,
                                bgColor: AppColors.actionCardOrangeBg,
                                iconColor: AppColors.actionCardOrangeIcon,
                                buttonColor: AppColors.actionCardOrangeIcon,
                                onTap: () => _go(const AdminOrderManagementScreen()),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: DashboardInfoBox(
                                title: l10n.refundRequests,
                                subtitle: l10n.refundRequestsSub,
                                buttonLabel: 'View Details',
                                icon: Icons.assignment_return_outlined,
                                bgColor: AppColors.actionCardTealBg,
                                iconColor: AppColors.actionCardTealIcon,
                                buttonColor: AppColors.actionCardTealIcon,
                                onTap: () => _go(const AdminRefundManagementScreen()),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(child: SizedBox()), // Empty space to match grid
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ─── Communication & Quick Access ─────────────────────────
                  DashboardSection(
                    title: l10n.communication,
                    icon: Icons.forum_outlined,
                    color: AppColors.communicationPurple,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Consumer<ChatProvider>(
                                builder: (context, chatProvider, _) {
                                  final showDot =
                                      chatProvider.unreadCount > 0 ||
                                      chatProvider.requests.any(
                                        (r) => r.status == 'PENDING',
                                      );
                                  return DashboardInfoBox(
                                    title: 'Live Chat',
                                    subtitle: 'Respond to community messages',
                                    buttonLabel: 'Open',
                                    icon: Icons.chat_bubble_outline,
                                    bgColor: AppColors.actionCardIndigoBg,
                                    iconColor: AppColors.actionCardIndigoIcon,
                                    buttonColor: AppColors.actionCardIndigoIcon,
                                    showDot: showDot,
                                    onTap: () => _go(const chat.ChatListScreen()),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DashboardInfoBox(
                                title: l10n.systemBroadcasts,
                                subtitle: l10n.systemBroadcastsSub,
                                buttonLabel: 'View Details',
                                icon: Icons.campaign_outlined,
                                bgColor: AppColors.actionCardDeepOrangeBg,
                                iconColor: AppColors.broadcastOrange,
                                buttonColor: AppColors.broadcastOrange,
                                onTap: () => _go(const AdminBroadcastScreen()),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── AppBar ──────────────────────────────────────────────────────────
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
              l10n.shilpkarAdmin,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
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
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () async {
            try {
              await context.read<AuthProvider>().logout();
            } catch (e) {
              debugPrint("AdminDashboard: Logout error: $e");
            }
            if (context.mounted) {
              AppRouter.pushAndRemoveUntil(
                context,
                const MainNavigationScreen(initialIndex: 1),
              );
            }
          },
        ),
      ],
    );
  }

  // ─── Hero Banner (with edit button) ──────────────────────────────────
  Widget _buildHeroSection() {
    return Consumer<HomepageProvider>(
      builder: (context, provider, _) {
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
                Positioned.fill(child: Container(color: Colors.black45)),
                Positioned.fill(
                  child: Center(
                    child: Consumer<LanguageProvider>(
                      builder: (context, _, __) {
                        final l10n = AppLocalizations.of(context)!;
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.adminDashboard,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.adminDashboardSub,
                              style:
                                  const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            // Edit button overlay (same as Super Admin)
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => _go(const HomepageManagementScreen()),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                  child: const Icon(Icons.edit, color: AppColors.appBarBlue, size: 20),
                ),
              ),
            ),
          ],
        );
      },
    );
  }



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
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}
