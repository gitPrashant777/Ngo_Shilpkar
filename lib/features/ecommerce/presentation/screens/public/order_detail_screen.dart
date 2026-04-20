import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../../../core/constants/app_colors.dart';
import '../../../data/models/order_model.dart';
import '../../widgets/ecommerce_widgets.dart';
import 'replace_item_screen.dart';
import 'replace_item_screen.dart';
import 'refund_request_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  // ─────────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────────
  String _fmtDate(DateTime? dt) =>
      dt != null ? DateFormat('d MMMM yyyy').format(dt) : '—';

  Color _statusColor(String s) {
    switch (s.toUpperCase()) {
      case 'DELIVERED':
        return AppColors.shopDeliveredGreen;
      case 'CONFIRMED':
        return AppColors.shopBlueCta;
      case 'REFUNDED':
        return AppColors.shopRefundPurple;
      case 'CANCELLED':
        return AppColors.accentRed;
      case 'REFUND_REQUESTED':
      case 'REPLACEMENT_REQUESTED':
        return AppColors.broadcastOrange;
      default:
        return AppColors.textSecondary;
    }
  }

  bool get _canReplace {
    if (order.status != 'DELIVERED') return false;
    if (order.refundExpiryAt != null) {
      return DateTime.now().isBefore(order.refundExpiryAt!);
    }
    if (order.deliveredAt != null) {
      return DateTime.now().difference(order.deliveredAt!).inDays <= 10;
    }
    return false;
  }

  bool get _canRefund {
    if (order.status != 'DELIVERED') return false;
    if (order.refundExpiryAt != null) {
      return DateTime.now().isBefore(order.refundExpiryAt!);
    }
    if (order.deliveredAt != null) {
      return DateTime.now().difference(order.deliveredAt!).inDays <= 7;
    }
    return false;
  }

  // ─────────────────────────────────────────────────────────────────
  // UI SECTIONS
  // ─────────────────────────────────────────────────────────────────
  Widget _infoCard(BuildContext context) {
    final shortId = order.id.length >= 8
        ? '1234-${order.id.substring(order.id.length - 5).toUpperCase()}'
        : order.id;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow('Order placed:', _fmtDate(order.createdAt)),
          const SizedBox(height: 8),
          _infoRow('Order number:', shortId),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {},
            child: Row(
              children: [
                const Icon(Icons.upload_outlined,
                    size: 18, color: ECommerceColors.gradientStart),
                const SizedBox(width: 8),
                Text(
                  'Download Invoice',
                  style: GoogleFonts.poppins(
                    color: ECommerceColors.gradientStart,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 13, color: AppColors.textSecondary)),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.shopSectionTitle)),
        ],
      );

  Widget _productSection(BuildContext context) {
    final statusColor = _statusColor(order.status);
    final deliveredLabel =
        order.status == 'DELIVERED' && order.deliveredAt != null
            ? 'Delivered ${_fmtDate(order.deliveredAt)}'
            : order.status;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            deliveredLabel,
            style: GoogleFonts.poppins(
                fontSize: 15, fontWeight: FontWeight.bold, color: statusColor),
          ),
          if (order.status == 'DELIVERED') ...[
            const SizedBox(height: 4),
            Text(
              'Package was handed to the customer',
              style: GoogleFonts.poppins(
                  fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: order.productImage != null && order.productImage!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: order.productImage!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Icon(Icons.image_outlined, color: Colors.grey),
                          errorWidget: (context, url, err) => const Icon(Icons.image_outlined, color: Colors.grey),
                        )
                      : order.productId.isNotEmpty
                          ? AsyncProductImage(
                              productId: order.productId,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.image_outlined, color: Colors.grey),
                ),
                              ),
                              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    order.productName != null
                        ? Text(
                            order.productName!,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: ECommerceColors.productName),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          )
                        : AsyncProductName(
                            productId: order.productId,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: ECommerceColors.productName),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                    const SizedBox(height: 4),
                    Text('Sold by: Shilpkar Foundation',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: AppColors.textSecondary)),
                    if (_canReplace)
                      Text(
                        'Replace Item: eligible till ${_fmtDate(order.refundExpiryAt ?? order.deliveredAt?.add(const Duration(days: 10)))}',
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: AppColors.textSecondary),
                      ),
                    Text(
                      '₹ ${order.totalAmount.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(

                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: ECommerceColors.productPrice),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Payment Method: ${order.paymentStatus == 'PAID' ? 'Online' : 'Pay on Delivery'}',
            style: GoogleFonts.poppins(
                fontSize: 13, color: AppColors.textSecondary),
          ),
          if (_canReplace || _canRefund) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                if (_canReplace)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ReplaceItemScreen(order: order)),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ECommerceColors.buyNowBg,
                        foregroundColor: ECommerceColors.buyNowText,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: Text('Replace',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ),
                if (_canReplace && _canRefund) const SizedBox(width: 12),
                if (_canRefund)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => RefundRequestScreen(order: order)),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: ECommerceColors.gradientStart,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(
                              color: ECommerceColors.gradientStart, width: 1.5),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: Text('Refund',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _shippedTo() {
    final addr = order.address;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Shipped to',
              style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.shopSectionTitle)),
          const SizedBox(height: 12),
          Text(addr.street.isNotEmpty ? addr.street : 'N/A',
              style: GoogleFonts.poppins(
                  fontSize: 13, color: AppColors.textSecondary)),
          if (addr.city.isNotEmpty)
            Text(addr.city,
                style: GoogleFonts.poppins(
                    fontSize: 13, color: AppColors.textSecondary)),
          if (addr.state.isNotEmpty)
            Text(addr.state,
                style: GoogleFonts.poppins(
                    fontSize: 13, color: AppColors.textSecondary)),
          if (addr.pincode.isNotEmpty)
            Text(addr.pincode,
                style: GoogleFonts.poppins(
                    fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _orderSummary() {
    const shippingContribution = 40.0;
    const codContribution = 8.0;
    final isPaid = order.paymentStatus == 'PAID';
    final totalWithContribution =
        isPaid ? order.totalAmount : order.totalAmount + codContribution;


    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Summary',
              style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.shopSectionTitle)),
          const SizedBox(height: 14),
          _summaryRow('Item Subtotal:',
              '₹${order.totalAmount.toStringAsFixed(2)}'),

          const SizedBox(height: 8),
          _summaryRow('Shipping:', '₹${shippingContribution.toStringAsFixed(2)}'),
          if (!isPaid) ...[
            const SizedBox(height: 8),
            _summaryRow('Pay on delivery Contribution:', '₹${codContribution.toStringAsFixed(2)}'),
          ],
          const SizedBox(height: 14),
          const Divider(color: AppColors.shopDivider),
          const SizedBox(height: 10),
          _summaryRow(
            'Grand Total:',
            '₹${totalWithContribution.toStringAsFixed(2)}',
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: isBold ? FontWeight.w600 : FontWeight.normal)),
        Text(value,
            style: GoogleFonts.poppins(
                fontSize: 14,
                color: ECommerceColors.productPrice,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w600)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ECommerceColors.scaffold,
      body: Stack(
        children: [
          // Header Gradient matching other screens
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 250,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ECommerceColors.gradientStart,
                    ECommerceColors.gradientEnd,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Minimal Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'Order Details',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _infoCard(context),
                        _productSection(context),
                        _shippedTo(),
                        _orderSummary(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
