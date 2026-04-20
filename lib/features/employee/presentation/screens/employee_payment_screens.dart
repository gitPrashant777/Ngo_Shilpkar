import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shilpkar/core/api/api_client.dart';
import 'package:shilpkar/core/api/api_endpoints.dart';
import 'package:shilpkar/core/constants/app_colors.dart';

// ─── Employee Payment Request Screen (for FIELD employees) ────────────────────
class EmployeePaymentRequestScreen extends StatefulWidget {
  const EmployeePaymentRequestScreen({super.key});

  @override
  State<EmployeePaymentRequestScreen> createState() =>
      _EmployeePaymentRequestScreenState();
}

class _EmployeePaymentRequestScreenState
    extends State<EmployeePaymentRequestScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  bool _loading = false;
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _result = null; });
    try {
      final client = ApiClient();
      final res = await client.dio.post(
        ApiEndpoints.employeePaymentRequest,
        data: {
          'requestedAmount': double.parse(_amountCtrl.text.trim()),
          'reason':          _reasonCtrl.text.trim(),
        },
      );
      setState(() => _result = res.data['data']);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('✅ Payment request submitted!'),
          backgroundColor: Colors.green,
        ));
        _amountCtrl.clear();
        _reasonCtrl.clear();
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'Request failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ $msg'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  InputDecoration _deco(String label, String hint, IconData icon) => InputDecoration(
    labelText: label, hintText: hint,
    prefixIcon: Icon(icon, size: 20),
    filled: true, fillColor: Colors.grey.shade50,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.profileBlue)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF27AE60),
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Request Payment',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            Text('Submit expense reimbursement',
                style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _amountCtrl,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Amount required';
                        if (double.tryParse(v.trim()) == null) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                      decoration: _deco('Requested Amount (₹)',
                          'e.g. 500', Icons.currency_rupee),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _reasonCtrl,
                      maxLines: 3,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Reason required' : null,
                      decoration: _deco('Reason',
                          'e.g. Travel reimbursement, Field expenses',
                          Icons.notes_outlined),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : _submit,
                        icon: _loading
                            ? const SizedBox(
                                width: 18, height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.send_outlined),
                        label: Text(_loading ? 'Submitting...' : 'Submit Request'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF27AE60),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_result != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Request Submitted',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ]),
                      const SizedBox(height: 10),
                      Text('Status: ${_result!['status'] ?? 'PENDING'}'),
                      Text('Amount: ₹${_result!['requestedAmount']}'),
                      Text('Reason: ${_result!['reason']}'),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Admin: View & Approve/Reject Employee Payment Requests ───────────────────
// Lists all requests fetched from the API — no manual ID entry needed.
class AdminEmployeePaymentsScreen extends StatefulWidget {
  const AdminEmployeePaymentsScreen({super.key});

  @override
  State<AdminEmployeePaymentsScreen> createState() =>
      _AdminEmployeePaymentsScreenState();
}

