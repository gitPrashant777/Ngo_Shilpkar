import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/GradientActionCard.dart';
import '../../../home/presentation/providers/homepage_provider.dart';
import '../../../../features/ecommerce/presentation/screens/public/product_list_screen.dart';
import '../../../../features/status/presentation/screens/status_viewer_screen.dart';
import '../../../../features/status/presentation/providers/status_provider.dart';
import '../../../../features/schemes/presentation/providers/scheme_provider.dart';

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
      context.read<StatusProvider>().fetchStatuses();
      context.read<SchemeProvider>().fetchPublishedSchemes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: _buildAppBar(l10n),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          children: [
            // ─── Hero Banner ─────────────────────────────────
            _buildHeroSection(),

            // ─── Our Vision / Our Work / Our Impact (Status Stories) ─────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 10),
                  Text(l10n.ourVisionSection,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const StatusRingRow(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // ─── Login Action Cards ──────────────────────
                  GradientActionCard(
                    title: l10n.loginAsEmployee,
                    subtitle: l10n.loginAsEmployeeSubtitle,
                    icon: Icons.person_pin_rounded,
                    gradientColors: AppColors.employeeGradient,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EmployeeLoginScreen()),
                    ),
                  ),

                  GradientActionCard(
                    title: l10n.loginAsBeneficiary,
                    subtitle: l10n.loginAsBeneficiarySubtitle,
                    icon: Icons.group_add_rounded,
                    gradientColors: AppColors.beneficiaryGradient,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const BeneficiaryLoginScreen()),
                    ),
                  ),

                  GradientActionCard(
                    title: l10n.loginAsAdmin,
                    subtitle: l10n.loginAsAdminSubtitle,
                    icon: Icons.admin_panel_settings_rounded,
                    gradientColors: AppColors.adminGradient,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AdminLoginScreen()),
                    ),
                  ),

                  GradientActionCard(
                    title: l10n.applyForJob,
                    subtitle: l10n.applyForJobSubtitle,
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
                        child: _buildInfoBox(
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

                  const SizedBox(height: 16),

                  // ─── Pillar Cards Row ────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _buildPillarCard(
                          icon: Icons.auto_awesome_rounded,
                          iconColor: AppColors.secondaryGreen,
                          label: l10n.ourVision,
                          sub: l10n.whyWeExist,
                          bgColor: AppColors.visionBg,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildPillarCard(
                          icon: Icons.handyman_rounded,
                          iconColor: AppColors.primaryBlue,
                          label: l10n.ourWork,
                          sub: l10n.whatWeDo,
                          bgColor: AppColors.workBg,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildPillarCard(
                          icon: Icons.emoji_events_rounded,
                          iconColor: AppColors.accentRed,
                          label: l10n.ourImpact,
                          sub: l10n.livesTouched,
                          bgColor: AppColors.impactBg,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ─── Schemes Section ─────────────────────────
                  _buildSchemesSection(l10n),

                  const SizedBox(height: 16),

                  // ─── Donate Card ─────────────────────────────
                  _buildDonateCard(l10n),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  SCHEMES SECTION (public preview)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildSchemesSection(AppLocalizations l10n) {
    return Consumer<SchemeProvider>(
      builder: (context, provider, _) {
        final schemes = provider.publishedSchemes;
        final hasError = provider.error != null && schemes.isEmpty;
        final isEmpty = !provider.isLoading && schemes.isEmpty && !hasError;

        // Section label row
        Widget header = Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.governmentNgoSchemes,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
            ],
          ),
        );

        // Loading shimmer
        if (provider.isLoading && schemes.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            ],
          );
        }

        // Failed or empty → show login CTA
        if (hasError || isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.schemeGreenLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.schemeBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.assignment_outlined,
                        color: AppColors.schemeGreen, size: 36),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.schemesAvailableForYou,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black87),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.loginToViewSchemes,
                            style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black54,
                                height: 1.4),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: 34,
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const BeneficiaryLoginScreen()),
                              ),
                              icon: const Icon(Icons.login,
                                  size: 15, color: Colors.white),
                              label: Text(
                                l10n.loginAsBeneficiary,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.schemeGreen,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        // Schemes loaded — show preview (max 3) + login CTA
        final preview = schemes.take(3).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            ...preview.map((scheme) {
              final isPaid = scheme.price > 0;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6)
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.assignment_rounded,
                          color: AppColors.primaryBlue, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(scheme.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text(scheme.description,
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey.shade500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPaid
                            ? Colors.orange.shade50
                            : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isPaid ? '₹${scheme.price.toInt()}' : l10n.free,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isPaid
                              ? Colors.orange.shade700
                              : Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            // Login CTA at the bottom
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const BeneficiaryLoginScreen()),
              ),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryBlue, AppColors.schemeGradientEnd],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.login_rounded,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      schemes.length > 3
                          ? l10n.loginToSeeAllSchemes(schemes.length)
                          : l10n.loginToApplySchemes,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
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

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  //  APP BAR
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  PreferredSizeWidget _buildAppBar(AppLocalizations l10n) {
    return AppBar(
      backgroundColor: AppColors.appBarBlue,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          Image.asset('assets/Images/logoSk.png', height: 35),
          const SizedBox(width: 8),
          Text(
            l10n.shilpkarFoundation,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
      actions: [
        Consumer<LanguageProvider>(
          builder: (context, langProvider, _) =>
              langProvider.buildToggleWidget(),
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
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12),
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.zero,
              ),
              child: Text(
                buttonLabel,
                style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
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
  Widget _buildDonateCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.favorite_rounded,
              color: AppColors.donateIconRed, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.donate,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  l10n.donateSubtitle,
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            ),
            child: Text(
              l10n.donate,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
