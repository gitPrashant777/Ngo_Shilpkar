import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shilpkar/features/jobs/presentation/screens/job_list_screen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/main_navigation.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/utils/storage_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/action_card.dart';
import '../../../../shared/widgets/dashboard_info_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../beneficiary/presentation/screens/my_application_screen.dart';
import '../../../chat/presentation/screens/chat_list_screen.dart' as shilpkar;
import '../../../ecommerce/presentation/screens/public/product_list_screen.dart';
import '../../../jobs/presentation/screens/user_job_list_screen.dart';
import '../../../schemes/presentation/screens/user_scheme_list_screen.dart';
import '../../../home/presentation/providers/homepage_provider.dart';
import '../../../chat/presentation/screens/public_broadcast_screen.dart';
import '../../../ecommerce/presentation/screens/public/my_orders_screen.dart';
import 'package:shilpkar/features/notifications/presentation/widgets/notification_bell.dart';

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
          const Icon(Icons.forum_outlined,
              color: Color(0xFF55789A), size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.connectWithAdmin,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text(l10n.connectWithAdminSub,
                    style:
                    const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const shilpkar.ChatListScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF55789A),
              shape: const StadiumBorder(),
            ),
            child: Text(l10n.chat,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildFullWidthAction(
                        l10n.applyForAJob,
                        l10n.applyForAJobSub,
                        Icons.edit_document,
                        const Color(0xFFD9A05B),
                            () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (_) => const JobListScreen()));
                        },
                      ),
                      const SizedBox(height: 16),
    
                      Row(
                        children: [
                          Expanded(
                            child: _buildCategoryBox(
                              l10n.myJobApplications,
                              l10n.myJobApplicationsSub,
                              l10n.viewApplications,
                              Icons.work,
                              const Color(0xFF55789A),
                                  () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (_) => const MyApplicationsScreen()));
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCategoryBox(
                              l10n.products,
                              l10n.productsSub,
                              l10n.explore,
                              Icons.shopping_bag_rounded,
                              const Color(0xFF7A9E6F),
                                  () {
                                 Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductListScreen()));
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      _buildFullWidthAction(
                        l10n.announcements,
                        l10n.announcementsSub,
                        Icons.campaign_outlined,
                        const Color(0xFF6B8E23),
                            () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (_) => const PublicBroadcastScreen()));
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      _buildFullWidthAction(
                        l10n.myOrders,
                        l10n.myOrdersSub,
                        Icons.shopping_cart_checkout_rounded,
                        const Color(0xFF4373AD), 
                            () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (_) => const MyOrdersScreen()));
                        },
                      ),
                      const SizedBox(height: 16),
    
                      _buildInfoGrid(l10n),
                      const SizedBox(height: 16),
    
                      _buildSupportCard(context, l10n),
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
          Image.asset('assets/Images/logoSk.png', height: 40),
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
          builder: (context, langProvider, _) => langProvider.buildToggleWidget(),
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
          String? bannerUrl;
          if (provider.homepage != null && provider.homepage!.coverImages.isNotEmpty) {
            bannerUrl = provider.homepage!.coverImages.first.url;
          }
        return Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: bannerUrl != null
                  ? NetworkImage(bannerUrl)
                  : const AssetImage('assets/Images/Frame2.png') as ImageProvider,
              fit: BoxFit.cover,
              colorFilter: const ColorFilter.mode(Colors.black45, BlendMode.darken),
            ),
          ),
          child: Center(
            child: Consumer<LanguageProvider>(
              builder: (context, _, __) {
                final l10n = AppLocalizations.of(context)!;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l10n.welcomeShilpkar,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(l10n.empoweringCommunities,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      }
    );
  }

  Widget _buildCategoryBox(String title, String sub, String btnText, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text(sub, style: const TextStyle(fontSize: 10, color: Colors.grey), maxLines: 2),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(btnText, style: const TextStyle(fontSize: 11, color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFullWidthAction(String title, String sub, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                  Text(sub, style: const TextStyle(fontSize: 11, color: Colors.white70)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoGrid(AppLocalizations l10n) {
    return Row(
      children: [
        _buildMiniCard(l10n.ourVision, Icons.track_changes_rounded, Colors.orange),
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
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }


}