class _AdminEmployeePaymentsScreenState
    extends State<AdminEmployeePaymentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _pending   = [];
  List<Map<String, dynamic>> _processed = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // GET /api/admin/employee-payments  → returns list of all requests
  Future<void> _fetchRequests() async {
    setState(() { _loading = true; _error = null; });
    try {
      final client = ApiClient();
      final res = await client.dio.get(ApiEndpoints.adminEmployeePayments);
      final rawData = res.data['data'];
      final all = (rawData is List ? rawData : (rawData != null ? [rawData] : []))
          .cast<Map<String, dynamic>>();
      setState(() {
        _pending   = all
            .where((r) => (r['status'] ?? '').toString().toUpperCase() == 'PENDING')
            .toList();
        _processed = all
            .where((r) => (r['status'] ?? '').toString().toUpperCase() != 'PENDING')
            .toList();
      });
    } on DioException catch (e) {
      setState(() =>
          _error = e.response?.data['message'] ?? 'Failed to load requests');
    } finally {
      setState(() => _loading = false);
    }
  }

  // Confirm dialog → POST /api/admin/employee-payments/pay
  Future<void> _processRequest(
      Map<String, dynamic> req, String status) async {
    final reasonCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Icon(
              status == 'APPROVED' ? Icons.thumb_up : Icons.thumb_down,
              color: status == 'APPROVED' ? Colors.green : Colors.red,
              size: 22),
          const SizedBox(width: 8),
          Text('${status == 'APPROVED' ? 'Approve' : 'Reject'} Request?'),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Employee: ${_empName(req)}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            Text('Amount: ₹${req['requestedAmount'] ?? req['amount'] ?? '-'}'),
            Text('Reason: ${req['reason'] ?? '-'}'),
            const SizedBox(height: 14),
            TextField(
              controller: reasonCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Admin Remarks (optional)',
                hintText: 'e.g. Approved after verification',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  status == 'APPROVED' ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(status == 'APPROVED' ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final client = ApiClient();
      await client.dio.post(
        ApiEndpoints.adminEmployeePaymentPay,
        data: {
          'requestId': req['_id'] ?? req['id'],
          'status':    status,
          'reason':    reasonCtrl.text.trim(),
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(status == 'APPROVED'
              ? '✅ Approved for ${_empName(req)}'
              : '❌ Request rejected'),
          backgroundColor:
              status == 'APPROVED' ? Colors.green : Colors.orange,
        ));
        _fetchRequests(); // auto-refresh
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'Action failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ $msg'), backgroundColor: Colors.red),
      );
    }
  }

  String _empName(Map<String, dynamic> r) {
    if (r['employeeName'] is String) return r['employeeName'];

    final emp = r['employee'] ?? r['employeeId'];
    if (emp is Map) {
      if (emp['name'] is String && emp['name'].toString().isNotEmpty) return emp['name'];
      if (emp['fullName'] is String && emp['fullName'].toString().isNotEmpty) return emp['fullName'];
    } else if (emp is String && emp.isNotEmpty) {
      return emp;
    }

    return 'Employee';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8E44AD),
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Employee Payment Requests',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('Review and process requests',
                style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh), onPressed: _fetchRequests),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'Pending (${_pending.length})'),
            Tab(text: 'Processed (${_processed.length})'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildList(_pending, isPending: true),
                    _buildList(_processed, isPending: false),
                  ],
                ),
    );
  }

  Widget _buildError() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded,
                  size: 56, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text(_error!,
                  style: TextStyle(color: Colors.grey.shade600),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchRequests,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8E44AD),
                    foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
      );

  Widget _buildList(List<Map<String, dynamic>> items,
      {required bool isPending}) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
                isPending ? Icons.check_circle_outline : Icons.history,
                size: 64,
                color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
                isPending
                    ? 'No pending requests 🎉'
                    : 'No processed requests yet',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchRequests,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (ctx, i) =>
            _buildRequestCard(items[i], isPending: isPending),
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> req,
      {required bool isPending}) {
    final name   = _empName(req);
    final amount = req['requestedAmount'] ?? req['amount'] ?? 0;
    final reason = req['reason'] ?? '-';
    final status = (req['status'] ?? '').toString().toUpperCase();
    final date   = req['createdAt'] ?? req['date'] ?? '';

    Color statusColor;
    IconData statusIcon;
    switch (status) {
      case 'APPROVED':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'REJECTED':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isPending ? Border.all(color: Colors.orange.shade200) : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)
        ],
      ),
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor:
                      const Color(0xFF8E44AD).withOpacity(0.12),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'E',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8E44AD)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      if (date.isNotEmpty)
                        Text(
                          date.toString().length > 10
                              ? date.toString().substring(0, 10)
                              : date.toString(),
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade500),
                        ),
                    ],
                  ),
                ),
                // Amount badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF27AE60).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '₹$amount',
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: Color(0xFF27AE60)),
                  ),
                ),
              ],
            ),
          ),

          // ── Reason ──────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.notes_outlined,
                    size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(reason,
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700))),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Actions ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: isPending
                ? Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _processRequest(req, 'REJECTED'),
                          icon: const Icon(Icons.close, size: 16),
                          label: const Text('Reject'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding:
                                const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _processRequest(req, 'APPROVED'),
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Approve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Icon(statusIcon, color: statusColor, size: 18),
                      const SizedBox(width: 8),
                      Text(status,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: statusColor)),
                      if (req['reviewedBy'] != null) ...[
                        const Spacer(),
                        Text('By: ${req['reviewedBy']}',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500)),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
