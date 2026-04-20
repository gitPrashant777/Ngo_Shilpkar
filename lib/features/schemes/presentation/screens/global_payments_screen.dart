import 'package:flutter/material.dart';
import '../../../../core/api/api_client.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_colors.dart';

class GlobalPaymentsScreen extends StatefulWidget {
  const GlobalPaymentsScreen({super.key});

  @override
  State<GlobalPaymentsScreen> createState() => _GlobalPaymentsScreenState();
}

class _GlobalPaymentsScreenState extends State<GlobalPaymentsScreen> {
  bool _isLoading = true;
  String? _error;
  List<dynamic> _payments = [];

  @override
  void initState() {
    super.initState();
    _fetchPayments();
  }

  Future<void> _fetchPayments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final dio = ApiClient().dio;
      final response = await dio.get('/payments');
      
      final data = response.data['data'] ?? response.data;
      if (mounted) {
        setState(() {
          _payments = data is List ? data : [];
        });
      }
    } on DioException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.response?.data?['message'] ?? e.message ?? "Failed to fetch payments";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Global Payment History'),
        backgroundColor: AppColors.lightBlueScheme,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchPayments,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              "Error loading payments:\n$_error",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchPayments,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('No payment history found',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _payments.length,
      itemBuilder: (context, index) {
        final payment = _payments[index];
        final isSuccess = payment['status']?.toString().toUpperCase() == 'SUCCESS';

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: isSuccess ? Colors.green.shade100 : Colors.orange.shade100,
              child: Icon(
                isSuccess ? Icons.check : Icons.pending_actions,
                color: isSuccess ? Colors.green : Colors.orange,
              ),
            ),
            title: Text(
              '₹${payment['amount']?.toString() ?? '0'}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Order ID: ${payment['orderId'] ?? 'N/A'}'),
                if (payment['paymentId'] != null) Text('Payment ID: ${payment['paymentId']}'),
                Text('Status: ${payment['status'] ?? 'UNKNOWN'}'),
              ],
            ),
            trailing: Text(
              payment['currency'] ?? 'INR',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
        );
      },
    );
  }
}
