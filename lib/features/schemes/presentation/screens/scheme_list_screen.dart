import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/scheme_model.dart';
import '../../data/models/scheme_application_model.dart';
import '../providers/scheme_provider.dart';
import 'Superadmin_scheme_management_screen.dart';
import 'scheme_detail_screen.dart';
import 'my_scheme_applications_screen.dart';
import '../../../auth/presentation/screens/beneficiary_login_screen.dart';
import '../../../../l10n/app_localizations.dart';

class SchemeListScreen extends StatefulWidget {
  const SchemeListScreen({super.key});

  @override
  State<SchemeListScreen> createState() => _SchemeListScreenState();
}

class _SchemeListScreenState extends State<SchemeListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = context.read<SchemeProvider>();
        final role = context.read<AuthProvider>().role;
        provider.fetchPublishedSchemes(refresh: true);
        if (role == 'BENEFICIARY' || role == 'GUEST') {
          provider.fetchMyApplications();
        }
      }
    });
  }

  bool _isAdmin(String? role) => role == 'ADMIN' || role == 'SUPER_ADMIN';
  bool _isBeneficiary(String? role) => role == 'BENEFICIARY' || role == 'GUEST';

  void _openAddScheme() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SuperAdminSchemeManagementScreen(),
      ),
    ).then((_) {
      if (mounted)
        context.read<SchemeProvider>().fetchPublishedSchemes(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().role;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(role),
            Expanded(
              child: Consumer<SchemeProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading && provider.publishedSchemes.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.error != null &&
                      provider.publishedSchemes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade300,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            AppLocalizations.of(context)!.failedToLoadSchemes,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            provider.error!,
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => context
                                .read<SchemeProvider>()
                                .fetchPublishedSchemes(refresh: true),
                            icon: const Icon(Icons.refresh),
                            label: Text(AppLocalizations.of(context)!.retry),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.lightBlueScheme,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (provider.publishedSchemes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context)!.noSchemesAvailable,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 16,
                            ),
                          ),
                          if (_isAdmin(role)) ...[
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _openAddScheme,
                              icon: const Icon(Icons.add),
                              label: Text(
                                AppLocalizations.of(context)!.createFirstScheme,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.lightBlueScheme,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  // Build a quick lookup: schemeId → application
                  final Map<String, SchemeApplicationModel> appliedMap = {
                    for (final app in provider.myApplications)
                      if (app.schemeId.isNotEmpty && app.isActive && app.status.toUpperCase() != 'WITHDRAWN') 
                        app.schemeId: app,
                  };

                  return Column(
                    children: [
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            await provider.fetchPublishedSchemes(refresh: true);
                            if (_isBeneficiary(role))
                              await provider.fetchMyApplications();
                          },
                          child: ListView.builder(
                            // Add bottom padding so the last card isn't hidden by the pagination bar or FAB
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                            itemCount: provider.publishedSchemes.length,
                            itemBuilder: (context, index) {
                              return _buildSchemeCard(
                                provider.publishedSchemes[index],
                                role,
                                appliedMap,
                                provider,
                              );
                            },
                          ),
                        ),
                      ),

                      // ── Pagination bar ─────────────────────────────────────
                      _PaginationBar(
                        currentPage: provider.publishedCurrentPage,
                        totalPages: provider.publishedTotalPages,
                        total: provider.publishedTotal,
                        isLoading: provider.isLoading,
                        onPageChanged: (p) => provider.goToPublishedPage(p),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String? role) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shilpkar Foundation',
            style: TextStyle(
              fontSize: 20,
              color: Color(0xFF3B71CA),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Schemes',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  if (_isAdmin(role))
                    TextButton(
                      onPressed: _openAddScheme,
                      child: const Text(
                        '+ Add Scheme',
                        style: TextStyle(
                          color: Color(0xFF3B71CA),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  if (_isBeneficiary(role))
                    Consumer<SchemeProvider>(
                      builder: (_, prov, __) {
                        final count = prov.myApplications.length;
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const MySchemeApplicationsScreen(),
                            ),
                          ).then((_) => prov.fetchMyApplications()),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              color: AppColors.lightBlueScheme.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.lightBlueScheme.withValues(
                                  alpha: 0.4,
                                ),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.checklist_rounded,
                                  size: 14,
                                  color: AppColors.lightBlueScheme,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  count > 0
                                      ? AppLocalizations.of(
                                          context,
                                        )!.myApplicationsCount(count)
                                      : AppLocalizations.of(
                                          context,
                                        )!.myApplications,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.lightBlueScheme,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  Consumer<SchemeProvider>(
                    builder: (_, prov, __) => prov.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : IconButton(
                            icon: const Icon(
                              Icons.refresh,
                              color: AppColors.lightBlueScheme,
                              size: 20,
                            ),
                            onPressed: () {
                              prov.fetchPublishedSchemes(refresh: true);
                              if (_isBeneficiary(role))
                                prov.fetchMyApplications();
                            },
                          ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSchemeCard(
    SchemeModel scheme,
    String? role,
    Map<String, SchemeApplicationModel> appliedMap,
    SchemeProvider provider,
  ) {
    final bool isPaid = scheme.price > 0;
    final SchemeApplicationModel? myApp = appliedMap[scheme.id];
    final bool isApplied = myApp != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${scheme.name} — ${isPaid ? '₹${scheme.price.toInt()}' : 'Free'}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              scheme.description,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 13,
                height: 1.3,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_isBeneficiary(role)) ...[
                  if (isApplied)
                    _WithdrawButton(
                      onWithdraw: () =>
                          _withdraw(myApp!.id, myApp.schemeId, provider),
                    )
                  else
                    ElevatedButton(
                      onPressed: () => _apply(scheme.id, provider, role),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightBlueScheme,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        elevation: 0,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.apply,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ] else ...[
                  const SizedBox.shrink(),
                ],
                ElevatedButton(
                  onPressed: () {
                    if (_isAdmin(role)) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const SuperAdminSchemeManagementScreen(),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SchemeDetailScreen(scheme: scheme),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightBlueScheme,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    elevation: 0,
                  ),
                  child: const Text(
                    "View Scheme",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _apply(
    String schemeId,
    SchemeProvider provider,
    String? role,
  ) async {
    // Guest/unauthenticated users: show login prompt
    if (role == null || role == 'GUEST' || role.isEmpty) {
      _showLoginPrompt();
      return;
    }
    final appId = await provider.applyForScheme(schemeId);
    final ok = appId != null;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? AppLocalizations.of(context)!.appliedSuccessfully
                : '\u274c ${provider.error}',
          ),
          backgroundColor: ok ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _showLoginPrompt() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              size: 48,
              color: AppColors.lightBlueScheme,
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.loginRequired,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.loginRequiredDesc,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BeneficiaryLoginScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.login, color: Colors.white, size: 16),
                label: Text(
                  AppLocalizations.of(context)!.loginAsBeneficiaryBtn,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightBlueScheme,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _withdraw(
    String applicationId,
    String schemeId,
    SchemeProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.withdrawApplicationQ),
        content: Text(AppLocalizations.of(context)!.areYouSureWithdrawScheme),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              AppLocalizations.of(context)!.withdraw,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final ok = await provider.withdrawApplication(
      applicationId,
      schemeId: schemeId,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? AppLocalizations.of(context)!.applicationWithdrawn
                : '\u274c ${provider.error}',
          ),
          backgroundColor: ok ? Colors.orange : Colors.red,
        ),
      );
    }
  }

  Widget _buildChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

// ─── Withdraw Button (animated red outline) ───────────────────────────────────
class _WithdrawButton extends StatelessWidget {
  final VoidCallback onWithdraw;
  const _WithdrawButton({required this.onWithdraw});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onWithdraw,
      icon: const Icon(Icons.undo_rounded, size: 15, color: Colors.red),
      label: Text(
        AppLocalizations.of(context)!.withdraw,
        style: const TextStyle(fontSize: 12, color: Colors.red),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.red),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}

// ─── Pagination Bar ──────────────────────────────────────────────────────────
class _PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int total;
  final bool isLoading;
  final void Function(int page) onPageChanged;

  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.total,
    required this.isLoading,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1 && total == 0) return const SizedBox.shrink();

    final bool hasPrev = currentPage > 1;
    final bool hasNext = currentPage < totalPages;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Page number chips (if ≤ 7 pages)
          if (totalPages > 1 && totalPages <= 7)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(totalPages, (i) {
                  final page = i + 1;
                  final isActive = page == currentPage;
                  return GestureDetector(
                    onTap: isLoading || isActive
                        ? null
                        : () => onPageChanged(page),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: isActive ? 34 : 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.lightBlueScheme
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isActive
                              ? AppColors.lightBlueScheme
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$page',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isActive
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isActive ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

          // Prev / Page info / Next row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Prev button
              _NavBtn(
                label: '← Prev',
                enabled: hasPrev && !isLoading,
                onTap: () => onPageChanged(currentPage - 1),
              ),

              // Centre info
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLoading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Text(
                      'Page $currentPage of $totalPages',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  if (total > 0)
                    Text(
                      '$total scheme${total == 1 ? '' : 's'} total',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                ],
              ),

              // Next button
              _NavBtn(
                label: 'Next →',
                enabled: hasNext && !isLoading,
                onTap: () => onPageChanged(currentPage + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _NavBtn({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: enabled ? AppColors.lightBlueScheme : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: enabled ? AppColors.lightBlueScheme : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: enabled ? Colors.white : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}
