import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/GradientActionCard.dart';
import '../../../home/presentation/providers/homepage_provider.dart';
import '../../../../features/ecommerce/presentation/screens/public/product_list_screen.dart';

import 'beneficiary_login_screen.dart';
import 'employee_login_screen.dart';
import 'package:shilpkar/features/dashboard/presentation/screens/admin_login_screen.dart';
import 'package:shilpkar/features/jobs/presentation/screens/job_list_screen.dart';

class PublicHomeScreen extends StatefulWidget {
  const PublicHomeScreen({super.key});

  @override
  State<PublicHomeScreen> createState() => _PublicHomeScreenState();
}

class _PublicHomeScreenState extends State<PublicHomeScreen> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomepageProvider>().fetchHomepage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ─── Hero Banner ─────────────────────────────────
            _buildHeroSection(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // ─── Login Action Cards ──────────────────────
                  GradientActionCard(
                    title: "Login as Employee",
                    subtitle: "for field staff, coordinators and office team",
                    icon: Icons.person_pin_rounded,
                    gradientColors: AppColors.employeeGradient,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EmployeeLoginScreen()),
                    ),
                  ),

                  GradientActionCard(
                    title: "Login as Beneficiary",
                    subtitle: "for farmers, women, workers, students & citizens",
                    icon: Icons.group_add_rounded,
                    gradientColors: AppColors.beneficiaryGradient,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BeneficiaryLoginScreen()),
                    ),
                  ),

                  GradientActionCard(
                    title: "Login as Admin",
                    subtitle: "for admins and super-admin",
                    icon: Icons.admin_panel_settings_rounded,
                    gradientColors: AppColors.adminGradient,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                    ),
                  ),

                  GradientActionCard(
                    title: "Apply for a Job",
                    subtitle: "View open positions and apply with your qualifications",
                    icon: Icons.work_outline,
                    gradientColors: AppColors.jobGradient,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const JobListScreen()),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ─── Info Boxes Row ──────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoBox(
                          icon: Icons.diversity_3_rounded,
                          iconColor: AppColors.primaryBlue,
                          title: "Join Us on our social mission",
                          subtitle: "Be a part of beautiful change",
                          buttonLabel: "Join Now",
                          buttonColor: AppColors.primaryBlue,
                          bgColor: AppColors.joinUsBg,
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoBox(
                          icon: Icons.volunteer_activism_rounded,
                          iconColor: AppColors.accentRed,
                          title: "Purpose Driven Products",
                          subtitle: "Every product you support creates impact",
                          buttonLabel: "Explore Products",
                          buttonColor: AppColors.secondaryGreen,
                          bgColor: AppColors.productsBg,
                          onTap: () {
                             Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductListScreen()));
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ─── Pillar Cards Row ────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _buildPillarCard(
                          icon: Icons.auto_awesome_rounded,
                          iconColor: AppColors.secondaryGreen,
                          label: "Our Vision",
                          sub: "Why we Exist",
                          bgColor: const Color(0xFFE8F5E9),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildPillarCard(
                          icon: Icons.handyman_rounded,
                          iconColor: AppColors.primaryBlue,
                          label: "Our Work",
                          sub: "what we do on the ground",
                          bgColor: const Color(0xFFE3F2FD),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildPillarCard(
                          icon: Icons.emoji_events_rounded,
                          iconColor: AppColors.accentRed,
                          label: "Our Impact",
                          sub: "Lives touched & villages reached",
                          bgColor: const Color(0xFFFCE4EC),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ─── Donate Card ─────────────────────────────
                  _buildDonateCard(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  APP BAR
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.appBarBlue,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          Image.asset('assets/Images/logoSk.png', height: 35),
          const SizedBox(width: 8),
          const Text(
            "Shilpkar Foundation",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
      actions: [
        Center(
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "English | मराठी",
              style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  HERO BANNER
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildHeroSection() {
    return Consumer<HomepageProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.homepage == null) {
          return const SizedBox(
            height: 180,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final coverImages = provider.coverImageUrls;
        final title = provider.welcomeTitle;
        final subtitle = provider.welcomeSubtitle;

        return SizedBox(
          height: 180,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              coverImages.isNotEmpty
                  ? PageView.builder(
                      controller: _pageController,
                      itemCount: coverImages.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          coverImages[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset('assets/Images/Frame2.png',
                                fit: BoxFit.cover);
                          },
                        );
                      },
                    )
                  : Image.asset('assets/Images/Frame2.png', fit: BoxFit.cover),

              // Dark Overlay
              Container(color: Colors.black.withOpacity(0.45)),

              // Text Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  INFO BOX (Join Us / Purpose Driven)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildInfoBox({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required Color buttonColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 32,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.zero,
              ),
              child: Text(
                buttonLabel,
                style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  PILLAR CARD (Our Vision / Our Work / Our Impact)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildPillarCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String sub,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  DONATE CARD
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildDonateCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Donate",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  "Your support help us reach more communities",
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryGreen,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            ),
            child: const Text(
              "Donate",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
