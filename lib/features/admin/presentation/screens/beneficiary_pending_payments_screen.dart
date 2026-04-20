import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shilpkar/core/api/api_client.dart';
import 'package:shilpkar/core/api/api_endpoints.dart';
import 'package:shilpkar/core/constants/app_colors.dart';

/// Admin / Super Admin — list all beneficiaries with pending/unpaid payments.
class BeneficiaryPendingPaymentsScreen extends StatefulWidget {
  const BeneficiaryPendingPaymentsScreen({super.key});

  @override
  State<BeneficiaryPendingPaymentsScreen> createState() =>
      _BeneficiaryPendingPaymentsScreenState();
}

class _BeneficiaryPendingPaymentsScreenState
    extends State<BeneficiaryPendingPaymentsScreen> {
  List<dynamic> _items = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() { _loading = true; _error = null; });
    try {
      final client = ApiClient();
      final res = await client.dio.get(ApiEndpoints.beneficiaryPendingPayments);
      setState(() => _items = res.data['data'] ?? []);
    } on DioException catch (e) {
      setState(() => _error = e.response?.data['message'] ?? 'Failed to fetch');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pending Payments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            Text('Beneficiaries with unpaid status', style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetch),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.wifi_off_rounded, size: 56, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text(_error!, style: TextStyle(color: Colors.grey.shade600)),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _fetch, child: const Text('Retry')),
                    ],
                  ),
                )
              : _items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_outline, size: 64, color: Colors.green.shade300),
                          const SizedBox(height: 12),
                          const Text('All payments are up to date! 🎉',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetch,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (ctx, i) => _buildCard(_items[i]),
                      ),
                    ),
    );
  }

  Widget _buildCard(Map<String, dynamic> b) {
    final name = b['name'] ?? b['fullName'] ?? 'Unknown';
    final phone = b['phone'] ?? b['mobileNumber'] ?? '-';
    final id = b['_id'] ?? b['id'] ?? '-';
    final isActive = b['isActive'] ?? true;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_outline, color: Colors.red.shade400, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text('📞 $phone', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(height: 2),
                Text('ID: $id', style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: const Text('UNPAID', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
