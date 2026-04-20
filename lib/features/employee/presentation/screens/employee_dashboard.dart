import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/main_navigation.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/dashboard_info_card.dart';
import '../../../../shared/widgets/dashboard_info_box.dart';
import '../../../../core/constants/user_roles.dart';
import '../../../attendance/presentation/screens/attendance_screen.dart';
import '../../../attendance/presentation/screens/attendance_list_screen.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../chat/presentation/screens/chat_request_screen.dart';
import '../../../home/presentation/providers/homepage_provider.dart';
import '../../../chat/presentation/screens/public_broadcast_screen.dart';
import '../../../../features/admin/presentation/screens/create_beneficiary_screen.dart';
import 'offline_beneficiary_screen.dart';
import 'online_beneficiary_screen.dart';
import '../../../../shared/widgets/dashboard_section.dart';
import 'package:shilpkar/features/notifications/presentation/widgets/notification_bell.dart';
import '../../../../shared/widgets/homepage_cover_media.dart';
import '../../../../features/employee/presentation/screens/employee_payment_screens.dart';
import '../../../status/presentation/providers/status_provider.dart';
import '../../../status/presentation/screens/status_viewer_screen.dart';

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
      context.read<StatusProvider>().fetchStatuses();
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
                const SizedBox(height: 12),
                const StatusRingRow(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                  // ─── Daily Operations ───────────────────────────────────────
                  DashboardSection(
                    title: l10n.attendance ?? "Daily Operations",
                    icon: Icons.access_time_filled_outlined,
                    color: AppColors.attendanceTeal,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: DashboardInfoBox(
                                title: l10n.attendance,
                                subtitle: l10n.attendancePunchInOut,
                                buttonLabel: 'View Details',
                                icon: Icons.access_time,
                                bgColor: AppColors.jobCard,
                                iconColor: Colors.black,
                                buttonColor: Colors.black,
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceScreen())),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DashboardInfoBox(
                                title: l10n.attendance,
                                subtitle: l10n.attendanceViewAll,
                                buttonLabel: 'View Details',
                                icon: Icons.fingerprint_rounded,
                                bgColor: AppColors.attendanceTealBg,
                                iconColor: AppColors.attendanceTeal,
                                buttonColor: AppColors.attendanceTeal,
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceListScreen())),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ─── Communication & Support ─────────────────────────────────
                  DashboardSection(
                    title: l10n.communication ?? "Communication",
                    icon: Icons.chat_bubble_outline,
                    color: AppColors.primaryBlue,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: DashboardInfoBox(
                                title: l10n.connectWithAdmin,
                                subtitle: l10n.resolveQueries,
                                buttonLabel: 'View Details',
                                icon: Icons.forum_rounded,
                                bgColor: AppColors.joinUsBg,
                                iconColor: AppColors.primaryBlue,
                                buttonColor: AppColors.primaryBlue,
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatRequestScreen())),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DashboardInfoBox(
                                title: l10n.announcements,
                                subtitle: l10n.systemMessages,
                                buttonLabel: 'View Details',
                                icon: Icons.campaign_rounded,
                                bgColor: AppColors.announcementOliveBg,
                                iconColor: AppColors.announcementOlive,
                                buttonColor: AppColors.announcementOlive,
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PublicBroadcastScreen())),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ─── User Management ─────────────────────────────────────────
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
                                title: 'Add Beneficiary',
                                subtitle: 'Choose online or offline mode',
                                buttonLabel: 'Create',
                                icon: Icons.person_add_alt_1_outlined,
                                bgColor: Colors.blue.shade50,
                                iconColor: AppColors.appBarBlue,
                                buttonColor: AppColors.appBarBlue,
                                onTap: () => _showOnboardingMode(context),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DashboardInfoBox(
                                title: 'Request Payment',
                                subtitle: 'Submit expense reimbursement',
                                buttonLabel: 'Request',
                                icon: Icons.currency_rupee_outlined,
                                bgColor: Colors.green.shade50,
                                iconColor: const Color(0xFF27AE60),
                                buttonColor: const Color(0xFF27AE60),
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmployeePaymentRequestScreen())),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
    final role = context.read<AuthProvider>().role;
    final String title = UserRole.isCoordinatorRole(role)
        ? '${UserRole.displayName(role ?? UserRole.coordinator)} Dashboard'
        : l10n.shilpkarEmployee;
    return AppBar(
      backgroundColor: AppColors.appBarBlue,
      elevation: 0,
      title: Row(
        children: [
          Image.asset('assets/Images/home.jpeg', height: 40),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
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

  void _showOnboardingMode(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Select Onboarding Mode',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: const Text('Online Mode'),
                subtitle: const Text('Beneficiary has a smartphone'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OnlineBeneficiaryScreen(),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Offline Mode'),
                subtitle: const Text('No OTP, immediate creation'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OfflineBeneficiaryScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeroSection(AppLocalizations l10n) {
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
                child: Column(
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
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
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
