import 'package:flutter/material.dart';
import '../../../auth/data/repository/user_repository.dart';

class DeletionManagementScreen extends StatefulWidget {
  const DeletionManagementScreen({super.key});

  @override
  State<DeletionManagementScreen> createState() =>
      _DeletionManagementScreenState();
}

class _DeletionManagementScreenState extends State<DeletionManagementScreen>
    with SingleTickerProviderStateMixin {
  final UserRepository _repository = UserRepository();

  late TabController _tabController;
  bool _loading = false;
  String? _error;

  List<Map<String, dynamic>> _deletionRequests = [];
  List<Map<String, dynamic>> _deactivated = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final requests = await _repository.getDeletionRequests();
      final history = await _repository.getDeactivatedHistory();

      setState(() {
        _deletionRequests = _extractUsers(requests);
        _deactivated = _extractUsers(history);
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> _extractUsers(Map<String, dynamic> response) {
    final payload = response['data'] is Map<String, dynamic>
        ? response['data'] as Map<String, dynamic>
        : response;

    final candidates = [
      payload['users'],
      payload['data'],
      payload['items'],
      payload['results'],
    ];

    for (final candidate in candidates) {
      if (candidate is List) {
        return candidate
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }
    return <Map<String, dynamic>>[];
  }

  String _nameOf(Map<String, dynamic> user) {
    final first = (user['firstName'] ?? user['profile']?['firstName'] ?? '')
        .toString()
        .trim();
    final last = (user['lastName'] ?? user['profile']?['lastName'] ?? '')
        .toString()
        .trim();
    final combined = '$first $last'.trim();
    return combined.isNotEmpty
        ? combined
        : (user['name'] ?? user['username'] ?? 'Unknown').toString();
  }

  String _roleOf(Map<String, dynamic> user) =>
      (user['role'] ?? user['profile']?['role'] ?? '-').toString();

  String _idOf(Map<String, dynamic> user) =>
      (user['_id'] ?? user['id'] ?? '').toString();

  Future<void> _approveDeletion(Map<String, dynamic> user) async {
    final userId = _idOf(user);
    if (userId.isEmpty) return;

    final response = await _repository.approveDeletion(userId);
    final success = response['success'] != false;
    final pending = response['pending'] is List ? response['pending'] as List : const [];

    if (pending.isNotEmpty) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Deletion Blocked'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pending items must be cleared before deletion:'),
              const SizedBox(height: 8),
              ...pending.map((item) => Text('• $item')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if (success) {
      await _fetchAll();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account deactivated')),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message']?.toString() ?? 'Failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF55789A),
        foregroundColor: Colors.white,
        title: const Text('Deleted Accounts'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Deletion Requests'),
            Tab(text: 'Deactivated History'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAll,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRequestList(),
                    _buildHistoryList(),
                  ],
                ),
    );
  }

  Widget _buildRequestList() {
    if (_deletionRequests.isEmpty) {
      return const Center(child: Text('No deletion requests'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _deletionRequests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final user = _deletionRequests[index];
        return _buildUserCard(
          user,
          trailing: ElevatedButton(
            onPressed: () => _approveDeletion(user),
            child: const Text('Approve'),
          ),
        );
      },
    );
  }

  Widget _buildHistoryList() {
    if (_deactivated.isEmpty) {
      return const Center(child: Text('No deactivated accounts'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _deactivated.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final user = _deactivated[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, {Widget? trailing}) {
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
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFE67E22).withValues(alpha: 0.12),
            child: Text(_nameOf(user).characters.first.toUpperCase()),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nameOf(user),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _roleOf(user),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
