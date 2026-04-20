import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';

class FoundationDashboardScreen extends StatefulWidget {
  const FoundationDashboardScreen({super.key});

  @override
  State<FoundationDashboardScreen> createState() =>
      _FoundationDashboardScreenState();
}

class _FoundationDashboardScreenState extends State<FoundationDashboardScreen>
    with SingleTickerProviderStateMixin {
  // Dashboard cards order (for rearranging)
  late List<_DashCardData> _cards;
  bool _cardsBuilt = false;

  void _buildCards(DashboardProvider p) {
    final totalStaff = p.employees + p.coordinators;
    _cards = [
      _DashCardData(
        key: 'beneficiaries',
        title: 'Total Beneficiaries',
        value: p.beneficiaries.toString(),
        target: 6000,
        current: p.beneficiaries,
        color: const Color(0xFF1E5799),
        icon: Icons.people_alt_outlined,
        subtitle: 'Registered beneficiaries',
      ),
      _DashCardData(
        key: 'employees',
        title: 'Employees & Coordinators',
        value: totalStaff.toString(),
        target: 300,
        current: totalStaff,
        color: const Color(0xFF27AE60),
        icon: Icons.badge_outlined,
        subtitle: '${p.employees} Employees · ${p.coordinators} Coordinators',
      ),
      _DashCardData(
        key: 'schemes',
        title: 'Total Schemes',
        value: p.totalSchemes.toString(),
        target: 50,
        current: p.totalSchemes,
        color: const Color(0xFF8E44AD),
        icon: Icons.assignment_outlined,
        subtitle: 'Active published schemes',
      ),
      _DashCardData(
        key: 'applications',
        title: 'Total Applications',
        value: p.totalApplications.toString(),
        target: 500,
        current: p.totalApplications,
        color: const Color(0xFF2980B9),
        icon: Icons.how_to_reg_outlined,
        subtitle: 'Submitted applications',
      ),
      _DashCardData(
        key: 'funds',
        title: 'Total Revenue',
        value: p.totalRevenue >= 1000
            ? '₹${(p.totalRevenue / 1000).toStringAsFixed(1)}K'
            : '₹${p.totalRevenue.toInt()}',
        target: 500000,
        current: p.totalRevenue.round(),
        color: const Color(0xFFE67E22),
        icon: Icons.account_balance_wallet_outlined,
        subtitle: 'Collected payments',
      ),
      _DashCardData(
        key: 'payments',
        title: 'Total Payments',
        value: p.totalPayments.toString(),
        target: 0,
        current: p.totalPayments,
        color: const Color(0xFF27AE60),
        icon: Icons.payment_outlined,
        subtitle: 'Completed transactions',
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        // Build cards lazily once we have real data (or on refresh)
        if (!_cardsBuilt || (!provider.isLoading && provider.totalUsers > 0)) {
          _buildCards(provider);
          _cardsBuilt = true;
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF4F6FA),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1E5799),
            foregroundColor: Colors.white,
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Foundation Dashboard',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Live Data',
                    style: TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
            actions: [
              // Error badge
              if (provider.error != null)
                IconButton(
                  icon: const Icon(Icons.warning_amber_rounded,
                      color: Colors.amber),
                  tooltip: provider.error,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(provider.error!),
                      backgroundColor: Colors.red.shade700,
                    ));
                  },
                ),
              IconButton(
                icon: provider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.refresh_outlined),
                tooltip: 'Refresh',
                onPressed: provider.isLoading
                    ? null
                    : () {
                        provider.fetchAll(refresh: true);
                      },
              ),
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Tooltip(
                  message: 'Drag cards to rearrange',
                  child: IconButton(
                    icon: const Icon(Icons.drag_indicator),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            '📌 Long press cards to drag and rearrange!'),
                        duration: Duration(seconds: 2),
                        backgroundColor: Color(0xFF1E5799),
                      ));
                    },
                  ),
                ),
              ),
            ],
          ),
          body: provider.isLoading && provider.totalUsers == 0
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderSummary(provider),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Container(
                              width: 4,
                              height: 18,
                              decoration: BoxDecoration(
                                  color: const Color(0xFF1E5799),
                                  borderRadius: BorderRadius.circular(2))),
                          const SizedBox(width: 10),
                          const Text('Foundation Progress',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          const Spacer(),
                          const Text('Drag to rearrange',
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Rearrangeable dashboard cards
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _cards.length,
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) newIndex--;
                            final item = _cards.removeAt(oldIndex);
                            _cards.insert(newIndex, item);
                          });
                        },
                        itemBuilder: (context, index) {
                          return _buildProgressCard(
                              _cards[index], Key(_cards[index].key));
                        },
                      ),

                      const SizedBox(height: 16),
                      _buildActivityNote(provider),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildHeaderSummary(DashboardProvider p) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E5799), Color(0xFF2E86C1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shilpakar Foundation',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Text('Latur-Maharashtra',
              style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildHeaderStat(
                    'Beneficiaries', p.beneficiaries.toString(), Icons.people),
              ),
              Expanded(
                child: _buildHeaderStat(
                    'Staff', p.totalStaff.toString(), Icons.badge),
              ),
              Expanded(
                child: _buildHeaderStat(
                    'Schemes', p.totalSchemes.toString(), Icons.assignment),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white24),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.trending_up,
                  color: Colors.greenAccent, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${p.totalApplications} applications submitted  •  '
                  '${p.totalPayments} payments completed',
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 22),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        Text(label,
            style: const TextStyle(color: Colors.white60, fontSize: 10)),
      ],
    );
  }

  Widget _buildProgressCard(_DashCardData data, Key key) {
    final progress = data.target > 0
        ? (data.current / data.target).clamp(0.0, 1.0)
        : 1.0;

    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: data.isAlert
            ? Border.all(color: Colors.orange, width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(data.icon, color: data.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    Text(data.subtitle,
                        style: TextStyle(
                            color: data.isAlert
                                ? Colors.orange
                                : Colors.grey.shade500,
                            fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                data.value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: data.color,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.drag_handle, color: Colors.grey, size: 18),
            ],
          ),
          if (data.target > 0) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: data.color.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(data.color),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${(progress * 100).round()}% of target',
                    style: TextStyle(
                        fontSize: 10, color: Colors.grey.shade500)),
                Text('Target: ${data.target}',
                    style: TextStyle(
                        fontSize: 10, color: Colors.grey.shade500)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActivityNote(DashboardProvider p) {
    if (p.error != null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.wifi_off_rounded, color: Colors.red.shade400, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Could not load live data: ${p.error}',
                style:
                    TextStyle(color: Colors.red.shade700, fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline,
              color: Colors.green.shade600, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Data fetched live from server  •  '
              '${p.totalUsers} total platform users',
              style:
                  TextStyle(color: Colors.green.shade800, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashCardData {
  final String key;
  final String title;
  final String value;
  final int target;
  final int current;
  final Color color;
  final IconData icon;
  final String subtitle;
  final bool isAlert;

  _DashCardData({
    required this.key,
    required this.title,
    required this.value,
    required this.target,
    required this.current,
    required this.color,
    required this.icon,
    required this.subtitle,
    this.isAlert = false,
  });
}
