import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../core/config/razorpay_config.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/main_navigation.dart';
import '../../../../core/services/razorpay_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/onboarding_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late RazorpayService _razorpayService;
  bool _isWaiverFormVisible = false;
  final TextEditingController _reasonController = TextEditingController();
  PlatformFile? _selectedFile;
  bool _isSubmittingWaiver = false;

  @override
  void initState() {
    super.initState();
    _razorpayService = RazorpayService(
      onSuccess: _handlePaymentSuccess,
      onError: _handlePaymentError,
      onExternalWallet: _handleExternalWallet,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OnboardingProvider>().checkStatus();
    });
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✅ Payment Successful! Verifying with server..."),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 10),
      ),
    );
    // Poll status every 2s for up to 15s — webhook may take a moment
    _pollOnboardingStatus(maxAttempts: 7, intervalMs: 2000);
  }

  /// Polls GET /onboarding/status until PAID/WAIVER_APPROVED or max attempts reached.
  Future<void> _pollOnboardingStatus({int maxAttempts = 7, int intervalMs = 2000}) async {
    for (int i = 0; i < maxAttempts; i++) {
      await Future.delayed(Duration(milliseconds: intervalMs));
      if (!mounted) return;
      await context.read<OnboardingProvider>().checkStatus();
      if (!mounted) return;
      final status = context.read<OnboardingProvider>().status?.status;
      if (status == 'PAID' || status == 'WAIVER_APPROVED') {
        _checkAndNavigateIn();
        return;
      }
    }
    // After max attempts, still try to navigate (webhook may have a delay)
    if (mounted) _checkAndNavigateIn();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (!mounted) return;

    final msg = response.message ?? '';
    final code = response.code ?? 0;

    // Razorpay error code 2 = "payment cancelled by user" — don't retry
    if (code == 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment cancelled.')),
      );
      return;
    }

    // Any other error (expired/stale order, "something went wrong", etc.)
    // → auto-retry: call initiatePayment again to get a fresh Razorpay order
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Previous session failed ($msg). Starting fresh payment...'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );

    // Wait for snackbar then retry with forceRetry = true
    // (skips stale order warning, directly opens new checkout)
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) _startCheckout(forceRetry: true);
    });
  }


  void _handleExternalWallet(ExternalWalletResponse response) {}

  void _checkAndNavigateIn() {
    if (!mounted) return;
    final status = context.read<OnboardingProvider>().status?.status;
    if (status == 'PAID' || status == 'WAIVER_APPROVED') {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen(initialIndex: 1)),
            (route) => false,
      );
    }
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen(initialIndex: 1)),
          (route) => false,
    );
  }

  // ignore: unused_element
  Future<void> _startCheckout({bool forceRetry = false}) async {
    final provider = context.read<OnboardingProvider>();

    // Show loading state
    if (!mounted) return;

    try {
      final razorpayData = await provider.initiatePayment();

      if (!mounted) return;

      if (razorpayData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? "Could not initiate payment. Try again."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // ── STALE ORDER DETECTION ──────────────────────────────────────────
      final String? createdAtStr = razorpayData['createdAt']?.toString();
      if (createdAtStr != null && !forceRetry) {
        final createdAt = DateTime.tryParse(createdAtStr);
        if (createdAt != null) {
          final age = DateTime.now().toUtc().difference(createdAt);
          if (age.inMinutes > 15) {
            if (!mounted) return;
            final retry = await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                title: const Text('⚠️ Payment Session Expired',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                content: Text(
                  'Your previous payment session has expired '
                  '(created ${age.inHours > 0 ? "${age.inHours}h" : "${age.inMinutes}min"} ago).\n\n'
                  'Please ask your admin to reset your payment record so a fresh session can be created.',
                  style: const TextStyle(fontSize: 13),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
                    child: const Text('Try Anyway', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
            if (retry != true || !mounted) return;
          }
        }
      }
      // ──────────────────────────────────────────────────────────────────

      final user = context.read<AuthProvider>().userProfile;
      final userMobile = user?.user.mobile ?? '';
      final userEmail = user?.user.email ?? '';

      final double amountInRupees = (razorpayData['amount'] as num).toDouble();
      final double amountInPaise = amountInRupees * 100;
      final String rzpKey = RazorpayConfig.keyId;
      final String orderId = razorpayData['razorpayOrderId'] ?? '';
      final String internalId = razorpayData['_id']?.toString() ?? '—';
      final String module = razorpayData['module']?.toString() ?? '—';
      final String createdAt = razorpayData['createdAt']?.toString() ?? '—';

      if (orderId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment order ID missing. Please contact support.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // ── DEBUG DIALOG ── shows all Razorpay payload fields for backend verification
      if (!mounted) return;
      final proceed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.bug_report, color: Colors.orange, size: 22),
              SizedBox(width: 8),
              Text('🔍 Debug: Payment Payload',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Verify these values with backend:',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 12),
                _DebugRow('Internal _id', internalId),
                _DebugRow('Razorpay Order ID', orderId),
                _DebugRow('Razorpay Key (frontend)', rzpKey),
                _DebugRow('Amount (₹ rupees)', '₹$amountInRupees'),
                _DebugRow('Amount (paise → RZP)', amountInPaise.toInt().toString()),
                _DebugRow('Module', module),
                _DebugRow('Created At', createdAt),
                _DebugRow('User Mobile', userMobile.isEmpty ? '—' : userMobile),
                _DebugRow('User Email', userEmail.isEmpty ? '—' : userEmail),
                const SizedBox(height: 10),
                const Text('Full raw response:',
                    style: TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    razorpayData.entries
                        .map((e) => '${e.key}: ${e.value}')
                        .join('\n'),
                    style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(ctx, true),
              icon: const Icon(Icons.payment, size: 16, color: Colors.white),
              label: const Text('Open Checkout',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue),
            ),
          ],
        ),
      );
      if (proceed != true || !mounted) return;
      // ── END DEBUG DIALOG ──

      _razorpayService.openCheckout(
        key: rzpKey,
        amount: amountInPaise,
        orderId: orderId,
        name: 'Shilpkar Foundation',
        description: 'Onboarding Contribution',
        userMobile: userMobile,
        userEmail: userEmail,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment error: ${e.toString().replaceAll("Exception: ", "")}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _bypassPayment() async {
    // Show a snackbar and navigate directly into the dashboard as a Demo Bypass
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✅ Demo: Onboarding Bypassed successfully!"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
    
    // Unconditionally Navigate into app dashboard
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen(initialIndex: 1)),
            (route) => false,
      );
    }
  }


  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null && mounted) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  Future<void> _submitWaiver() async {
    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide a reason for the waiver.")),
      );
      return;
    }

    setState(() => _isSubmittingWaiver = true);

    try {
      final provider = context.read<OnboardingProvider>();
      String filePath = _selectedFile?.path ?? "";

      bool success = await provider.applyWaiver(_reasonController.text.trim(), filePath);

      if (mounted) {
        if (success) {
          setState(() {
            _isWaiverFormVisible = false;
            _reasonController.clear();
            _selectedFile = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✅ Waiver application submitted successfully!"),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(provider.error ?? "Failed to submit waiver.")),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isSubmittingWaiver = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Complete Onboarding',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryBlue,
        automaticallyImplyLeading: false,
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.logout, color: Colors.white, size: 20),
            label: const Text("Logout", style: TextStyle(color: Colors.white)),
            onPressed: _logout,
          ),
        ],
      ),
      body: Consumer<OnboardingProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.status == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Checking your onboarding status...", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          if (provider.error != null && provider.status == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      provider.error!.replaceAll('Exception: ', ''),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: provider.checkStatus,
                      child: const Text("Try Again"),
                    ),
                  ],
                ),
              ),
            );
          }

          final statusModel = provider.status;
          if (statusModel == null) {
            return const Center(child: Text('Checking status...'));
          }

          if (statusModel.status == 'WAIVER_PENDING') {
            return _buildWaiverPendingView(provider);
          }

          if (statusModel.status == 'PAID' || statusModel.status == 'WAIVER_APPROVED') {
            return _buildSuccessView();
          }

          return _buildPendingView(provider, statusModel.requiredAmount);
        },
      ),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 80),
            ),
            const SizedBox(height: 24),
            const Text(
              "Onboarding Complete!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "Your account has been activated. You can now access all NGO services.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _checkAndNavigateIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  "Enter Dashboard",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingView(OnboardingProvider provider, double amount) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryBlue, AppColors.lightBlueScheme],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(Icons.account_balance_wallet, size: 60, color: Colors.white),
                const SizedBox(height: 16),
                const Text(
                  "Account Activation",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  "A one-time onboarding contribution unlocks access to schemes, jobs, and all NGO services.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              children: [
                const Text("Required Amount", style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 8),
                Text(
                  amount > 0 ? "₹${amount.toInt()}" : "Loading...",
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    color: amount > 0 ? AppColors.primaryBlue : Colors.grey,
                  ),
                ),
                const Text("One-time Contribution", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 24),
                // --- ORIGINAL BUTTON DISABLED FOR DEMO ---
                // SizedBox(
                //   width: double.infinity,
                //   height: 52,
                //   child: ElevatedButton.icon(
                //     onPressed: provider.isLoading || amount <= 0 ? null : _startCheckout,
                //     icon: const Icon(Icons.payment, color: Colors.white),
                //     label: Text(
                //       provider.isLoading ? "Processing..." : "Pay Securely – ₹${amount.toInt()}",
                //       style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                //     ),
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: AppColors.primaryBlue,
                //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                //     ),
                //   ),
                // ),
                
                // --- DEMO BYPASS BUTTON ---
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: provider.isLoading || amount <= 0 ? null : _bypassPayment,
                    icon: const Icon(Icons.payment, color: Colors.white),
                    label: Text(
                      provider.isLoading ? "Processing..." : "DEMO: BYPASS ONBOARDING",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline, size: 14, color: Colors.grey),
                    SizedBox(width: 4),
                    Text("Secure payment bypassed for demo", style: TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => setState(() => _isWaiverFormVisible = !_isWaiverFormVisible),
            icon: Icon(_isWaiverFormVisible ? Icons.close : Icons.volunteer_activism_outlined),
            label: Text(_isWaiverFormVisible ? "Cancel Waiver Application" : "I cannot afford the contribution – Apply for Waiver"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: const BorderSide(color: Colors.orange),
              foregroundColor: Colors.orange.shade700,
            ),
          ),
          if (_isWaiverFormVisible) ...[
            const SizedBox(height: 16),
            _buildWaiverForm(),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildWaiverForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.volunteer_activism, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              Text(
                "Contribution Waiver Application",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.orange.shade700),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "An admin will review your application within 1-3 business days.",
            style: TextStyle(fontSize: 12, color: Colors.orange.shade600),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _reasonController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: "Reason for Waiver *",
              hintText: "Explain your financial hardship briefly (e.g. unemployment, below poverty line, etc.)",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ListTile(
              leading: Icon(
                _selectedFile != null ? Icons.check_circle : Icons.upload_file,
                color: _selectedFile != null ? Colors.green : Colors.orange.shade700,
              ),
              title: Text(
                _selectedFile != null ? _selectedFile!.name : "Upload Supporting Document (Optional)",
                style: TextStyle(
                  fontSize: 13,
                  color: _selectedFile != null ? Colors.green.shade700 : Colors.grey.shade700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: const Text("Income cert, Ration card, etc. (JPG, PNG, PDF)", style: TextStyle(fontSize: 11)),
              trailing: TextButton(onPressed: _pickFile, child: const Text("Browse")),
              onTap: _pickFile,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmittingWaiver ? null : _submitWaiver,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSubmittingWaiver
                  ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                  SizedBox(width: 10),
                  Text("Submitting...", style: TextStyle(color: Colors.white)),
                ],
              )
                  : const Text("Submit Waiver Application", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaiverPendingView(OnboardingProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.hourglass_top_rounded, size: 70, color: Colors.orange),
            ),
            const SizedBox(height: 24),
            const Text(
              "Waiver Under Review",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "We have received your contribution waiver application. Our admin team is reviewing it. You will be notified once a decision is made.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Expected review time: 1-3 business days.",
                      style: TextStyle(color: Colors.blue, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: provider.isLoading ? null : provider.checkStatus,
              icon: const Icon(Icons.refresh),
              label: const Text("Refresh Status"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple label + value row used in the debug dialog.
class _DebugRow extends StatelessWidget {
  final String label;
  final String value;
  const _DebugRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 145,
            child: Text(
              '$label:',
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: Colors.deepOrange),
            ),
          ),
        ],
      ),
    );
  }
}
