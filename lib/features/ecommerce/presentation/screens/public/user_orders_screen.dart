import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../data/models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../widgets/ecommerce_widgets.dart';
import 'order_detail_screen.dart';
import 'refund_request_screen.dart';
import 'replace_item_screen.dart';

class UserOrdersScreen extends StatefulWidget {
  const UserOrdersScreen({super.key});

  @override
  State<UserOrdersScreen> createState() => _UserOrdersScreenState();
}

class _UserOrdersScreenState extends State<UserOrdersScreen> {
  // ─── Status filter ────────────────────────────────────────────────────────
  String _selectedFilter = 'ALL';
  final List<String> _filters = [
    'ALL', 'CONFIRMED', 'DELIVERED', 'REFUND_REQUESTED', 'REFUNDED',
    'REPLACED', 'CANCELLED',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchMyOrders();
    });
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
  Color _statusColor(String s) {
    switch (s) {
      case 'PENDING':          return Colors.orange;
      case 'CONFIRMED':        return const Color(0xFF1565C0);
      case 'SHIPPED':          return Colors.cyan.shade700;
      case 'DELIVERED':        return Colors.green.shade700;
      case 'REFUND_REQUESTED': return Colors.deepOrange;
      case 'REFUNDED':         return Colors.purple;
      case 'REPLACED':         return Colors.teal;
      case 'CANCELLED':        return Colors.red.shade700;
      default:                 return Colors.grey;
    }
  }

  IconData _statusIcon(String s) {
    switch (s) {
      case 'CONFIRMED':        return Icons.check_circle_outline;
      case 'SHIPPED':          return Icons.local_shipping_outlined;
      case 'DELIVERED':        return Icons.home_outlined;
      case 'REFUND_REQUESTED': return Icons.assignment_return_outlined;
      case 'REFUNDED':         return Icons.currency_rupee;
      case 'REPLACED':         return Icons.swap_horiz;
      case 'CANCELLED':        return Icons.cancel_outlined;
      default:                 return Icons.hourglass_empty;
    }
  }

  // ─── Return/refund eligibility ────────────────────────────────────────────
  bool _canRequestReturn(OrderModel o) {
    if (o.status != 'DELIVERED') return false;
    if (o.deliveredAt == null && o.refundExpiryAt == null) return true;
    if (o.refundExpiryAt != null) {
      return DateTime.now().isBefore(o.refundExpiryAt!);
    }
    if (o.deliveredAt != null) {
      return DateTime.now().difference(o.deliveredAt!).inDays <= 7;
    }
    return false;
  }

  int _daysLeft(OrderModel o) {
    if (o.refundExpiryAt != null) {
      return o.refundExpiryAt!.difference(DateTime.now()).inDays;
    }
    if (o.deliveredAt != null) {
      return 7 - DateTime.now().difference(o.deliveredAt!).inDays;
    }
    return 0;
  }

  // ─── UI ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('My Orders', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.appBarBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<OrderProvider>().fetchMyOrders(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: Consumer<OrderProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.myOrders.isEmpty) {
                  return const Center(child: CircularProgressIndicator.adaptive());
                }
                if (provider.error != null && provider.myOrders.isEmpty) {
                  return _buildError(provider);
                }

                final orders = _selectedFilter == 'ALL'
                    ? provider.myOrders
                    : provider.myOrders.where((o) => o.status == _selectedFilter).toList();

                if (orders.isEmpty) {
                  return _buildEmpty();
                }

                return RefreshIndicator(
                  onRefresh: () => provider.fetchMyOrders(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                    itemCount: orders.length,
                    itemBuilder: (_, i) => _buildOrderCard(orders[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: _filters.map((f) {
          final isSelected = _selectedFilter == f;
          final color = f == 'ALL' ? AppColors.appBarBlue : _statusColor(f);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(f == 'ALL' ? 'All Orders' : f.replaceAll('_', ' ')),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedFilter = f),
              selectedColor: color.withOpacity(0.15),
              labelStyle: TextStyle(
                color: isSelected ? color : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              side: BorderSide(color: isSelected ? color : Colors.grey.shade300),
              backgroundColor: Colors.white,
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final statusColor = _statusColor(order.status);
    final canReturn  = _canRequestReturn(order);
    final daysLeft   = canReturn ? _daysLeft(order) : 0;
    final isReplacement = order.isReplacement;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OrderDetailScreen(order: order),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
        children: [
          // ── Top color bar ─────────────────────────────────────────────
          Container(height: 4, color: statusColor),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Header row ──────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Order #${order.id.substring(order.id.length - 8).toUpperCase()}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.blueGrey,
                                ),
                              ),
                              if (isReplacement) ...[
                                const SizedBox(width: 6),
                                _miniChip('🔄 Replacement', Colors.teal),
                              ],
                            ],
                          ),
                          if (order.createdAt != null)
                            Text(
                              DateFormat('dd MMM yyyy • hh:mm a').format(order.createdAt!),
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                            ),
                        ],
                      ),
                    ),
                    _statusBadge(order.status, statusColor),
                  ],
                ),

                const SizedBox(height: 14),

                // ── Product info ─────────────────────────────────────────
                Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: order.productImage != null && order.productImage!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: order.productImage!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Icon(_statusIcon(order.status), color: statusColor, size: 26),
                                errorWidget: (context, url, err) => Icon(_statusIcon(order.status), color: statusColor, size: 26),
                              )
                            : order.productId.isNotEmpty
                                ? AsyncProductImage(
                                    productId: order.productId,
                                    fit: BoxFit.cover,
                                  )
                                : Icon(_statusIcon(order.status), color: statusColor, size: 26),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          order.productName != null
                              ? Text(
                                  order.productName!,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : AsyncProductName(
                                  productId: order.productId,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                          Text(
                            'Qty: ${order.quantity}',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₹${order.totalAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: AppColors.appBarBlue,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Payment status row ───────────────────────────────────
                Row(
                  children: [
                    Icon(Icons.payment, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      'Payment: ',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    _paymentBadge(order.paymentStatus),
                  ],
                ),

                // ── Replacement of ───────────────────────────────────────
                if (isReplacement && order.replacementOf != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.link, size: 14, color: Colors.teal.shade400),
                      const SizedBox(width: 4),
                      Text(
                        'Replaces order: #${order.replacementOf!.substring(order.replacementOf!.length.clamp(8, order.replacementOf!.length) - 8).toUpperCase()}',
                        style: TextStyle(fontSize: 11, color: Colors.teal.shade600),
                      ),
                    ],
                  ),
                ],

                // ── DELIVERED: refund countdown ──────────────────────────
                if (order.status == 'DELIVERED' && order.deliveredAt != null) ...[
                  const SizedBox(height: 10),
                  if (canReturn)
                    _infoTile(
                      icon: Icons.timer_outlined,
                      color: daysLeft <= 2 ? Colors.red : Colors.green.shade700,
                      text: 'Return window: $daysLeft day${daysLeft == 1 ? "" : "s"} remaining',
                    )
                  else
                    _infoTile(
                      icon: Icons.timer_off_outlined,
                      color: Colors.grey,
                      text: 'Return window expired',
                    ),
                ],

                // ── REFUNDED note ────────────────────────────────────────
                if (order.status == 'REFUNDED') ...[
                  const SizedBox(height: 10),
                  _infoTile(
                    icon: Icons.check_circle_outline,
                    color: Colors.purple,
                    text: 'Refund processed. Check your bank account within 5–7 business days.',
                  ),
                ],

                // ── REPLACED note ────────────────────────────────────────
                if (order.status == 'REPLACED') ...[
                  const SizedBox(height: 10),
                  _infoTile(
                    icon: Icons.swap_horiz,
                    color: Colors.teal,
                    text: 'Replacement order has been created and confirmed.',
                  ),
                ],

                // ── REFUND_REQUESTED note ────────────────────────────────
                if (order.status == 'REFUND_REQUESTED') ...[
                  const SizedBox(height: 10),
                  _infoTile(
                    icon: Icons.hourglass_top_outlined,
                    color: Colors.deepOrange,
                    text: 'Return/refund request submitted. Admin will review shortly.',
                  ),
                ],

                // ── Actions ──────────────────────────────────────────────
                if (canReturn) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showReturnDialog(order),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red.shade700,
                        elevation: 0,
                        side: BorderSide(color: Colors.red.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.assignment_return_outlined, size: 18),
                      label: const Text('Request Return / Refund', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],


              ],
            ),
          ),
        ],
      ),
     ),
    );
  }

  Widget _statusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _paymentBadge(String status) {
    final color = status == 'PAID'
        ? Colors.green
        : status == 'REFUNDED'
            ? Colors.purple
            : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(status, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _miniChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _infoTile({required IconData icon, required Color color, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == 'ALL' ? 'No orders yet' : 'No ${_selectedFilter.replaceAll("_", " ")} orders',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text('Your orders will appear here', style: TextStyle(color: Colors.grey.shade400)),
        ],
      ),
    );
  }

  Widget _buildError(OrderProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 12),
          Text(provider.error ?? 'Unknown error'),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: provider.fetchMyOrders, child: const Text('Retry')),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // DIALOGS
  // ────────────────────────────────────────────────────────────────────────────

  void _showReturnDialog(OrderModel order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('What would you like to do?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red.shade700,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RefundRequestScreen(order: order)),
                      );
                    },
                    icon: const Icon(Icons.currency_rupee, size: 20),
                    label: const Text('Refund', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade50,
                      foregroundColor: Colors.blue.shade700,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ReplaceItemScreen(order: order)),
                      );
                    },
                    icon: const Icon(Icons.swap_horiz, size: 20),
                    label: const Text('Replace', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }




}
