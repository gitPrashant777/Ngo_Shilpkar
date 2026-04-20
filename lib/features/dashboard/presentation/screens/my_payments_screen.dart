import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_colors.dart';

class MyPaymentsScreen extends StatefulWidget {
  const MyPaymentsScreen({super.key});

  @override
  State<MyPaymentsScreen> createState() => _MyPaymentsScreenState();
}

class _MyPaymentsScreenState extends State<MyPaymentsScreen> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _payments = [];

  @override
  void initState() {
    super.initState();
    _fetchMyPayments();
  }

  Future<void> _fetchMyPayments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiClient().dio.get('/payments/my-payments');
      
      if (response.data['success'] == true) {
        final rawData = response.data['data'];
        if (rawData is List) {
          setState(() {
            _payments = rawData.cast<Map<String, dynamic>>();
          });
        }
      } else {
        setState(() {
          _error = response.data['message'] ?? 'Failed to load payments.';
        });
      }
    } on DioException catch (e) {
        setState(() {
          _error = 'Network error: ${e.response?.data['message'] ?? e.message}';
        });
    } catch (e) {
      setState(() {
        _error = 'An unexpected error occurred: $e';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text('My Payments'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                      const SizedBox(height: 16),
                      Text(_error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchMyPayments,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _payments.isEmpty
                  ? const Center(
                      child: Text('No payments found.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchMyPayments,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _payments.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final payment = _payments[index];
                          return _buildPaymentCard(payment);
                        },
                      ),
                    ),
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> payment) {
    final double amount = (payment['amount'] as num?)?.toDouble() ?? 0.0;
    final String status = payment['status']?.toString() ?? 'PENDING';
    final String method = payment['method']?.toString().toUpperCase() ?? 'UNKNOWN';
    final String type = payment['type']?.toString() ?? 'PAYMENT';
    final String source = payment['source']?.toString() ?? '';
    final String dateStr = payment['createdAt']?.toString() ?? '';
    
    // Formatting date
    String formattedDate = '';
    if (dateStr.isNotEmpty) {
      try {
        final date = DateTime.parse(dateStr).toLocal();
        formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(date);
      } catch (_) {
        formattedDate = dateStr.substring(0, 10);
      }
    }

    // Determine color based on status
    Color statusColor = Colors.orange;
    IconData statusIcon = Icons.hourglass_top;
    if (status == 'SUCCESS') {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (status == 'FAILED' || status == 'REFUNDED') {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
    }

    // Checking if it's a manual entry
    bool isManual = source == 'MANUAL_ENTRY' || method == 'CASH';
    String adminName = '';
    if (isManual && payment['recordedBy'] is Map) {
      adminName = payment['recordedBy']['name'] ?? payment['recordedBy']['firstName'] ?? '';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10), // Replaced deprecated withOpacity
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                   Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withAlpha(20), // Replaced deprecated withOpacity
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isManual ? Icons.money : Icons.account_balance_wallet,
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          formattedDate,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                ],
              ),
              Text(
                '₹${amount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Payment Method', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(method, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      if (isManual) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.withAlpha(30),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('MANUAL', style: TextStyle(color: Colors.blue, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      ]
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Status', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(statusIcon, color: statusColor, size: 14),
                      const SizedBox(width: 4),
                      Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          if (isManual && adminName.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha(20),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.orange.withAlpha(50)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.support_agent, size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Payment received by Admin: $adminName',
                      style: const TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            )
          ]
        ],
      ),
    );
  }
}
