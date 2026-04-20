import 'package:flutter/material.dart';
import '../../../schemes/data/repository/scheme_repository.dart';

class SchemePayoutScreen extends StatefulWidget {
  final String schemeId;
  final String schemeName;

  const SchemePayoutScreen({super.key, required this.schemeId, required this.schemeName});

  @override
  State<SchemePayoutScreen> createState() => _SchemePayoutScreenState();
}

class _SchemePayoutScreenState extends State<SchemePayoutScreen> {
  final SchemeRepository _repository = SchemeRepository();
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};
  List<dynamic> _payouts = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _repository.getSchemeSummary(widget.schemeId);
      final payouts = await _repository.getSchemePayouts(widget.schemeId);
      if (mounted) {
        setState(() {
          _stats = stats;
          _payouts = payouts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Payouts: ${widget.schemeName}")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsCard(),
                  const SizedBox(height: 20),
                  const Text("Payout History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildPayoutList(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statItem("Total Apps", "${_stats['totalApplications'] ?? 0}"),
                _statItem("Approved", "${_stats['approvedApplications'] ?? 0}"),
                _statItem("Pending Payouts", "${_stats['pendingPayouts'] ?? 0}"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildPayoutList() {
    if (_payouts.isEmpty) return const Text("No payouts recorded yet.");

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _payouts.length,
      itemBuilder: (context, index) {
        final payout = _payouts[index];
        return ListTile(
          title: Text("Amount: ₹${payout['amount']}"),
          subtitle: Text("Date: ${payout['date']}"),
          trailing: Text(payout['status'] ?? "Processing"),
        );
      },
    );
  }
}
