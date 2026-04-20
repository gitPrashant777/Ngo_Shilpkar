import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../data/models/return_request_model.dart';
import '../../providers/order_provider.dart';

class AdminRefundReviewScreen extends StatefulWidget {
  final ReturnRequestModel request;

  const AdminRefundReviewScreen({super.key, required this.request});

  @override
  State<AdminRefundReviewScreen> createState() => _AdminRefundReviewScreenState();
}

class _AdminRefundReviewScreenState extends State<AdminRefundReviewScreen> {
  final TextEditingController _remarkController = TextEditingController();
  late ReturnRequestModel _request;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _request = widget.request;
    _refresh();
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = _request;
    final pending = request.status == 'PENDING';

    return Scaffold(
      backgroundColor: AppColors.refundBackground,
      appBar: AppBar(
        title: const Text('Refund Review'),
        backgroundColor: AppColors.refundBackground,
        foregroundColor: AppColors.refundPrimaryText,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: LinearProgressIndicator(minHeight: 2),
              ),
            _profileCard(request),
            const SizedBox(height: 12),
            _transactionCard(request),
            const SizedBox(height: 12),
            _refundRequestCard(request),
            const SizedBox(height: 12),
            _adminActionsCard(request, pending),
            const SizedBox(height: 16),
            _timelineCard(request),
          ],
        ),
      ),
    );
  }

  Widget _profileCard(ReturnRequestModel request) {
    if (request.requesterName == null &&
        request.requesterPhone == null &&
        request.requesterId == null &&
        request.verificationStatus == null) {
      return const SizedBox.shrink();
    }

    return _sectionCard(
      title: 'Beneficiary Profile',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _avatar(request),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (request.requesterName != null)
                  Text(
                    request.requesterName!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.refundPrimaryText,
                    ),
                  ),
                if (request.requesterId != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'ID: ${request.requesterId!}',
                      style: const TextStyle(
                        color: AppColors.refundSecondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ),
                if (request.requesterPhone != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      request.requesterPhone!,
                      style: const TextStyle(
                        color: AppColors.refundSecondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ),
                if (request.verificationStatus != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: _pill(
                      request.verificationStatus!,
                      AppColors.refundPendingBg,
                      AppColors.refundPendingText,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _transactionCard(ReturnRequestModel request) {
    if (request.transactionId == null &&
        request.paymentMethod == null &&
        request.paidAmount == null &&
        request.transactionCreatedAt == null) {
      return const SizedBox.shrink();
    }

    return _sectionCard(
      title: 'Original Transaction',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (request.transactionId != null)
            _row('Transaction ID', request.transactionId!),
          if (request.transactionCreatedAt != null)
            _row(
              'Date & Time',
              DateFormat('dd MMM yyyy • hh:mm a')
                  .format(request.transactionCreatedAt!),
            ),
          if (request.paymentMethod != null)
            _row('Payment Method', request.paymentMethod!),
          if (request.paidAmount != null)
            _row(
              'Total Paid',
              '₹${request.paidAmount!.toStringAsFixed(2)}',
              isBold: true,
            ),
        ],
      ),
    );
  }

  Widget _refundRequestCard(ReturnRequestModel request) {
    if (request.reason == null && request.requestedAmount == null) {
      return const SizedBox.shrink();
    }

    return _sectionCard(
      title: 'Refund Request',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (request.reason != null)
            _calloutBox(request.reason!),
          if (request.requestedAmount != null) ...[
            const SizedBox(height: 8),
            _row(
              'Requested Amount',
              '₹${request.requestedAmount!.toStringAsFixed(2)}',
              isBold: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _adminActionsCard(ReturnRequestModel request, bool pending) {
    return _sectionCard(
      title: 'Administrative Actions',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pending) ...[
            TextField(
              controller: _remarkController,
              decoration: InputDecoration(
                hintText: 'Add a reason for approval/rejection...',
                filled: true,
                fillColor: AppColors.refundSearchBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              minLines: 2,
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _reject(request.id),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Reject Request'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.refundRejectButton,
                      side: const BorderSide(color: AppColors.refundRejectButton),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approve(request.id),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Initiate Refund'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.refundPrimaryButton,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (!pending && request.status == 'APPROVED' && request.refundId == null) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _retryRefund(request.id),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Retry Refund'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.refundPrimaryButton,
                  side: const BorderSide(color: AppColors.refundPrimaryButton),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _timelineCard(ReturnRequestModel request) {
    if (request.createdAt == null && request.updatedAt == null) {
      return const SizedBox.shrink();
    }
    return _sectionCard(
      title: 'Request Timeline',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (request.createdAt != null)
            _timelineRow('Refund requested', request.createdAt!),
          if (request.updatedAt != null)
            _timelineRow('System verification', request.updatedAt!),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.refundCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.refundCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.refundPrimaryText,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.refundSecondaryText,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.refundPrimaryText,
              fontSize: 12,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  Widget _calloutBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.refundSearchBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.refundDivider),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: AppColors.refundSecondaryText),
      ),
    );
  }

  Widget _timelineRow(String label, DateTime time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.refundPrimaryButton,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.refundPrimaryText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            DateFormat('dd MMM, hh:mm a').format(time),
            style: const TextStyle(color: AppColors.refundMutedText, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _avatar(ReturnRequestModel request) {
    if (request.requesterAvatar != null && request.requesterAvatar!.isNotEmpty) {
      return CircleAvatar(
        radius: 26,
        backgroundImage: NetworkImage(request.requesterAvatar!),
        backgroundColor: AppColors.refundSearchBg,
      );
    }
    final initials = (request.requesterName ?? 'U').trim().isEmpty
        ? 'U'
        : request.requesterName!.trim()[0].toUpperCase();
    return CircleAvatar(
      radius: 26,
      backgroundColor: AppColors.refundSearchBg,
      child: Text(
        initials,
        style: const TextStyle(color: AppColors.refundPrimaryText, fontWeight: FontWeight.w700),
      ),
    );
  }

  Future<void> _approve(String id) async {
    try {
      final remark = _remarkController.text.trim();
      await context.read<OrderProvider>().approveReturn(
            id,
            adminNotes: remark.isEmpty ? null : remark,
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _reject(String id) async {
    final remark = _remarkController.text.trim();
    if (remark.isEmpty) {
      _showError('Please add a rejection reason.');
      return;
    }
    try {
      await context.read<OrderProvider>().rejectReturn(id, remark);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _retryRefund(String id) async {
    try {
      await context.read<OrderProvider>().retryRefund(id);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    final latest = await context.read<OrderProvider>().getRefundRequestById(_request.id);
    if (!mounted) return;
    if (latest != null) {
      setState(() {
        _request = latest;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.refundRejectButton),
    );
  }
}
