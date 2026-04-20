import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:shilpkar/features/auth/data/repository/user_repository.dart';
import '../../../../features/admin/presentation/screens/beneficiary_detail_screen.dart';
import '../providers/onboarding_provider.dart';

class OnboardingAdminScreen extends StatefulWidget {
  const OnboardingAdminScreen({super.key});

  @override
  State<OnboardingAdminScreen> createState() => _OnboardingAdminScreenState();
}

class _OnboardingAdminScreenState extends State<OnboardingAdminScreen> {
  final TextEditingController _contributionController = TextEditingController();

  bool _isSettingContribution = false;
  bool _isReviewing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final provider = context.read<OnboardingProvider>();
      await provider.fetchAdminData();
      if (mounted && provider.error != null) {
        _showSnack(provider.error!, color: Colors.red);
      }
    });
  }

  @override
  void dispose() {
    _contributionController.dispose();
    super.dispose();
  }

  // ------------------- CONTRIBUTION CONFIG -------------------

  void _openContributionDialog(double? current) {
    if (current != null) _contributionController.text = current.toInt().toString();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(children: [
              Icon(Icons.currency_rupee, color: AppColors.primaryBlue),
              SizedBox(width: 8),
              Text("Create New Contribution Config", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ]),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              if (current != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    const Icon(Icons.info_outline, color: Colors.blue, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Current: ₹${current.toInt()}. Creating a new config instantly activates it for new beneficiaries.",
                        style: const TextStyle(fontSize: 11, color: Colors.blue),
                      ),
                    ),
                  ]),
                ),
              TextField(
                controller: _contributionController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: "New Contribution Amount",
                  prefixText: "₹ ",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                ),
              ),
            ]),
            actions: [
              TextButton(
                onPressed: _isSettingContribution ? null : () { 
                  Navigator.pop(dialogContext); 
                  _contributionController.clear(); 
                },
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: _isSettingContribution ? null : () async {
                  final amount = double.tryParse(_contributionController.text.trim());
                  if (amount == null || amount <= 0) {
                    _showSnack("Enter a valid contribution amount greater than 0");
                    return;
                  }
                  
                  setDialogState(() => _isSettingContribution = true);
                  
                  final provider = this.context.read<OnboardingProvider>();
                  final success = await provider.setContribution(amount);
                  
                  if (!mounted) return;
                  setDialogState(() => _isSettingContribution = false);
                  
                  Navigator.pop(dialogContext);
                  _contributionController.clear();
                  
                  _showSnack(
                    success ? "✅ Contribution updated to ₹${amount.toInt()}" : (provider.error ?? "Failed"),
                    color: success ? Colors.green : Colors.red,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isSettingContribution
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Activate Contribution", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        }
      ),
    );
  }

  // ─────────────────── HELPERS ───────────────────

  void _showSnack(String msg, {Color? color, int duration = 3}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      duration: Duration(seconds: duration),
    ));
  }

  // ─────────────────── BUILD ───────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text("Onboarding Configuration", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          if (context.watch<OnboardingProvider>().isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              tooltip: "Refresh",
              onPressed: () => context.read<OnboardingProvider>().fetchAdminData(),
            ),
        ],
      ),
      body: Consumer<OnboardingProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.latestContribution == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: provider.fetchAdminData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildContributionBanner(provider),
                  const SizedBox(height: 24),
                  const Text("Waiver Review", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildWaiverReviewCard(provider),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─────────────────── WIDGETS ───────────────────

  Widget _buildContributionBanner(OnboardingProvider provider) {
    final contribution = provider.latestContribution;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.profileBlue, AppColors.lightBlueScheme],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.3), blurRadius: 14, offset: const Offset(0, 5))],
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Active Onboarding Contribution", style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 6),
            Text(
              contribution != null ? "₹${contribution.amount.toInt()}" : "Not Configured",
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            ),
            if (contribution != null)
              Text(
                "Effective from ${_fmtDate(contribution.effectiveFrom)}",
                style: const TextStyle(color: Colors.white60, fontSize: 11),
              )
            else
              const Text(
                "Contribution not yet created on server",
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
          ]),
        ),
        ElevatedButton.icon(
          onPressed: () => _openContributionDialog(contribution?.amount),
          icon: const Icon(Icons.add, size: 16),
          label: const Text("New Config"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primaryBlue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
      ]),
    );
  }

  Widget _buildWaiverReviewCard(OnboardingProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(children: [
                   Icon(Icons.volunteer_activism, color: Colors.orange, size: 20),
                   SizedBox(width: 8),
                   Text("Waiver Requests", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ]),
                // Simple filter dropdown
                DropdownButton<String>(
                  value: provider.currentWaiverStatusFilter,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.filter_list, size: 18),
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                  items: const [
                    DropdownMenuItem(value: 'WAIVER_PENDING', child: Text("Pending")),
                    DropdownMenuItem(value: 'WAIVER_APPROVED', child: Text("Approved")),
                    DropdownMenuItem(value: 'PENDING', child: Text("Rejected")), // "REJECT" sets to PENDING
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      provider.fetchWaiverRequests(refresh: true, status: val);
                    }
                  },
                )
              ],
            ),
          ),
          
          if (provider.isLoading && provider.waiverRequests.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (provider.waiverRequests.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      "No ${provider.currentWaiverStatusFilter == 'WAIVER_PENDING' ? 'Pending' : provider.currentWaiverStatusFilter == 'PENDING' ? 'Rejected' : 'Approved'} requests found",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.waiverRequests.length + (provider.hasMoreWaivers ? 1 : 0),
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                if (index == provider.waiverRequests.length) {
                  return TextButton(
                    onPressed: provider.isLoading ? null : () => provider.fetchWaiverRequests(),
                    child: provider.isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text("Load More"),
                  );
                }

                final request = provider.waiverRequests[index];
                return _buildWaiverItem(context, request, provider);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildWaiverItem(BuildContext context, dynamic request, OnboardingProvider provider) {
    final bool isPending = request.status == 'WAIVER_PENDING';
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                child: Text(
                  request.requesterName.isNotEmpty ? request.requesterName[0].toUpperCase() : '?',
                  style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.requesterName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          "Phone: ${request.requesterPhone}",
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: () => _viewMemberDetails(request.requesterId),
                          child: const Text("View Member", style: TextStyle(color: AppColors.primaryBlue, decoration: TextDecoration.underline, fontSize:12, fontWeight: FontWeight.bold)),
                        )
                      ]
                    )
                  ],
                ),
              ),
              if (!isPending)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: request.status == 'WAIVER_APPROVED' ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    request.status == 'WAIVER_APPROVED' ? "Approved" : "Rejected",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: request.status == 'WAIVER_APPROVED' ? Colors.green : Colors.red,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Reason for Waiver:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue)),
                const SizedBox(height: 4),
                Text(request.waiverReason ?? "No reason provided", style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
          if (request.waiverDocumentUrl != null && request.waiverDocumentUrl!.isNotEmpty) ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                // In a real app, open URL or document viewer
                _showSnack("Document URL: ${request.waiverDocumentUrl}");
              },
              child: Row(
                children: [
                  const Icon(Icons.attachment, size: 16, color: AppColors.primaryBlue),
                  const SizedBox(width: 4),
                  const Text("View Document", style: TextStyle(color: AppColors.primaryBlue, fontSize: 13, decoration: TextDecoration.underline)),
                ],
              ),
            ),
          ],
          
          if (isPending) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isReviewing ? null : () => _confirmAndReview(request.requesterId, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red.shade200),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Reject"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isReviewing ? null : () => _confirmAndReview(request.requesterId, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Approve", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            )
          ]
        ],
      ),
    );
  }

  Future<void> _confirmAndReview(String id, bool approve) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(approve ? "Approve Waiver?" : "Reject Waiver?"),
        content: Text(approve 
            ? "This will grant the user full system access without payment." 
            : "This will require the user to pay the onboarding contribution."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: approve ? Colors.green : Colors.red),
            child: Text(approve ? "Approve" : "Reject"),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isReviewing = true);
      final provider = context.read<OnboardingProvider>();
      final success = await provider.reviewWaiver(id, approve);
      if (mounted) {
        setState(() => _isReviewing = false);
        _showSnack(
          success 
              ? (approve ? "Waiver Approved" : "Waiver Rejected") 
              : (provider.error ?? "Failed"),
          color: success ? (approve ? Colors.green : Colors.orange) : Colors.red,
        );
      }
    }
  }

  Future<void> _viewMemberDetails(String id) async {
    try {
      showDialog(
        context: context, 
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator())
      );
      final repo = UserRepository();
      final beneficiary = await repo.getBeneficiaryById(id);
      if(mounted){
        Navigator.pop(context); // close loader
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BeneficiaryDetailScreen(beneficiary: beneficiary),
          ),
        );
      }
    } catch (e) {
      if(mounted){
        Navigator.pop(context); // close loader
        _showSnack("Failed to fetch details: $e", color: Colors.red);
      }
    }
  }

  String _fmtDate(DateTime d) {
    const m = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
    return "${d.day} ${m[d.month - 1]} ${d.year}";
  }
}

