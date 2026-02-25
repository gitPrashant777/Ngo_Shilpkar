import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../core/config/razorpay_config.dart';
import '../../../../core/services/razorpay_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/scheme_provider.dart';
import '../../data/models/scheme_application_model.dart';

class MySchemeApplicationsScreen extends StatefulWidget {
  const MySchemeApplicationsScreen({super.key});

  @override
  State<MySchemeApplicationsScreen> createState() => _MySchemeApplicationsScreenState();
}

class _MySchemeApplicationsScreenState extends State<MySchemeApplicationsScreen> {
  static const _kBlue = Color(0xFF4A78B0);
  late RazorpayService _razorpayService;

  @override
  void initState() {
    super.initState();
    _razorpayService = RazorpayService(
      onSuccess: _handlePaymentSuccess,
      onError: _handlePaymentError,
      onExternalWallet: _handleExternalWallet,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SchemeProvider>().fetchMyApplications();
    });
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✅ Payment Successful! Verifying with server..."),
        backgroundColor: Colors.green,
      ),
    );
    Provider.of<SchemeProvider>(context, listen: false).fetchMyApplications();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: ${response.message}")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        backgroundColor: _kBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Applications',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            Text('Scheme applications you have submitted',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w300)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<SchemeProvider>().fetchMyApplications(),
          )
        ],
      ),
      body: Consumer<SchemeProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.myApplications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.myApplications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 72, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('No applications yet',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600)),
                  const SizedBox(height: 8),
                  Text('Apply for a scheme from the Schemes tab',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchMyApplications(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.myApplications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final app = provider.myApplications[index];
                return _buildApplicationCard(app, provider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildApplicationCard(SchemeApplicationModel app, SchemeProvider provider) {
    final statusColor = _statusColor(app.status);
    final statusLabel = app.status.isNotEmpty ? app.status : 'PENDING';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
        border: Border(left: BorderSide(color: statusColor, width: 4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Scheme name + status chip
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    app.schemeName.isNotEmpty ? app.schemeName : 'Unnamed Scheme',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold, color: statusColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Applied date
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 13, color: Colors.grey.shade400),
                const SizedBox(width: 5),
                Text(
                  'Applied on ${_formatDate(app.createdAt)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _StatusNote(status: statusLabel),
            // Withdraw option only for pending/under review
            if (_canWithdraw(app.status)) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _withdraw(app, provider),
                  icon: const Icon(Icons.undo_rounded, size: 16, color: Colors.red),
                  label: const Text('Withdraw Application',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
            if (_canPay(app.status)) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: provider.isLoading ? null : () => _startPayment(app, provider),
                  icon: const Icon(Icons.payment, size: 16),
                  label: Text(provider.isLoading ? 'Processing...' : 'Proceed to Payment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _canWithdraw(String status) {
    return status.toUpperCase() == 'PAYMENT_PENDING';
  }

  bool _canPay(String status) {
    return status.toUpperCase() == 'PAYMENT_PENDING';
  }

  Future<void> _startPayment(SchemeApplicationModel app, SchemeProvider provider) async {
    try {
      // Pass schemeId (not applicationId) to get a Razorpay order
      print('🚀 [SCHEME PAYMENT] Starting payment for scheme: ${app.schemeId}, app: ${app.id}');
      final razorpayData = await provider.initiatePayment(app.schemeId);

      if (!mounted) return;

      if (razorpayData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error ?? "Could not initiate payment. Try again.")),
        );
        return;
      }

      print('🚀 [SCHEME PAYMENT] Full razorpayData: $razorpayData');

      // If no razorpayOrderId exists → scheme may be FREE or already applied
      final String orderId = razorpayData['razorpayOrderId'] ?? '';
      if (orderId.isEmpty) {
        print('⚠️ [SCHEME PAYMENT] No razorpayOrderId in response - refreshing applications');
        await provider.fetchMyApplications();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Application updated. No payment required.")),
          );
        }
        return;
      }

      final user = context.read<AuthProvider>().userProfile;
      final userMobile = user?.user.mobile ?? '';
      final userEmail = user?.user.email ?? '';

      // Mirror e-commerce exactly: (amount as num).toDouble() * 100
      final double amountInPaise = ((razorpayData['amount'] as num).toDouble()) * 100;

      // Mirror e-commerce exactly: use hardcoded key
      final String rzpKey = RazorpayConfig.keyId;

      print('🚀 [SCHEME] key=$rzpKey paise=$amountInPaise orderId=$orderId');

      _razorpayService.openCheckout(
        key: rzpKey,
        amount: amountInPaise,
        orderId: orderId,
        name: 'Shilpkar Foundation',
        description: 'Scheme Payment: ${app.schemeName}',
        userMobile: userMobile,
        userEmail: userEmail,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment error: $e")),
      );
    }
  }


  Future<void> _withdraw(SchemeApplicationModel app, SchemeProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Withdraw Application?'),
        content:
            Text('Are you sure you want to withdraw from "${app.schemeName}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Withdraw', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final ok = await provider.withdrawApplication(app.id, schemeId: app.schemeId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? '✅ Application withdrawn' : '❌ ${provider.error}'),
        backgroundColor: ok ? Colors.orange : Colors.red,
      ));
    }
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
      case 'ACCEPTED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      case 'UNDER_REVIEW':
      case 'REVIEWED':
        return Colors.blue;
      case 'DISBURSED':
        return Colors.purple;
      case 'PAYMENT_PENDING':
      case 'WAIVER_PENDING':
        return Colors.orange;
      default:
        return Colors.orange;
    }
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
}

class _StatusNote extends StatelessWidget {
  final String status;
  const _StatusNote({required this.status});

  @override
  Widget build(BuildContext context) {
    String note;
    IconData icon;
    Color color;

    switch (status.toUpperCase()) {
      case 'PENDING':
        note = 'Your application is waiting for review.';
        icon = Icons.hourglass_empty_rounded;
        color = Colors.orange;
        break;
      case 'PAYMENT_PENDING':
        note = 'Please complete the payment to proceed.';
        icon = Icons.payment;
        color = Colors.orange;
        break;
      case 'WAIVER_PENDING':
        note = 'Your waiver request is under review.';
        icon = Icons.hourglass_top_rounded;
        color = Colors.orange;
        break;
      case 'UNDER_REVIEW':
      case 'REVIEWED':
        note = 'Your application is currently under review.';
        icon = Icons.find_in_page_outlined;
        color = Colors.blue;
        break;
      case 'APPROVED':
      case 'ACCEPTED':
        note = 'Congratulations! Your application has been approved.';
        icon = Icons.check_circle_outline_rounded;
        color = Colors.green;
        break;
      case 'REJECTED':
        note = 'Unfortunately, your application was not approved.';
        icon = Icons.cancel_outlined;
        color = Colors.red;
        break;
      case 'DISBURSED':
        note = 'Scheme benefits have been disbursed to you.';
        icon = Icons.account_balance_wallet_outlined;
        color = Colors.purple;
        break;
      default:
        note = 'Application submitted successfully.';
        icon = Icons.info_outline;
        color = Colors.grey;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 5),
        Expanded(
          child: Text(note,
              style: TextStyle(
                  fontSize: 12, color: color, fontStyle: FontStyle.italic)),
        ),
      ],
    );
  }
}
