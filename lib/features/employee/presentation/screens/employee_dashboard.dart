import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/main_navigation.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/dashboard_info_card.dart';
import '../../../attendance/presentation/screens/attendance_screen.dart';
import '../../../attendance/presentation/screens/attendance_list_screen.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../chat/presentation/screens/chat_list_screen.dart';
import '../../../chat/presentation/screens/chat_request_screen.dart';
import '../../../ecommerce/presentation/screens/public/product_list_screen.dart';
import '../../../home/presentation/providers/homepage_provider.dart';
import '../../../chat/presentation/screens/public_broadcast_screen.dart';
import '../../../../features/admin/presentation/screens/create_beneficiary_screen.dart';
import 'package:shilpkar/features/notifications/presentation/widgets/notification_bell.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomepageProvider>().fetchHomepage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        _buildAppBar(context, l10n),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeroSection(l10n),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildAttendanceAction(
                        l10n.attendance,
                        l10n.attendancePunchInOut,
                        AppColors.jobCard,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AttendanceScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      DashboardInfoCard(
                        icon: Icons.forum_rounded,
                        iconColor: AppColors.primaryBlue,
                        title: l10n.connectWithAdmin,
                        subtitle: l10n.resolveQueries,
                        buttonLabel: l10n.chatNow,
                        buttonColor: AppColors.primaryBlue,
                        bgColor: AppColors.joinUsBg,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ChatRequestScreen())),
                      ),
                      const SizedBox(height: 16),

                      const SizedBox(height: 16),

                      // ── Attendance Records  +  Announcements (side by side) ──
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: DashboardInfoCard(
                              icon: Icons.fingerprint_rounded,
                              iconColor: AppColors.attendanceTeal,
                              title: l10n.attendance,
                              subtitle: l10n.attendanceViewAll,
                              buttonLabel: l10n.viewList,
                              buttonColor: AppColors.attendanceTeal,
                              bgColor: AppColors.attendanceTealBg,
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const AttendanceListScreen())),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DashboardInfoCard(
                              icon: Icons.campaign_rounded,
                              iconColor: AppColors.announcementOlive,
                              title: l10n.announcements,
                              subtitle: l10n.systemMessages,
                              buttonLabel: l10n.viewAll,
                              buttonColor: AppColors.announcementOlive,
                              bgColor: AppColors.announcementOliveBg,
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const PublicBroadcastScreen())),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

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

  PreferredSizeWidget _buildAppBar(BuildContext context, AppLocalizations l10n) {
    return AppBar(
      backgroundColor: AppColors.appBarBlue,
      elevation: 0,
      title: Row(
        children: [
          Image.asset('assets/Images/logoSk.png', height: 40),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              l10n.shilpkarEmployee,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white),
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
              debugPrint("EmployeeDashboard: Calling logout...");
              await context.read<AuthProvider>().logout();
            } catch (e) {
              debugPrint("EmployeeDashboard: Logout error: $e");
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

  Widget _buildHeroSection(AppLocalizations l10n) {
    return Consumer<HomepageProvider>(
      builder: (context, provider, _) {
        String? bannerUrl;
        if (provider.homepage != null &&
            provider.homepage!.coverImages.isNotEmpty) {
          bannerUrl = provider.homepage!.coverImages.first.url;
        }
        return Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: bannerUrl != null
                  ? NetworkImage(bannerUrl)
                  : const AssetImage('assets/Images/Frame2.png')
                      as ImageProvider,
              fit: BoxFit.cover,
              colorFilter: const ColorFilter.mode(Colors.black45, BlendMode.darken),
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(l10n.welcomeShilpkar,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(l10n.empoweringCommunities,
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttendanceAction(
      String title, String sub, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black)),
            Text(sub,
                style:
                    const TextStyle(fontSize: 11, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoGrid(AppLocalizations l10n) {
    return Row(
      children: [
        _buildMiniCard(l10n.ourVision, l10n.whyWeExist,
            Icons.track_changes_rounded, AppColors.broadcastOrange),
        const SizedBox(width: 8),
        _buildMiniCard(l10n.ourWork, l10n.whatWeDoBrief,
            Icons.auto_graph_rounded, AppColors.primaryBlue),
        const SizedBox(width: 8),
        _buildMiniCard(l10n.ourImpact, l10n.villageReached,
            Icons.public_rounded, AppColors.secondaryGreen),
      ],
    );
  }

  Widget _buildMiniCard(
      String title, String sub, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(title,
                style: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.bold)),
            Text(sub,
                style: const TextStyle(
                    fontSize: 8, color: AppColors.textSecondary),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}