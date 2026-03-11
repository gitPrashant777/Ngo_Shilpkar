import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/job_info_row.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

import '../../data/models/job_model.dart';
import 'apply_job_screen.dart';
import 'job_applications_screen.dart';

class JobDetailScreen extends StatelessWidget {
  final JobModel job;

  const JobDetailScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.shilpkarFoundation,
          style: const TextStyle(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: Stack(
        children: [
          // ── Scrollable content ─────────────────────────────────────────────
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header: title + org + logo ────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            job.organization,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const JobLogoPlaceholder(size: 80),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Info rows: location / duration / stipend ───────────────
                JobInfoRow(
                  icon: Icons.location_on_outlined,
                  text: job.city.isNotEmpty ? job.city : 'Location',
                  iconSize: 18,
                  fontSize: 14,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: JobInfoRow(
                        icon: Icons.calendar_today_outlined,
                        text: job.duration.isNotEmpty ? job.duration : l10n.naLabel,
                        iconSize: 16,
                        fontSize: 13,
                      ),
                    ),
                    Expanded(
                      child: JobInfoRow(
                        icon: Icons.payments_outlined,
                        text: job.stipend.isNotEmpty ? '₹${job.stipend}' : l10n.unpaidLabel,
                        iconSize: 16,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),
                const Divider(color: AppColors.dividerGrey),
                const SizedBox(height: 20),

                // ── Job Description ────────────────────────────────────────
                Text(
                  l10n.jobDescriptionLabel,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  job.description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 28),

                // ── Required Skills ────────────────────────────────────────
                if (job.requiredSkills.isNotEmpty) ...[
                  Text(
                    l10n.requiredSkillsLabel,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: job.requiredSkills.map((skill) {
                      return Chip(
                        label: Text(
                          skill,
                          style: const TextStyle(
                            color: AppColors.profileBlue,
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor: AppColors.workBg,
                        side: BorderSide.none,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],

                // ── Category ───────────────────────────────────────────────
                if (job.category.isNotEmpty)
                  JobInfoRow(
                    icon: Icons.category_outlined,
                    text: job.category,
                    iconSize: 16,
                    fontSize: 13,
                  ),
              ],
            ),
          ),

          // ── Fixed bottom action bar ───────────────────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: _BottomActionBar(job: job),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Action Bar ─────────────────────────────────────────────────────────
class _BottomActionBar extends StatelessWidget {
  final JobModel job;
  const _BottomActionBar({required this.job});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userRole = Provider.of<AuthProvider>(context).role;
    final bool isJobClosed = job.status == 'CLOSED';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.dividerGrey,
            blurRadius: 12,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: _buildButton(context, l10n, userRole, isJobClosed),
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    AppLocalizations l10n,
    String? userRole,
    bool isJobClosed,
  ) {
    if (isJobClosed) {
      return JobPrimaryButton(
        label: l10n.jobClosedBtn,
        onPressed: null,
        color: AppColors.textSecondary,
      );
    }

    if (userRole == 'ADMIN' || userRole == 'SUPER_ADMIN') {
      return JobPrimaryButton(
        label: l10n.viewApplicationsBtn,
        color: AppColors.appBarBlue,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => JobApplicationsScreen(jobId: job.id, jobTitle: job.title),
          ),
        ),
      );
    }

    if (userRole == 'FIELD' || userRole == 'COORDINATOR') {
      return JobPrimaryButton(
        label: l10n.notEligibleToApply,
        onPressed: null,
        color: AppColors.textSecondary,
      );
    }

    // Guest or Beneficiary
    return JobPrimaryButton(
      label: l10n.applyNowBtn,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ApplyJobScreen(jobId: job.id)),
        );
      },
    );
  }

  // _showLoginSheet removed since guests can now apply directly
}
