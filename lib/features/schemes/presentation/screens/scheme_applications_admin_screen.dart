import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/scheme_application_model.dart';
import '../providers/scheme_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// Admin screen to view and approve/reject applications for a specific scheme.
class SchemeApplicationsAdminScreen extends StatefulWidget {
  final String schemeId;
  final String schemeName;

  const SchemeApplicationsAdminScreen({
    super.key,
    required this.schemeId,
    required this.schemeName,
  });

  @override
  State<SchemeApplicationsAdminScreen> createState() =>
      _SchemeApplicationsAdminScreenState();
}

class _SchemeApplicationsAdminScreenState
    extends State<SchemeApplicationsAdminScreen> {
  String _filter = 'ALL';
  final List<String> _filters = ['ALL', 'PAYMENT_PENDING', 'PENDING', 'APPROVED', 'REJECTED', 'UNDER_REVIEW'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final provider = context.read<SchemeProvider>();
    await provider.fetchAdminApplications(
      widget.schemeId,
      refresh: true,
      statusFilter: _filter == 'ALL' ? '' : _filter,
    );
  }

  // ─── Approve with optional remarks ─────────────────────────────────────────
  void _showActionDialog(SchemeApplicationModel app, String action) {
    final remarksCtrl = TextEditingController();
    final isApprove = action == 'APPROVE';
    final isActivate = action == 'ACTIVATE';
    final isComplete = action == 'COMPLETE';

    String title;
    if (isApprove) {
      title = 'Approve Application';
    } else if (isActivate) {
      title = 'Activate Application';
    } else if (isComplete) {
      title = 'Complete Application';
    } else {
      title = 'Reject Application';
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Perform "$action" for "${app.beneficiaryName.isNotEmpty ? app.beneficiaryName : "applicant"}"?',
              style: const TextStyle(fontSize: 14),
            ),
            if (isApprove || action == 'REJECT') ...[
              const SizedBox(height: 12),
              TextField(
                controller: remarksCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Remarks (optional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = context.read<SchemeProvider>();
              bool ok;
              if (isApprove) {
                ok = await provider.approveApplication(app.id, remarks: remarksCtrl.text.trim());
              } else if (isActivate) {
                ok = await provider.activateApplication(app.id);
              } else if (isComplete) {
                ok = await provider.completeApplication(app.id);
              } else {
                ok = await provider.rejectApplication(app.id, remarks: remarksCtrl.text.trim());
              }

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok
                      ? '✅ Success: $action'
                      : '❌ ${provider.error}'),
                  backgroundColor: ok ? Colors.green : Colors.red,
                ));
                if (ok) _load(); // Refresh list
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: action == 'REJECT' ? Colors.red : Colors.green,
            ),
            child: Text(
              action,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showPayoutDialog(SchemeApplicationModel app) {
    final amountCtrl = TextEditingController();
    final monthCtrl = TextEditingController(text: '1');
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Manual Payout'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount (₹)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: monthCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Month Number'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountCtrl.text) ?? 0;
              final month = int.tryParse(monthCtrl.text) ?? 1;
              if (amount <= 0) return;
              
              Navigator.pop(ctx);
              final provider = context.read<SchemeProvider>();
              final ok = await provider.triggerManualPayout(app.id, amount, month);
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok ? '✅ Payout logged' : '❌ ${provider.error}'),
                  backgroundColor: ok ? Colors.blue : Colors.red,
                ));
              }
            },
            child: const Text('Submit Payout'),
          ),
        ],
      ),
    );
  }

  void _showPaymentDetailsDialog(SchemeApplicationModel app) async {
    final provider = context.read<SchemeProvider>();
    await provider.fetchApplicationPayments(app.id);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateBuilder) {
            return AlertDialog(
              title: const Text('Payment Details'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Payment Status: ${app.paymentStatus}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    if (provider.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (provider.applicationPayments.isEmpty)
                      const Text("No payments found for this application.")
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: provider.applicationPayments.length,
                        itemBuilder: (context, index) {
                          final p = provider.applicationPayments[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text("ID: ${p['paymentId'] ?? p['_id'] ?? 'N/A'}"),
                            subtitle: Text("Status: ${p['status'] ?? 'N/A'}\nAmount: ₹${p['amount'] ?? 0}"),
                            isThreeLine: true,
                          );
                        },
                      ),
                  ],
                ),
              ),
              actions: [
                if (app.paymentStatus != 'SUCCESS')
                  TextButton(
                    onPressed: () async {
                      final ok = await provider.markPaymentSuccess(app.id, "manual_txn_${DateTime.now().millisecondsSinceEpoch}");
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(ok ? '✅ Triggered Manual Success' : '❌ ${provider.error}'),
                          backgroundColor: ok ? Colors.green : Colors.red,
                        ));
                        if (ok) {
                          Navigator.pop(ctx);
                          _load();
                        }
                      }
                    },
                    child: const Text('Force Payment Success', style: TextStyle(color: Colors.orange)),
                  ),
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightBlueScheme,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Scheme Applications',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            Text(widget.schemeName,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w300),
                overflow: TextOverflow.ellipsis),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          )
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((f) {
                  final isSelected = _filter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(f,
                          style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600)),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() => _filter = f);
                        _load();
                      },
                      backgroundColor: Colors.grey.shade100,
                      selectedColor: AppColors.lightBlueScheme,
                      checkmarkColor: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Applications list
          Expanded(
            child: Consumer<SchemeProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.adminApplications.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.adminApplications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text('No applications found',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey.shade500)),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.adminApplications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, index) =>
                        _buildCard(provider.adminApplications[index]),
                  ),
                );
              },
            ),
          ),
          // Pagination Bar
          Consumer<SchemeProvider>(
            builder: (context, provider, _) => _ApplicationsPaginationBar(
              currentPage: provider.adminAppsCurrentPage,
              totalPages: provider.adminAppsTotalPages,
              isLoading: provider.isLoading,
              onPageChanged: (p) => provider.goToAdminAppsPage(widget.schemeId, p),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(SchemeApplicationModel app) {
    final statusColor = _statusColor(app.status);
    final isPending = ['PENDING', 'UNDER_REVIEW', 'WAIVER_PENDING', ''].contains(app.status.toUpperCase());

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)
        ],
        border: Border(left: BorderSide(color: statusColor, width: 4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Applicant icon
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person_outline, color: statusColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.beneficiaryName.isNotEmpty
                            ? app.beneficiaryName
                            : 'Anonymous Applicant',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      if (app.category.isNotEmpty)
                        Text(app.category,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                // Status chip
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    app.status.isNotEmpty ? app.status : 'PENDING',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.payment, size: 14, color: app.paymentStatus.toUpperCase() == 'SUCCESS' ? Colors.green : Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      app.paymentStatus,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: app.paymentStatus.toUpperCase() == 'SUCCESS' ? Colors.green : Colors.orange),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => _showPaymentDetailsDialog(app),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  child: const Text('View Payment', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 12, color: Colors.grey.shade400),
                const SizedBox(width: 5),
                Text(
                  'Applied ${_formatDate(app.createdAt)}',
                  style:
                      TextStyle(fontSize: 12, color: Colors.grey.shade400),
                ),
              ],
            ),
            // Approve / Reject buttons — only when pending
            if (isPending) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showActionDialog(app, 'REJECT'),
                      icon: const Icon(Icons.close_rounded, size: 16, color: Colors.red),
                      label: const Text('Reject',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showActionDialog(app, 'APPROVE'),
                      icon: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                      label: const Text('Approve',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            // Activate button — only when approved
            if (app.status.toUpperCase() == 'APPROVED' || app.status.toUpperCase() == 'ACCEPTED') ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showActionDialog(app, 'ACTIVATE'),
                  icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                  label: const Text('Activate Application', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
            // Payout / Complete — only when active
            if (app.status.toUpperCase() == 'ACTIVE') ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showPayoutDialog(app),
                      icon: const Icon(Icons.currency_rupee, size: 16),
                      label: const Text('Payout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showActionDialog(app, 'COMPLETE'),
                      icon: const Icon(Icons.task_alt, size: 16),
                      label: const Text('Complete'),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
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

class _ApplicationsPaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final bool isLoading;
  final Function(int) onPageChanged;

  const _ApplicationsPaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.isLoading,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox(height: 20);

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
            onPressed: (currentPage > 1 && !isLoading) ? () => onPageChanged(currentPage - 1) : null,
            icon: Icon(Icons.chevron_left, color: (currentPage > 1) ? AppColors.lightBlueScheme : Colors.grey),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${AppLocalizations.of(context)!.page} $currentPage ${AppLocalizations.of(context)!.ofText} $totalPages",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          IconButton(
            onPressed: (currentPage < totalPages && !isLoading) ? () => onPageChanged(currentPage + 1) : null,
            icon: Icon(Icons.chevron_right, color: (currentPage < totalPages) ? AppColors.lightBlueScheme : Colors.grey),
          ),
        ],
      ),
    );
  }
}
