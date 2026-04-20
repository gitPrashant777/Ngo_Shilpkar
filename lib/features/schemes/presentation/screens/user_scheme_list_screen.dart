import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/scheme_provider.dart';
import '../../data/models/scheme_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'my_scheme_applications_screen.dart';
import '../../../../l10n/app_localizations.dart';

class UserSchemeListScreen extends StatefulWidget {
  const UserSchemeListScreen({super.key});

  @override
  State<UserSchemeListScreen> createState() => _UserSchemeListScreenState();
}

class _UserSchemeListScreenState extends State<UserSchemeListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final cat = auth.userProfile?.profile.category;
      Provider.of<SchemeProvider>(context, listen: false).fetchPublishedSchemes(refresh: true, category: cat);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.governmentSchemes, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: [
            Tab(text: AppLocalizations.of(context)!.availableSchemes),
            Tab(text: AppLocalizations.of(context)!.myApplicationsTab),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAvailableSchemes(),
          const MySchemeApplicationsScreen(),
        ],
      ),
    );
  }

  Widget _buildAvailableSchemes() {
    return Consumer<SchemeProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.publishedSchemes.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null && provider.publishedSchemes.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade300, size: 48),
                  const SizedBox(height: 16),
                  Text(AppLocalizations.of(context)!.failedToLoadSchemesError(provider.error ?? ''), textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final auth = Provider.of<AuthProvider>(context, listen: false);
                      provider.fetchPublishedSchemes(category: auth.userProfile?.profile.category);
                    },
                    child: Text(AppLocalizations.of(context)!.retry),
                  ),
                ],
              ),
            ),
          );
        }

        if (provider.publishedSchemes.isEmpty) {
          return Center(
            child: Text(AppLocalizations.of(context)!.noSchemesAvailableAtMoment, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          );
        }

        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  final auth = Provider.of<AuthProvider>(context, listen: false);
                  await provider.fetchPublishedSchemes(refresh: true, category: auth.userProfile?.profile.category);
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.publishedSchemes.length,
                  itemBuilder: (context, index) {
                    final scheme = provider.publishedSchemes[index];
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
                            Row(
                              children: [
                                Expanded(
                                  child: Text(scheme.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: scheme.schemeType == 'FREE' ? Colors.green.shade50 : Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
                                  child: Text(
                                    scheme.schemeType == 'FREE' ? AppLocalizations.of(context)!.free : "₹${scheme.price.toStringAsFixed(0)}",
                                    style: TextStyle(color: scheme.schemeType == 'FREE' ? Colors.green.shade700 : Colors.blue.shade700, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(scheme.description, style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.3)),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () => _showApplyDialog(context, scheme, provider),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3B71CA),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text("View Scheme", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Pagination bar
            _UserSchemesPaginationBar(
              currentPage: provider.publishedCurrentPage,
              totalPages: provider.publishedTotalPages,
              total: provider.publishedTotal,
              isLoading: provider.isLoading,
              onPageChanged: (p) => provider.goToPublishedPage(p),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildTag(IconData icon, String label, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.shade50, borderRadius: BorderRadius.circular(6), border: Border.all(color: color.shade100)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color.shade700),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: color.shade800, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showApplyDialog(BuildContext context, SchemeModel scheme, SchemeProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(AppLocalizations.of(context)!.applyScheme, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text("${AppLocalizations.of(context)!.schemeTermsPrompt(scheme.name)}${scheme.schemeType == 'PAID' ? AppLocalizations.of(context)!.schemeTermsPaidNote(scheme.price.toStringAsFixed(0)) : ''}"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppLocalizations.of(context)!.cancelBtn)),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final appId = await provider.applyForScheme(scheme.id);
              if (context.mounted) {
                if (appId != null) {
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(scheme.schemeType == 'PAID' ? AppLocalizations.of(context)!.appliedPleasePay : AppLocalizations.of(context)!.appliedSuccessfully), backgroundColor: Colors.green));
                   _tabController.animateTo(1); // Switch to My Applications Tab automatically!
                } else {
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.error ?? AppLocalizations.of(context)!.failedToApply), backgroundColor: Colors.red));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            child: Text(AppLocalizations.of(context)!.confirmApplicationBtn, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─── Pagination Bar ──────────────────────────────────────────────────────────
class _UserSchemesPaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int total;
  final bool isLoading;
  final void Function(int page) onPageChanged;

  const _UserSchemesPaginationBar({
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: hasPrev && !isLoading ? () => onPageChanged(currentPage - 1) : null,
            icon: Icon(Icons.chevron_left, color: hasPrev ? AppColors.primaryBlue : Colors.grey),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${AppLocalizations.of(context)!.page} $currentPage ${AppLocalizations.of(context)!.ofText} $totalPages",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              if (total > 0)
                Text(
                  "$total ${AppLocalizations.of(context)!.totalSchemes}",
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
            ],
          ),
          IconButton(
            onPressed: hasNext && !isLoading ? () => onPageChanged(currentPage + 1) : null,
            icon: Icon(Icons.chevron_right, color: hasNext ? AppColors.primaryBlue : Colors.grey),
          ),
        ],
      ),
    );
  }
}
