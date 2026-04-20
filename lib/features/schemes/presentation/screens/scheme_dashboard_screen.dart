import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/scheme_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

class SchemeDashboardScreen extends StatefulWidget {
  final String schemeId;
  final String schemeName;

  const SchemeDashboardScreen({
    super.key,
    required this.schemeId,
    required this.schemeName,
  });

  @override
  State<SchemeDashboardScreen> createState() => _SchemeDashboardScreenState();
}

class _SchemeDashboardScreenState extends State<SchemeDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SchemeProvider>().fetchDashboardStats(widget.schemeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightBlueScheme,
        foregroundColor: Colors.white,
        title: Text(AppLocalizations.of(context)!.schemeStats(widget.schemeName)),
        elevation: 0,
      ),
      body: Consumer<SchemeProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.dashboardSummary == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = provider.dashboardSummary ?? {};
          
          return RefreshIndicator(
            onRefresh: () => provider.fetchDashboardStats(widget.schemeId),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSummaryGrid(stats, context),
                const SizedBox(height: 24),
                _buildPayoutCard(stats, context),
                const SizedBox(height: 24),
                Text(
                  AppLocalizations.of(context)!.recentUnpaidApplications,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (provider.unpaidApplications.isEmpty)
                  Center(child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(AppLocalizations.of(context)!.noPendingPayouts),
                  ))
                else
                  ...provider.unpaidApplications.map((app) => _buildUnpaidTile(app, context)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryGrid(Map<String, dynamic> stats, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(l10n.totalApps, stats['totalApplications']?.toString() ?? '0', Icons.assignment, Colors.blue),
        _buildStatCard(l10n.paymentsLabel, stats['paymentSuccess']?.toString() ?? '0', Icons.check_circle, Colors.green),
        _buildStatCard(l10n.active, stats['active']?.toString() ?? '0', Icons.play_circle_fill, Colors.orange),
        _buildStatCard(l10n.completed, stats['completed']?.toString() ?? '0', Icons.verified, Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Icon(icon, color: color, size: 20),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildPayoutCard(Map<String, dynamic> stats, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.lightBlueScheme, AppColors.lightBlueScheme.withValues(alpha: 0.8)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(l10n.totalPayoutsDisbursed, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            '₹${stats['totalPayoutAmount']?.toString() ?? '0'}',
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(l10n.transactions(stats['totalPayouts'] ?? 0), style: const TextStyle(color: Colors.white60, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildUnpaidTile(dynamic app, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(app.beneficiaryName),
        subtitle: Text(AppLocalizations.of(context)!.statusLabel(app.status)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
        },
      ),
    );
  }
}
