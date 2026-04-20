import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../data/models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../../../../../l10n/app_localizations.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).fetchMyOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.myOrders)),
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.myOrders.isEmpty) {
            return Center(child: Text(AppLocalizations.of(context)!.noOrdersYetCustomer));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.myOrders.length,
            itemBuilder: (context, index) {
              final order = provider.myOrders[index];
              return _buildOrderCard(order);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    bool canRequestRefund = false;

    if (order.status == 'DELIVERED') {
      // Use backend-provided expiry first (most accurate)
      if (order.refundExpiryAt != null) {
        canRequestRefund = DateTime.now().isBefore(order.refundExpiryAt!);
      } else if (order.deliveredAt != null) {
        final difference = DateTime.now().difference(order.deliveredAt!).inDays;
        if (difference <= 7) {
          canRequestRefund = true;
        }
      }
    }

    // Check if refund or replacement already requested
    if (order.status == 'REFUNDED' || order.status == 'REPLACED' || order.status == 'REFUND_REQUESTED' || order.status == 'CANCELLED') {
       canRequestRefund = false;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Order ID: ${order.id.substring(order.id.length - 8).toUpperCase()}", 
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                _buildStatusBadge(order.status),
              ],
            ),
            const SizedBox(height: 12),
            Text(order.productName ?? "Product ID: ${order.productId}", 
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text("Quantity: ${order.quantity}", style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Amount: ₹${order.totalAmount}", 
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4373AD))),
                if (order.createdAt != null)
                  Text(DateFormat('MMM dd, yyyy').format(order.createdAt!), 
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.paymentStatus, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(order.paymentStatus, style: TextStyle(
                      color: order.paymentStatus == 'PAID' ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                    )),
                  ],
                ),

                if (canRequestRefund)
                  ElevatedButton(
                    onPressed: () => _showRefundDialog(order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      elevation: 0,
                    ),
                    child: Text(AppLocalizations.of(context)!.requestRefund),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'DELIVERED': color = Colors.green; break;
      case 'CONFIRMED': color = Colors.blue; break;
      case 'REFUNDED': color = Colors.purple; break;
      case 'CANCELLED': color = Colors.red; break;
      case 'PENDING': color = Colors.orange; break;
      default: color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  void _showRefundDialog(OrderModel order) {
    final reasonController = TextEditingController();
    String type = "REFUND";

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.requestReturnRefund),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: type,
                isExpanded: true,
                items: [
                  DropdownMenuItem(value: "REFUND", child: Text(AppLocalizations.of(context)!.refund)),
                  DropdownMenuItem(value: "REPLACEMENT", child: Text(AppLocalizations.of(context)!.replacement)),
                ],
                onChanged: (v) => setDialogState(() => type = v!),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.reasonForReturn,
                    border: const OutlineInputBorder(),
                  ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                if (reasonController.text.isEmpty) return;
                Navigator.pop(ctx);
                try {
                  await Provider.of<OrderProvider>(context, listen: false)
                      .createReturnRequest(order.id, type, reasonController.text);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)!.returnRequestSubmitted)),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  }
                }
              },
              child: Text(AppLocalizations.of(context)!.submit),
            ),
          ],
        ),
      ),
    );
  }


}
