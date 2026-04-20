import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../providers/order_provider.dart';

class AdminOrderManagementScreen extends StatefulWidget {
  final bool embedded;
  const AdminOrderManagementScreen({super.key, this.embedded = false});

  @override
  State<AdminOrderManagementScreen> createState() => _AdminOrderManagementScreenState();
}

class _AdminOrderManagementScreenState extends State<AdminOrderManagementScreen> {
  String _selectedFilter = 'ALL';

  final List<String> _filters = [
    'ALL', 'PENDING', 'CONFIRMED', 'SHIPPED', 'DELIVERED',
    'REFUND_REQUESTED', 'REFUNDED', 'REPLACED', 'CANCELLED',
  ];

  // All valid next-state options an admin can set
  final List<String> _statusOptions = [
    'PENDING', 'CONFIRMED', 'SHIPPED', 'DELIVERED',
    'REFUND_REQUESTED', 'REFUNDED', 'REPLACED', 'CANCELLED',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchAllOrders();
    });
  }

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

  // ─── Status Update Bottom Sheet ───────────────────────────────────────────
  void _showStatusSheet(String orderId, String currentStatus) {
    String selected = currentStatus;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(height: 16),
              Text(AppLocalizations.of(context)!.updateOrderStatus,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                'Order #${orderId.substring(orderId.length - 8).toUpperCase()}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 12),
              ..._statusOptions.map((status) {
                final color = _statusColor(status);
                final isSelected = selected == status;
                return RadioListTile<String>(
                  title: Text(
                    status.replaceAll('_', ' '),
                    style: TextStyle(color: color, fontWeight: FontWeight.w600),
                  ),
                  secondary: Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  value: status,
                  groupValue: selected,
                  activeColor: color,
                  dense: true,
                  onChanged: (v) => setModalState(() => selected = v!),
                );
              }),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appBarBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    if (selected != currentStatus) {
                      _applyStatusUpdate(orderId, selected);
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.applyChanges, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _applyStatusUpdate(String orderId, String newStatus) async {
    try {
      final result = await context.read<OrderProvider>().updateOrderStatus(orderId, newStatus);
      if (!mounted) return;

      // If DELIVERED, show extra info about refund window
      if (newStatus == 'DELIVERED') {
        final deliveredAt  = result['deliveredAt'];
        final refundExpiry = result['refundExpiryAt'];
        _showDeliveryConfirmation(deliveredAt, refundExpiry);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order moved to ${newStatus.replaceAll("_", " ")} ✓'),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showDeliveryConfirmation(String? deliveredAt, String? refundExpiryAt) {
    DateTime? delivered;
    DateTime? expiry;
    try { delivered = deliveredAt != null ? DateTime.parse(deliveredAt) : null; } catch (_) {}
    try { expiry = refundExpiryAt != null ? DateTime.parse(refundExpiryAt) : null; } catch (_) {}

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Icon(Icons.home_outlined, color: Colors.green.shade700),
          const SizedBox(width: 8),
          Text(AppLocalizations.of(context)!.markedAsDelivered),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (delivered != null)
              _detailRow(AppLocalizations.of(context)!.deliveredAt, DateFormat('dd MMM yyyy • hh:mm a').format(delivered.toLocal())),
            if (expiry != null) ...[
              const SizedBox(height: 8),
              _detailRow(AppLocalizations.of(context)!.refundWindowExpires, DateFormat('dd MMM yyyy').format(expiry.toLocal())),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.customerCanRequestRefund,
                      style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
                    ),
                  ),
                ]),
              ),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
            child: Text(AppLocalizations.of(context)!.gotIt),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
      ],
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final body = Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: Consumer<OrderProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.allOrders.isEmpty) {
                  return const Center(child: CircularProgressIndicator.adaptive());
                }
                if (provider.error != null && provider.allOrders.isEmpty) {
                  return _buildError(provider);
                }

                final orders = _selectedFilter == 'ALL'
                    ? provider.allOrders
                    : provider.allOrders.where((o) => o.status == _selectedFilter).toList();

                if (orders.isEmpty) {
                  return Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        _selectedFilter == 'ALL' ? AppLocalizations.of(context)!.noOrdersYet : 'No ${_selectedFilter.replaceAll("_", " ")} orders',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                      ),
                    ]),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.fetchAllOrders(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 80),
                    itemCount: orders.length,
                    itemBuilder: (_, i) {
                      final order     = orders[i];
                      final statusColor = _statusColor(order.status);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              // Color side-bar
                              Container(
                                width: 6,
                                color: statusColor,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            '#${order.id.substring(order.id.length - 6).toUpperCase()}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
                                          ),
                                          const Spacer(),
                                          _statusChip(order.status, statusColor),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        order.productName ?? 'Product ID: ${order.productId}',
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                        maxLines: 2, overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'Qty: ${order.quantity}  •  ₹${order.totalAmount.toStringAsFixed(0)}',
                                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(children: [
                                        Icon(Icons.location_on_outlined, size: 13, color: Colors.grey.shade500),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            '${order.address.street}, ${order.address.city}',
                                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600, overflow: TextOverflow.ellipsis),
                                          ),
                                        ),
                                        if (order.createdAt != null)
                                          Text(
                                            DateFormat('MMM d, h:mm a').format(order.createdAt!),
                                            style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                                          ),
                                      ]),
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        width: double.infinity,
                                        child: TextButton.icon(
                                          onPressed: () => _showStatusSheet(order.id, order.status),
                                          style: TextButton.styleFrom(
                                            backgroundColor: statusColor.withOpacity(0.08),
                                            foregroundColor: statusColor,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          icon: const Icon(Icons.edit_note, size: 18),
                                          label: Text(AppLocalizations.of(context)!.manageStatus, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      );

    if (widget.embedded) {
      return Container(
        color: const Color(0xFFF0F4F8),
        child: body,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.orderManagement,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.appBarBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<OrderProvider>().fetchAllOrders(),
          ),
        ],
      ),
      body: body,
    );
  }

  Widget _buildFilterBar() {
    return Container(
      color: Colors.white,
      height: 52,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: _filters.map((f) {
          final isSelected = _selectedFilter == f;
          final color = f == 'ALL' ? AppColors.appBarBlue : _statusColor(f);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(f == 'ALL' ? 'All' : f.replaceAll('_', ' ')),
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

  Widget _statusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildError(OrderProvider provider) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
        const SizedBox(height: 16),
        Text('${provider.error}', textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: provider.fetchAllOrders, child: Text(AppLocalizations.of(context)!.retry)),
      ]),
    );
  }
}
