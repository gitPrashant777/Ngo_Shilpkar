import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shilpkar/core/api/api_client.dart';
import 'package:shilpkar/core/api/api_endpoints.dart';
import 'package:shilpkar/core/constants/app_colors.dart';

/// Admin / Super Admin — record a manual (cash) payment for a beneficiary.
/// User is selected from a live API-powered search picker (uses real _id).
class ManualPaymentScreen extends StatefulWidget {
  const ManualPaymentScreen({super.key});

  @override
  State<ManualPaymentScreen> createState() => _ManualPaymentScreenState();
}

class _ManualPaymentScreenState extends State<ManualPaymentScreen> {
  // ── User picker state ──────────────────────────────────────────────────────
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loadingUsers = false;
  Map<String, dynamic>? _selectedUser;
  final _searchCtrl = TextEditingController();

  // ── Form state ─────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();
  bool _loading = false;
  Map<String, dynamic>? _receipt;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _amountCtrl.dispose();
    _remarksCtrl.dispose();
    super.dispose();
  }

  // Load all three user types in parallel so the picker is comprehensive
  Future<void> _loadUsers() async {
    setState(() => _loadingUsers = true);
    try {
      final client = ApiClient();
      final results = await Future.wait([
        client.dio.get(ApiEndpoints.usersBeneficiaries, queryParameters: {'limit': 100}),
        client.dio.get(ApiEndpoints.usersEmployees,    queryParameters: {'limit': 100}),
        client.dio.get(ApiEndpoints.usersCoordinators, queryParameters: {'limit': 100}),
      ]);
      final all = <Map<String, dynamic>>[];
      for (final res in results) {
        final data = res.data['data'];
        if (data is List) {
          all.addAll(data.cast<Map<String, dynamic>>());
        }
      }
      setState(() {
        _users = all;
        _filtered = all;
      });
    } catch (_) {
      // Non-fatal — user can still try
    } finally {
      setState(() => _loadingUsers = false);
    }
  }

  void _onSearch() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _users
          : _users.where((u) {
              final name  = (u['name'] ?? u['fullName'] ?? '').toString().toLowerCase();
              final phone = (u['phone'] ?? u['mobileNumber'] ?? '').toString();
              final role  = (u['role'] ?? '').toString().toLowerCase();
              return name.contains(q) || phone.contains(q) || role.contains(q);
            }).toList();
    });
  }

  // ── Show bottom-sheet user picker ──────────────────────────────────────────
  void _showUserPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.92,
        builder: (_, scrollCtrl) => Column(
          children: [
            // Handle bar
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select User', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _searchCtrl,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search by name, phone, or role...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
            if (_loadingUsers)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_filtered.isEmpty)
              Expanded(
                child: Center(
                  child: Text(_users.isEmpty ? 'No users found' : 'No match for "${_searchCtrl.text}"',
                      style: TextStyle(color: Colors.grey.shade500)),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx2, i) {
                    final u = _filtered[i];
                    final id    = u['_id'] ?? u['id'] ?? '';
                    final name  = u['name'] ?? u['fullName'] ?? 'Unknown';
                    final phone = u['phone'] ?? u['mobileNumber'] ?? '-';
                    final role  = u['role'] ?? '-';

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedUser = u;
                          _receipt = null; // clear old receipt when user changes
                        });
                        Navigator.pop(ctx);
                        _searchCtrl.clear();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: _roleColor(role).withOpacity(0.15),
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : '?',
                                style: TextStyle(fontWeight: FontWeight.bold, color: _roleColor(role)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                  Text('📞 $phone', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                  Text('ID: $id', style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _roleColor(role).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(role, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _roleColor(role))),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role.toUpperCase()) {
      case 'BENEFICIARY': return const Color(0xFF1E5799);
      case 'FIELD':
      case 'EMPLOYEE':    return const Color(0xFF27AE60);
      case 'COORDINATOR': return const Color(0xFF8E44AD);
      default:            return Colors.grey.shade600;
    }
  }

  // ── Submit payment ─────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (_selectedUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Please select a user first'), backgroundColor: Colors.orange),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() { _loading = true; _receipt = null; });
    try {
      final client = ApiClient();
      // Use the real MongoDB _id — never a human-readable string
      final userId = _selectedUser!['_id'] ?? _selectedUser!['id'];
      final res = await client.dio.post(
        ApiEndpoints.manualPayment,
        data: {
          'userId':  userId,
          'amount':  double.parse(_amountCtrl.text.trim()),
          'remarks': _remarksCtrl.text.trim(),
        },
      );
      setState(() => _receipt = res.data['data']);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('✅ Payment recorded successfully!'),
          backgroundColor: Colors.green,
        ));
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'Request failed';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('❌ $msg'),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selName  = _selectedUser?['name'] ?? _selectedUser?['fullName'];
    final selPhone = _selectedUser?['phone'] ?? _selectedUser?['mobileNumber'];
    final selRole  = _selectedUser?['role'] ?? '';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: AppColors.profileBlue,
          foregroundColor: Colors.white,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Manual Payment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              Text('Record cash transaction', style: TextStyle(fontSize: 11, color: Colors.white70)),
            ],
          ),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Record'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRecordTab(selName, selPhone, selRole),
            _buildHistoryTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordTab(String? selName, String? selPhone, String selRole) {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ── User Selector ─────────────────────────────────────────────
              GestureDetector(
                onTap: _showUserPicker,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _selectedUser != null ? AppColors.profileBlue : Colors.grey.shade200,
                      width: _selectedUser != null ? 1.5 : 1,
                    ),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: _selectedUser != null
                              ? _roleColor(selRole).withOpacity(0.12)
                              : Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _selectedUser != null ? Icons.person : Icons.person_search_outlined,
                          color: _selectedUser != null ? _roleColor(selRole) : Colors.grey,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _selectedUser == null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Select User', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                  Text('Tap to search beneficiaries, employees…',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(selName ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  Text('📞 ${selPhone ?? '-'}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _roleColor(selRole).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(selRole,
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _roleColor(selRole))),
                                  ),
                                ],
                              ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: _selectedUser != null ? AppColors.profileBlue : Colors.grey.shade400,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Payment Details Form ──────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Payment Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountCtrl,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Amount required';
                        final n = double.tryParse(v.trim());
                        if (n == null || n <= 0) return 'Enter a valid amount';
                        return null;
                      },
                      decoration: _deco('Amount (₹)', 'e.g. 1000', Icons.currency_rupee),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _remarksCtrl,
                      maxLines: 2,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Remarks required' : null,
                      decoration: _deco('Remarks', 'e.g. Cash in hand, Collected at camp', Icons.notes_outlined),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : _submit,
                        icon: _loading
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.check_circle_outline),
                        label: Text(_loading ? 'Recording...' : 'Record Payment'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.profileBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Receipt card (success) ────────────────────────────────────
              if (_receipt != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.receipt_long, color: Colors.green, size: 22),
                        const SizedBox(width: 8),
                        const Text('Payment Receipt', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)),
                          child: const Text('SUCCESS', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ]),
                      const Divider(height: 24),
                      _receiptRow('Paid for', selName ?? '-'),
                      _receiptRow('Method',   _receipt!['method'] ?? 'CASH'),
                      _receiptRow('Source',   _receipt!['source'] ?? 'MANUAL_ENTRY'),
                      _receiptRow('Amount',   '₹${_receipt!['amount']}'),
                      _receiptRow('Tx Key',   _receipt!['idempotencyKey'] ?? '-'),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
  }

  Widget _buildHistoryTab() {
    return FutureBuilder<Response>(
      future: ApiClient().dio.get('/transactions/history?source=MANUAL_ENTRY').catchError((_) {
        // Fallback to general payments list if specific manual route doesn't support GET
        return ApiClient().dio.get('/payments'); 
      }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Failed to load history', style: TextStyle(color: Colors.red.shade400)));
        }
        
        final data = snapshot.data?.data['data'];
        final records = (data is List) ? data.cast<Map<String, dynamic>>() : [];
        // Optional: filter out non-manual records if frontend needs to
        final manualRecords = records.where((r) => r['source'] == 'MANUAL_ENTRY' || r['method'] == 'CASH').toList();

        if (manualRecords.isEmpty) {
          return const Center(child: Text('No manual payments recorded yet', style: TextStyle(color: Colors.grey)));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: manualRecords.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (ctx, i) {
            final r = manualRecords[i];
            final amount = r['amount']?.toString() ?? '0';
            final remarks = r['remarks'] ?? '-';
            final status = r['paymentStatus'] ?? r['status'] ?? 'SUCCESS';
            
            // Try to extract user details
            final dynamic u = r['user'] ?? r['buyerId'] ?? r['beneficiaryId'] ?? r['userId'];
            final userMap = u is Map ? u : null;
            
            final fName = userMap?['firstName'] ?? userMap?['name'] ?? userMap?['fullName'] ?? '';
            final lName = userMap?['lastName'] ?? '';
            String uName = "$fName $lName".trim();
            if (uName.isEmpty) uName = 'Unknown User';
            
            final enteredBy = r['enteredByAdmin'] ?? r['recordedBy'];
            final adminName = (enteredBy is Map) 
                ? (enteredBy['name'] ?? enteredBy['firstName'] ?? enteredBy['username'] ?? 'Admin')
                : '';

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 6)], // withOpacity->withAlpha fix
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: Colors.green.shade50,
                  child: const Icon(Icons.currency_rupee, color: Colors.green),
                ),
                title: Text(uName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Remarks: $remarks', style: const TextStyle(fontSize: 12)),
                    if (adminName.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text('Recorded by: $adminName', style: const TextStyle(fontSize: 11, color: Colors.blueAccent, fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('₹$amount', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green)),
                    Text(status, style: TextStyle(fontSize: 10, color: status == 'SUCCESS' ? Colors.green : Colors.grey)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _deco(String label, String hint, IconData icon) => InputDecoration(
    labelText: label, hintText: hint,
    prefixIcon: Icon(icon, size: 20),
    filled: true, fillColor: Colors.grey.shade50,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.profileBlue)),
  );

  Widget _receiptRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Text('$label: ', style: const TextStyle(color: Colors.black54, fontSize: 13)),
      Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
    ]),
  );
}
