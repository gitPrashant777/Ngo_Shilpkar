import 'package:flutter/material.dart';
import '../../../auth/data/repository/user_repository.dart';

class CashSettlementScreen extends StatefulWidget {
  const CashSettlementScreen({super.key});

  @override
  State<CashSettlementScreen> createState() => _CashSettlementScreenState();
}

class _CashSettlementScreenState extends State<CashSettlementScreen> {
  final UserRepository _repository = UserRepository();

  bool _loading = false;
  String? _error;
  List<Map<String, dynamic>> _requests = [];

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await _repository.getCashRequests(status: 'PENDING');
      final payload = response['data'] is Map<String, dynamic>
          ? response['data'] as Map<String, dynamic>
          : response;
      final list = payload['data'] is List
          ? payload['data'] as List
          : payload['requests'] is List
              ? payload['requests'] as List
              : payload['items'] is List
                  ? payload['items'] as List
                  : <dynamic>[];

      setState(() {
        _requests = list
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _approve(Map<String, dynamic> request) async {
    final id = (request['_id'] ?? request['id'] ?? '').toString();
    if (id.isEmpty) return;

    try {
      await _repository.approveCashRequest(id);
      await _fetchRequests();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cash settlement approved')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  String _nameOf(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is Map) {
      final first = value['firstName'] ?? '';
      final last = value['lastName'] ?? '';
      final combined = '$first $last'.trim();
      return combined.isNotEmpty ? combined : value['name']?.toString() ?? '';
    }
    return value?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF55789A),
        foregroundColor: Colors.white,
        title: const Text('Pending Cash Settlements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchRequests,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _requests.isEmpty
                  ? const Center(child: Text('No pending cash requests'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _requests.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final req = _requests[index];
                        final amount = req['amount']?.toString() ?? '-';
                        final module = req['module']?.toString() ?? '-';
                        final collector = _nameOf(req, 'collector');
                        final beneficiary = _nameOf(req, 'beneficiary');
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                beneficiary.isNotEmpty
                                    ? beneficiary
                                    : 'Beneficiary',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text('Collector: ${collector.isNotEmpty ? collector : '-'}'),
                              Text('Module: $module'),
                              Text('Amount: ₹$amount'),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => _approve(req),
                                  child: const Text('Approve'),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}
