import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shilpkar/features/jobs/presentation/screens/job_list_screen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/main_navigation.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/utils/storage_service.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../../shared/widgets/dashboard_info_card.dart';
import '../../../../shared/widgets/dashboard_info_box.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../beneficiary/presentation/screens/my_application_screen.dart';
import '../../../chat/presentation/screens/chat_list_screen.dart' as shilpkar;
import '../../../ecommerce/presentation/screens/public/product_list_screen.dart';
import '../../../jobs/presentation/screens/user_job_list_screen.dart';
import '../../../schemes/presentation/screens/user_scheme_list_screen.dart';
import '../../../home/presentation/providers/homepage_provider.dart';
import '../../../chat/presentation/screens/public_broadcast_screen.dart';
import '../../../ecommerce/presentation/screens/public/user_orders_screen.dart';
import '../../../../shared/widgets/dashboard_section.dart';
import 'package:shilpkar/features/notifications/presentation/widgets/notification_bell.dart';
import '../../../../shared/widgets/homepage_cover_media.dart';
import '../../../status/presentation/providers/status_provider.dart';
import '../../../status/presentation/screens/status_viewer_screen.dart';
import 'package:shilpkar/features/jobs/presentation/screens/apply_job_screen.dart';
import 'package:shilpkar/features/jobs/presentation/screens/local_job_data.dart';

class BeneficiaryDashboard extends StatefulWidget {
  const BeneficiaryDashboard({super.key});

  @override
  State<BeneficiaryDashboard> createState() => _BeneficiaryDashboardState();
}

class _BeneficiaryDashboardState extends State<BeneficiaryDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomepageProvider>().fetchHomepage();
      context.read<StatusProvider>().fetchStatuses();
    });
  }

  Widget _buildSupportCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(Icons.forum_outlined, color: Color(0xFF55789A), size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.connectWithAdmin,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  l10n.connectWithAdminSub,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const shilpkar.ChatListScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF55789A),
              shape: const StadiumBorder(),
            ),
            child: Text(l10n.chat, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToJobs() async {
    final localData = await LocalJobDataStorage.getJobData();
    if (localData != null && localData.isNotEmpty) {
      if (mounted)
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const JobListScreen()),
        );
    } else {
      if (mounted)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ApplyJobScreen(isPreScreen: true),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        _buildAppBar(context),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeroSection(),
                const SizedBox(height: 12),
                const StatusRingRow(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // ─── Programs & Jobs ─────────────────────────────────────
                      DashboardSection(
                        title: l10n.applyForAJob ?? "Programs & Jobs",
                        icon: Icons.work_outline,
                        color: const Color(0xFFD9A05B),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: DashboardInfoBox(
                                    title: l10n.applyForAJob,
                                    subtitle: l10n.applyForAJobSub,
                                    buttonLabel: 'View Details',
                                    icon: Icons.edit_document,
                                    bgColor: const Color(0xFFFFF3E0),
                                    iconColor: const Color(0xFFF57C00),
                                    buttonColor: const Color(0xFFF57C00),
                                    onTap: _navigateToJobs,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: DashboardInfoBox(
                                    title: l10n.myJobApplications,
                                    subtitle: l10n.myJobApplicationsSub,
                                    buttonLabel: 'View Details',
                                    icon: Icons.work,
                                    bgColor: const Color(0xFFE3F2FD),
                                    iconColor: const Color(0xFF1976D2),
                                    buttonColor: const Color(0xFF1976D2),
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const MyApplicationsScreen(),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ─── E-Commerce  ──────────────────────────────────────────
                      DashboardSection(
                        title: l10n.products ?? "E-Commerce",
                        icon: Icons.storefront_outlined,
                        color: const Color(0xFF7A9E6F),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: DashboardInfoBox(
                                    title: l10n.products,
                                    subtitle: l10n.productsSub,
                                    buttonLabel: 'View Details',
                                    icon: Icons.shopping_bag_rounded,
                                    bgColor: const Color(0xFFE8F5E9),
                                    iconColor: const Color(0xFF4CAF50),
                                    buttonColor: const Color(0xFF4CAF50),
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const ProductListScreen(),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: DashboardInfoBox(
                                    title: l10n.myOrders,
                                    subtitle: l10n.myOrdersSub,
                                    buttonLabel: 'View Details',
                                    icon: Icons.shopping_cart_checkout_rounded,
                                    bgColor: const Color(0xFFFFF8E1),
                                    iconColor: const Color(0xFFFFA000),
                                    buttonColor: const Color(0xFFFFA000),
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const UserOrdersScreen(),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ─── Communication & Support ──────────────────────────────
                      DashboardSection(
                        title: l10n.announcements ?? "Communication & Support",
                        icon: Icons.campaign_outlined,
                        color: const Color(0xFF6B8E23),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: DashboardInfoBox(
                                    title: l10n.announcements,
                                    subtitle: l10n.announcementsSub,
                                    buttonLabel: 'View Details',
                                    icon: Icons.campaign_outlined,
                                    bgColor: const Color(0xFFF3E5F5),
                                    iconColor: const Color(0xFF8E24AA),
                                    buttonColor: const Color(0xFF8E24AA),
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const PublicBroadcastScreen(),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: DashboardInfoBox(
                                    title: l10n.connectWithAdmin,
                                    subtitle: l10n.connectWithAdminSub,
                                    buttonLabel: 'View Details',
                                    icon: Icons.forum_outlined,
                                    bgColor: const Color(0xFFE8EAF6),
                                    iconColor: const Color(0xFF5C6BC0),
                                    buttonColor: const Color(0xFF5C6BC0),
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const shilpkar.ChatListScreen(),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      _buildInfoGrid(l10n),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
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
              AppLocalizations.of(context)!.shilpkarFoundation,
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
          builder: (context, langProvider, _) =>
              langProvider.buildToggleWidget(),
        ),
        const NotificationBell(iconColor: Colors.white),
        const SizedBox(width: 2),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () async {
            try {
              await context.read<AuthProvider>().logout();
            } catch (e) {
              debugPrint("BeneficiaryDashboard: Logout error: $e");
            }
            if (context.mounted) {
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
                              l10n.welcomeShilpkar,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                l10n.empoweringCommunities,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
      },
    );
  }

  Widget _buildCategoryBox(
    String title,
    String sub,
    String btnText,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF1F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Text(
            sub,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                btnText,
                style: const TextStyle(fontSize: 11, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(AppLocalizations l10n) {
    return Row(
      children: [
        _buildMiniCard(
          l10n.ourVision,
          Icons.track_changes_rounded,
          Colors.orange,
        ),
        const SizedBox(width: 8),
        _buildMiniCard(l10n.ourWork, Icons.auto_graph_rounded, Colors.blue),
        const SizedBox(width: 8),
        _buildMiniCard(l10n.ourImpact, Icons.public_rounded, Colors.green),
      ],
    );
  }

  Widget _buildMiniCard(String title, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF1F5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
