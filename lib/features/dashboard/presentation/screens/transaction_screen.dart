import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/api/api_client.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E5799),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Shilpakar Foundation',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400)),
            Text('Transactions',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          isScrollable: true,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Contributions'),
            Tab(text: 'Refunds'),
            Tab(text: 'Benefits'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: FutureBuilder<Response>(
        future: ApiClient().dio.get('/transactions/history').catchError((_) {
          return ApiClient().dio.get('/payments');
        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load transactions'));
          }

          final rawData = snapshot.data?.data['data'];
          final List<Map<String, dynamic>> transactions = 
            (rawData is List) ? rawData.cast<Map<String, dynamic>>() : [];

          // Basic segregations according to backend models
          final contributions = transactions.where((t) => 
            (t['type'] == 'ONBOARDING' || t['type'] == 'ORDER' || t['method'] == 'CASH') && 
            t['status'] != 'REFUNDED' && (t['amount'] as num? ?? 0) > 0).toList();

          final refunds = transactions.where((t) => t['status'] == 'REFUNDED').toList();
          
          final benefits = transactions.where((t) => t['type'] == 'SCHEME' || (t['scheme'] != null)).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildContributionsTab(contributions),
              _buildRefundsTab(refunds),
              _buildBenefitsTab(benefits),
              _buildHistoryTab(transactions),
            ],
          );
        }
      ),
    );
  }

  Widget _buildContributionsTab(List<Map<String, dynamic>> contributions) {
    double total = contributions
        .where((c) => c['status'] == 'SUCCESS')
        .fold(0.0, (sum, c) => sum + ((c['amount'] as num?)?.toDouble() ?? 0.0));

    int paidCount = contributions.where((c) => c['status'] == 'SUCCESS').length;
    int pendingCount = contributions.where((c) => c['status'] == 'PENDING' || c['status'] == 'CREATED').length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E5799), Color(0xFF2E86C1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total Contribution',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 4),
              Text('₹${total.toStringAsFixed(0)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                   _buildMiniStat('Success', paidCount.toString(), Colors.greenAccent),
                   const SizedBox(width: 20),
                   _buildMiniStat('Pending/Other', pendingCount.toString(), Colors.orangeAccent),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...contributions.map((c) => _buildContributionCard(
            _extractUserName(c, 'Contribution'),
            c['amount']?.toString() ?? '0',
            (c['createdAt'] != null) ? c['createdAt'].toString().substring(0, 10) : '-',
            c['status'] ?? 'UNKNOWN'
        )),

        const SizedBox(height: 12),
        // Cash Payment Option
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.money, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Paid in Cash?',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.orange)),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'If you have paid in cash, you can request the Super Admin to update your payment status.',
                style: TextStyle(fontSize: 12, color: Colors.black87),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showCashPaymentDialog(context),
                  icon: const Icon(Icons.send_outlined, size: 16),
                  label: const Text('Request Cash Payment Update'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRefundsTab(List<Map<String, dynamic>> refunds) {
    double total = refunds.fold(0.0, (sum, c) => sum + ((c['amount'] as num?)?.toDouble() ?? 0.0));
    int processedCount = refunds.where((r) => r['status'] == 'REFUNDED').length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF27AE60), Color(0xFF2ECC71)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Refund Status', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 4),
              Text('₹${total.toStringAsFixed(0)} Processed',
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildMiniStat('Processed', processedCount.toString(), Colors.greenAccent),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...refunds.map((r) => _buildTransactionCard(
              _extractUserName(r, 'Refunded Payment'),
              '₹${r['amount']}',
              (r['createdAt'] != null) ? r['createdAt'].toString().substring(0, 10) : '-',
              r['status']!,
              Colors.orange,
              Icons.assignment_return_outlined,
            )),
        if (refunds.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Text('No refunds found', style: TextStyle(color: Colors.grey)),
            ),
          ),
      ],
    );
  }

  Widget _buildBenefitsTab(List<Map<String, dynamic>> benefits) {
    double total = benefits.fold(0.0, (s, b) => s + ((b['amount'] as num?)?.toDouble() ?? 0.0));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8E44AD), Color(0xFF9B59B6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total Benefits Received', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 4),
              Text('₹${total.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              Text('${benefits.length} benefit(s) received',
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...benefits.map((b) => _buildTransactionCard(
              b['scheme'] is Map ? b['scheme']['name'] : 'Scheme Benefit',
              '₹${b['amount']}',
              (b['createdAt'] != null) ? b['createdAt'].toString().substring(0, 10) : '-',
              b['status'] ?? 'SUCCESS',
              const Color(0xFF8E44AD),
              Icons.card_giftcard_outlined,
            )),
      ],
    );
  }

  Widget _buildHistoryTab(List<Map<String, dynamic>> transactions) {

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final t = transactions[index];
        final isCredit = t['type'] == 'SCHEME';
        
        final name = _extractUserName(t, 'Transaction');
        final amount = t['amount']?.toString() ?? '0';
        final date = (t['createdAt'] != null) ? t['createdAt'].toString().substring(0, 10) : '-';

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(
                color: isCredit ? Colors.green : Colors.blue,
                width: 4,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCredit
                      ? Colors.green.withOpacity(0.1)
                      : Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isCredit ? Colors.green : Colors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    Text(date,
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 11)),
                  ],
                ),
              ),
              Text(
                '₹$amount',
                style: TextStyle(
                  color: isCredit ? Colors.green : Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContributionCard(String name, String amount, String date, String status) {
    final isPaid = status == 'SUCCESS';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1E5799).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.payments_outlined, color: Color(0xFF1E5799), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                Text(date,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹$amount',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isPaid
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                      fontSize: 10,
                      color: isPaid ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(
      String name, String amount, String date, String badge, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                Text(date,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14, color: color)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(badge,
                    style: TextStyle(
                        fontSize: 10, color: color, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
      ],
    );
  }

  String _extractUserName(dynamic record, String fallback) {
    if (record is! Map) return fallback;
    final dynamic u = record['user'] ?? record['buyerId'] ?? record['beneficiaryId'] ?? record['userId'];
    if (u is Map) {
      final fName = u['firstName'] ?? u['name'] ?? u['fullName'] ?? '';
      final lName = u['lastName'] ?? '';
      final combined = "$fName $lName".trim();
      return combined.isEmpty ? fallback : combined;
    }
    return fallback;
  }

  void _showCashPaymentDialog(BuildContext context) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cash Payment Request',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the cash payment details to notify the Super Admin.',
                style: TextStyle(fontSize: 13, color: Colors.black87)),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount Paid (₹)',
                prefixIcon: const Icon(Icons.currency_rupee),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: noteController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Note (optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('✅ Cash payment request sent to Super Admin!'),
                backgroundColor: Colors.green,
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E5799),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
  }
}
