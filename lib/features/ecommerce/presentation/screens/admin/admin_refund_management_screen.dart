import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../data/models/return_request_model.dart';
import '../../providers/order_provider.dart';
import 'admin_refund_review_screen.dart';

class AdminRefundManagementScreen extends StatefulWidget {
  const AdminRefundManagementScreen({super.key});

  @override
  State<AdminRefundManagementScreen> createState() => _AdminRefundManagementScreenState();
}

class _AdminRefundManagementScreenState extends State<AdminRefundManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).fetchReturnRequests();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.refundBackground,
      appBar: AppBar(
        title: const Text('Refund Queries', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.refundBackground,
        foregroundColor: AppColors.refundPrimaryText,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<OrderProvider>().fetchReturnRequests(),
          ),
        ],
      ),
      body: Consumer<OrderProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.returnRequests.isEmpty) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (provider.error != null && provider.returnRequests.isEmpty) {
            return _buildError(provider);
          }

          final requests = _applySearch(provider.returnRequests);
          final pendingCount = provider.returnRequests.where((r) => r.status == 'PENDING').length;

          return RefreshIndicator(
            onRefresh: () => provider.fetchReturnRequests(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _buildSearchBar(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      'Active Requests',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.refundPrimaryText,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _pill(
                      '$pendingCount Pending',
                      AppColors.refundPendingBg,
                      AppColors.refundPendingText,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (requests.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Text(
                        AppLocalizations.of(context)!.noReturnRequests,
                        style: const TextStyle(color: AppColors.refundMutedText),
                      ),
                    ),
                  )
                else
                  ...requests.map(_buildRequestCard),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.refundSearchBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.refundCardBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.refundSearchIcon),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value.trim().toLowerCase()),
              decoration: const InputDecoration(
                hintText: 'Search ...',
                border: InputBorder.none,
              ),
            ),
          ),
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.refundPrimaryButton,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Text(
              'Search',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(ReturnRequestModel request) {
    final amount = request.requestedAmount ?? request.paidAmount;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.refundCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.refundCardBorder),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AdminRefundReviewScreen(request: request),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _avatar(request),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.requesterName ?? 'User',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.refundPrimaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ref ID: ${_refIdLabel(request)}',
                      style: const TextStyle(
                        color: AppColors.refundSecondaryText,
                        fontSize: 12,
                      ),
                    ),
                    if (request.createdAt != null)
                      Text(
                        DateFormat('d MMM, yyyy').format(request.createdAt!),
                        style: const TextStyle(
                          color: AppColors.refundMutedText,
                          fontSize: 11,
                        ),
                      ),
                    const SizedBox(height: 6),
                    if (request.status == 'PENDING')
                      _pill('PENDING', AppColors.refundPendingBg, AppColors.refundPendingText),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (amount != null)
                    Text(
                      '₹${amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.refundPrimaryText,
                      ),
                    ),
                  const SizedBox(height: 8),
                  const Icon(Icons.chevron_right, color: AppColors.refundMutedText),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<ReturnRequestModel> _applySearch(List<ReturnRequestModel> requests) {
    if (_searchQuery.isEmpty) return requests;
    return requests.where((r) {
      final id = r.id.toLowerCase();
      final name = (r.requesterName ?? '').toLowerCase();
      final order = r.orderId.toLowerCase();
      final refId = (r.requesterId ?? '').toLowerCase();
      final tx = (r.transactionId ?? '').toLowerCase();
      return id.contains(_searchQuery) ||
          name.contains(_searchQuery) ||
          order.contains(_searchQuery) ||
          refId.contains(_searchQuery) ||
          tx.contains(_searchQuery);
    }).toList();
  }

  Widget _avatar(ReturnRequestModel request) {
    if (request.requesterAvatar != null && request.requesterAvatar!.isNotEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(request.requesterAvatar!),
        backgroundColor: AppColors.refundSearchBg,
      );
    }
    final name = (request.requesterName ?? '').trim();
    final initials = name.isEmpty ? 'U' : name[0].toUpperCase();
    return CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.refundSearchBg,
      child: Text(
        initials,
        style: const TextStyle(color: AppColors.refundPrimaryText, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _pill(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
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

  String _shortId(String id) {
    if (id.length <= 6) return id;
    return id.substring(id.length - 6).toUpperCase();
  }

  String _refIdLabel(ReturnRequestModel request) {
    if (request.requesterId != null && request.requesterId!.isNotEmpty) {
      return request.requesterId!;
    }
    return '#${_shortId(request.id)}';
  }

  Widget _buildError(OrderProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          provider.error.toString(),
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.refundRejectButton),
        ),
      ),
    );
  }
}
