import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../jobs/presentation/providers/job_provider.dart';
import '../../../jobs/data/models/user_job_application_model.dart';
import '../../../schemes/presentation/providers/scheme_provider.dart';
import '../../../schemes/data/models/scheme_application_model.dart';

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  static const _kBlue = Color(0xFF4A78B0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JobProvider>(context, listen: false).fetchMyApplications();
      Provider.of<SchemeProvider>(context, listen: false).fetchMyApplications();
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
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        backgroundColor: _kBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Applications',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            Text('Track your job & scheme applications',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w300)),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: [
            // Job tab with count badge
            Consumer<JobProvider>(
              builder: (_, p, __) => Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.work_outline, size: 16),
                    const SizedBox(width: 6),
                    const Text('Jobs'),
                    if (p.myApplications.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      _Badge(count: p.myApplications.length),
                    ],
                  ],
                ),
              ),
            ),
            // Scheme tab with count badge
            Consumer<SchemeProvider>(
              builder: (_, p, __) => Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.assignment_outlined, size: 16),
                    const SizedBox(width: 6),
                    const Text('Schemes'),
                    if (p.myApplications.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      _Badge(count: p.myApplications.length),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildJobTab(),
          _buildSchemeTab(),
        ],
      ),
    );
  }

  // ─── JOB APPLICATIONS TAB ──────────────────────────────────────────────────
  Widget _buildJobTab() {
    return Consumer<JobProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.myApplications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.myApplications.isEmpty) {
          return _EmptyState(
            icon: Icons.work_off_outlined,
            message: 'No job applications yet',
            sub: 'Apply for a job to see your applications here',
          );
        }
        return RefreshIndicator(
          onRefresh: () => provider.fetchMyApplications(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.myApplications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, index) =>
                _buildJobCard(provider.myApplications[index]),
          ),
        );
      },
    );
  }

  Widget _buildJobCard(UserJobApplicationModel app) {
    final color = _jobStatusColor(app.status);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(app.jobTitle.isNotEmpty ? app.jobTitle : 'Unnamed Job',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(
                        '${app.organization}${app.jobCity.isNotEmpty ? " \u2022 ${app.jobCity}" : ""}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _StatusChip(status: app.status, color: color),
              ],
            ),
            const SizedBox(height: 8),
            _JobStatusNote(status: app.status),
          ],
        ),
      ),
    );
  }

  // ─── SCHEME APPLICATIONS TAB ───────────────────────────────────────────────
  Widget _buildSchemeTab() {
    return Consumer<SchemeProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.myApplications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.myApplications.isEmpty) {
          return _EmptyState(
            icon: Icons.assignment_late_outlined,
            message: 'No scheme applications yet',
            sub: 'Apply for a scheme to see your applications here',
          );
        }
        return RefreshIndicator(
          onRefresh: () => provider.fetchMyApplications(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.myApplications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, index) =>
                _buildSchemeCard(provider.myApplications[index], provider),
          ),
        );
      },
    );
  }

  Widget _buildSchemeCard(SchemeApplicationModel app, SchemeProvider provider) {
    final color = _schemeStatusColor(app.status);
    final canWithdraw = _canWithdraw(app.status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    app.schemeName.isNotEmpty ? app.schemeName : 'Unnamed Scheme',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                const SizedBox(width: 8),
                _StatusChip(status: app.status, color: color),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text(_formatDate(app.createdAt),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
              ],
            ),
            const SizedBox(height: 4),
            _SchemeStatusNote(status: app.status),
            if (canWithdraw) ...[
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _withdrawScheme(app, provider),
                  icon: const Icon(Icons.undo_rounded, size: 14, color: Colors.red),
                  label: const Text('Withdraw',
                      style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _withdrawScheme(SchemeApplicationModel app, SchemeProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Withdraw Application?'),
        content: Text('Withdraw from "${app.schemeName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Withdraw', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final ok = await provider.withdrawApplication(app.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? '✅ Application withdrawn' : '❌ ${provider.error}'),
        backgroundColor: ok ? Colors.orange : Colors.red,
      ));
    }
  }

  bool _canWithdraw(String status) {
    final s = status.toUpperCase();
    return s == 'PENDING' || s == 'SUBMITTED' || s == '' || s == 'UNDER_REVIEW';
  }

  Color _jobStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACCEPTED': return Colors.green;
      case 'REJECTED': return Colors.red;
      case 'REVIEWED': return Colors.blue;
      default: return Colors.orange;
    }
  }

  Color _schemeStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED': case 'ACCEPTED': return Colors.green;
      case 'REJECTED': return Colors.red;
      case 'UNDER_REVIEW': case 'REVIEWED': return Colors.blue;
      case 'DISBURSED': return Colors.purple;
      default: return Colors.orange;
    }
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
}

// ─── Shared Widgets ──────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final String status;
  final Color color;
  const _StatusChip({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    final label = status.isNotEmpty ? status : 'PENDING';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
    );
  }
}

class _Badge extends StatelessWidget {
  final int count;
  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
      child: Text('$count', style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String sub;
  const _EmptyState({required this.icon, required this.message, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(message,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
          const SizedBox(height: 6),
          Text(sub,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _JobStatusNote extends StatelessWidget {
  final String status;
  const _JobStatusNote({required this.status});

  @override
  Widget build(BuildContext context) {
    String note; IconData icon; Color color;
    switch (status.toUpperCase()) {
      case 'ACCEPTED':
        note = 'Congratulations! You have been selected.'; icon = Icons.check_circle_outline; color = Colors.green; break;
      case 'REJECTED':
        note = 'Your application was not selected this time.'; icon = Icons.cancel_outlined; color = Colors.red; break;
      case 'REVIEWED':
        note = 'Your application has been reviewed by the team.'; icon = Icons.find_in_page_outlined; color = Colors.blue; break;
      default:
        note = 'Waiting for review by the hiring team.'; icon = Icons.hourglass_empty_rounded; color = Colors.orange;
    }
    return Row(
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 5),
        Expanded(child: Text(note, style: TextStyle(fontSize: 11, color: color, fontStyle: FontStyle.italic))),
      ],
    );
  }
}

class _SchemeStatusNote extends StatelessWidget {
  final String status;
  const _SchemeStatusNote({required this.status});

  @override
  Widget build(BuildContext context) {
    String note; IconData icon; Color color;
    switch (status.toUpperCase()) {
      case 'APPROVED': case 'ACCEPTED':
        note = 'Congratulations! Your application has been approved.'; icon = Icons.check_circle_outline; color = Colors.green; break;
      case 'REJECTED':
        note = 'Unfortunately, your application was not approved.'; icon = Icons.cancel_outlined; color = Colors.red; break;
      case 'UNDER_REVIEW': case 'REVIEWED':
        note = 'Your application is currently under review.'; icon = Icons.find_in_page_outlined; color = Colors.blue; break;
      case 'DISBURSED':
        note = 'Benefits have been disbursed to you.'; icon = Icons.account_balance_wallet_outlined; color = Colors.purple; break;
      default:
        note = 'Your application is waiting for review.'; icon = Icons.hourglass_empty_rounded; color = Colors.orange;
    }
    return Row(
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 5),
        Expanded(child: Text(note, style: TextStyle(fontSize: 11, color: color, fontStyle: FontStyle.italic))),
      ],
    );
  }
}
