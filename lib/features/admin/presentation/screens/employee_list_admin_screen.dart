import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shilpkar/core/constants/user_roles.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../auth/data/repository/user_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/profile_screen.dart';
import '../../../chat/presentation/screens/chat_room_screen.dart';
import '../../../ecommerce/presentation/screens/admin/admin_category_management_screen.dart';
import '../../../notifications/presentation/screens/notification_screen.dart';
import 'deletion_management_screen.dart';

class EmployeeListAdminScreen extends StatefulWidget {
  final String? initialRole;

  const EmployeeListAdminScreen({super.key, this.initialRole});

  @override
  State<EmployeeListAdminScreen> createState() =>
      _EmployeeListAdminScreenState();
}

class _EmployeeListAdminScreenState extends State<EmployeeListAdminScreen> {
  static const int _pageSize = 20;

  final UserRepository _repository = UserRepository();
  final TextEditingController _searchController = TextEditingController();

  // Removed _searchDebounce as it's no longer used

  List<Map<String, dynamic>> _users = [];
  bool _loading = false;
  bool _detailsLoading = false;
  bool _loadingCategories = false;
  String? _error;

  int _page = 1;
  int _totalPages = 1;
  int _total = 0;

  String? _selectedRole;
  String? _selectedDistrict;
  String? _selectedTaluka;
  String? _selectedCategory;
  bool? _verifiedFilter;

  List<String> _categoryOptions = [];

  final List<String?> _roleOptions = [
    null,
    UserRole.field,
    UserRole.coordinator,
    UserRole.districtCoordinator,
    UserRole.talukaCoordinator,
    UserRole.villageCoordinator,
    UserRole.beneficiary,
  ];

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole;
    _fetchCommunity();
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() => _loadingCategories = true);
    try {
      final data = await _repository.getUserCategories();
      final names = data
          .map((e) => (e['name'] ?? '').toString())
          .where((e) => e.isNotEmpty)
          .toList();
      if (mounted) {
        setState(() {
          _categoryOptions = names;
          _loadingCategories = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _categoryOptions = [
            "FARMER",
            "STUDENT",
            "WOMEN",
            "WORKER",
            "CITIZEN",
          ];
          _loadingCategories = false;
        });
      }
    }
  }

  Future<void> _fetchCommunity({int? page}) async {
    setState(() {
      _loading = true;
      _error = null;
      if (page != null) _page = page;
    });

    try {
      final isBeneficiaryOnly = _selectedRole == UserRole.beneficiary;
      final response = isBeneficiaryOnly
          ? await _repository.getBeneficiariesPage(
              page: _page,
              limit: _pageSize,
              search: _searchController.text.trim(),
              category: _selectedCategory,
            )
          : await _repository.getCommunityUsers(
              page: _page,
              limit: _pageSize,
              role: _selectedRole,
              search: _searchController.text.trim(),
              district: _selectedDistrict,
              taluka: _selectedTaluka,
              category: _selectedCategory,
              verified: _verifiedFilter,
            );

      final payload = _extractPayload(response);
      final users = _extractUsers(payload);

      if (!mounted) return;
      setState(() {
        _users = users;
        _total = _readInt(payload, ['total', 'count'], fallback: users.length);
        _totalPages =
            _readInt(payload, ['totalPages', 'pages'], fallback: 1).clamp(1, 999999);
        _page = _readInt(payload, ['page', 'currentPage'], fallback: _page)
            .clamp(1, _totalPages);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Map<String, dynamic> _extractPayload(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is Map<String, dynamic>) return data;
    return response;
  }

  List<Map<String, dynamic>> _extractUsers(Map<String, dynamic> payload) {
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

  int _readInt(
    Map<String, dynamic> payload,
    List<String> keys, {
    required int fallback,
  }) {
    for (final key in keys) {
      final value = payload[key];
      if (value is int) return value;
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return fallback;
  }

  List<String> _distinctValues(String key) {
    final values = _users
        .map((user) => _stringValue(user[key]))
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return values;
  }

  String _stringValue(dynamic value) => value?.toString().trim() ?? '';

  String _nameOf(Map<String, dynamic> user) {
    final profile = _profileMap(user);
    final firstName =
        _firstNonEmpty([user['firstName'], profile['firstName']]);
    final lastName = _firstNonEmpty([user['lastName'], profile['lastName']]);
    final combined = '$firstName $lastName'.trim();
    return combined.isNotEmpty
        ? combined
        : _firstNonEmpty([
            user['name'],
            user['fullName'],
            user['username'],
            profile['username'],
            'Unknown',
          ]);
  }

  String _roleOf(Map<String, dynamic> user) => _firstNonEmpty([
        user['role'],
        _profileMap(user)['employeeType'],
      ]);

  String _displayRoleOf(Map<String, dynamic> user) {
    final role = _roleOf(user);
    if (role.isEmpty) return 'Community';
    return UserRole.displayName(role);
  }

  String _phoneOf(Map<String, dynamic> user) => _firstNonEmpty([
        user['mobile'],
        user['mobileNumber'],
        user['phone'],
        _profileMap(user)['mobile'],
      ]);

  String _districtOf(Map<String, dynamic> user) => _firstNonEmpty([
        user['district'],
        _profileMap(user)['district'],
      ]);

  String _talukaOf(Map<String, dynamic> user) => _firstNonEmpty([
        user['taluka'],
        _profileMap(user)['taluka'],
      ]);

  String _categoryOf(Map<String, dynamic> user) => _firstNonEmpty([
        user['category'],
        _profileMap(user)['category'],
      ]);

  bool _isVerifiedOf(Map<String, dynamic> user) {
    final value = user['isVerified'] ?? _profileMap(user)['isVerified'];
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return true;
  }

  bool _isSuperAdmin() {
    final role = context.read<AuthProvider>().role;
    return role == UserRole.superAdmin;
  }

  String _usernameOf(Map<String, dynamic> user) => _firstNonEmpty([
        user['username'],
        _profileMap(user)['username'],
      ]);

  String _emailOf(Map<String, dynamic> user) => _firstNonEmpty([
        user['email'],
        user['emailAddress'],
        _profileMap(user)['email'],
      ]);

  String _stateOf(Map<String, dynamic> user) => _firstNonEmpty([
        user['state'],
        _profileMap(user)['state'],
      ]);

  Map<String, dynamic> _profileMap(Map<String, dynamic> user) {
    final profile = user['profile'];
    if (profile is Map<String, dynamic>) return profile;
    if (profile is Map) return Map<String, dynamic>.from(profile);
    return const {};
  }

  String _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      final normalized = _stringValue(value);
      if (normalized.isNotEmpty) return normalized;
    }
    return '';
  }

  String _userIdOf(Map<String, dynamic> user) => _firstNonEmpty([
        user['_id'],
        user['id'],
        _profileMap(user)['_id'],
        _profileMap(user)['id'],
      ]);

  Color _roleColor(String role) {
    switch (role) {
      case UserRole.beneficiary:
        return const Color(0xFFE67E22);
      case UserRole.coordinator:
      case UserRole.districtCoordinator:
      case UserRole.talukaCoordinator:
      case UserRole.villageCoordinator:
        return const Color(0xFF7E57C2);
      default:
        return const Color(0xFF2E7D32);
    }
  }

  // Removed _updateSearch as search bar is now part of the filter section if needed

  Future<void> _openProfile(Map<String, dynamic> user) async {
    final userId = _userIdOf(user);
    if (userId.isEmpty) return;

    setState(() {
      _detailsLoading = true;
    });

    try {
      final response = await _repository.getCommunityProfile(userId);
      if (!mounted) return;
      final payload = _extractPayload(response);
      _showProfileSheet(payload.isEmpty ? user : payload);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _detailsLoading = false;
        });
      }
    }
  }

  void _showProfileSheet(Map<String, dynamic> profile) {
    final role = _roleOf(profile);
    final displayRole = _displayRoleOf(profile);
    final color = _roleColor(role);
    final bankDetails = _profileMap(profile)['bankDetails'];
    final bank = bankDetails is Map ? Map<String, dynamic>.from(bankDetails) : const {};
    final isOffline =
        profile['isOffline'] == true || _profileMap(profile)['isOffline'] == true;
    final isCashAccount = profile['isCashAccount'] == true ||
        _profileMap(profile)['isCashAccount'] == true;
    final canCollectCash = isOffline || isCashAccount;
    final isVerified = _isVerifiedOf(profile);
    final canVerify = _isSuperAdmin() && !isVerified;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: color.withValues(alpha: 0.14),
                      child: Text(
                        _nameOf(profile).characters.first.toUpperCase(),
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _nameOf(profile),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            displayRole,
                            style: TextStyle(color: color, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _detailRow(Icons.badge_outlined, 'Username', _usernameOf(profile)),
                _detailRow(Icons.phone_outlined, 'Mobile', _phoneOf(profile)),
                _detailRow(Icons.email_outlined, 'Email', _emailOf(profile)),
                _detailRow(Icons.location_on_outlined, 'State', _stateOf(profile)),
                _detailRow(Icons.location_city_outlined, 'District', _districtOf(profile)),
                _detailRow(Icons.map_outlined, 'Taluka', _talukaOf(profile)),
                _detailRow(Icons.place_outlined, 'Village', _firstNonEmpty([
                  profile['village'],
                  _profileMap(profile)['village'],
                ])),
                _detailRow(Icons.category_outlined, 'Category', _categoryOf(profile)),
                _detailRow(Icons.credit_card_outlined, 'Aadhar Number', _firstNonEmpty([
                  profile['aadharNumber'],
                  _profileMap(profile)['aadharNumber'],
                ])),
                _detailImageRow(
                  'Aadhar Photo',
                  _firstNonEmpty([
                    profile['aadharPhotoUrl'],
                    _profileMap(profile)['aadharPhotoUrl'],
                  ]),
                ),
                _detailRow(Icons.badge_outlined, 'PAN Number', _firstNonEmpty([
                  profile['panNumber'],
                  _profileMap(profile)['panNumber'],
                ])),
                _detailImageRow(
                  'PAN Photo',
                  _firstNonEmpty([
                    profile['panPhotoUrl'],
                    _profileMap(profile)['panPhotoUrl'],
                  ]),
                ),
                _detailRow(Icons.cake_outlined, 'DOB', _firstNonEmpty([
                  profile['dob'],
                  _profileMap(profile)['dob'],
                ])),
                _detailRow(Icons.home_outlined, 'Address', _firstNonEmpty([
                  profile['address'],
                  _profileMap(profile)['address'],
                ])),
                _detailRow(Icons.account_balance_outlined, 'Account Number',
                    _stringValue(bank['accountNumber'])),
                _detailRow(Icons.person_outline, 'Account Holder',
                    _stringValue(bank['accountHolderName'])),
                _detailRow(Icons.qr_code_outlined, 'IFSC', _stringValue(bank['ifsc'])),
                _detailRow(Icons.wallet_outlined, 'Account Type',
                    _stringValue(bank['accountType'])),
                if (canVerify) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await _verifyUser(profile);
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.verified_outlined),
                      label: const Text('Verify Account'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
                if (canCollectCash) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showCashRequestDialog(profile),
                      icon: const Icon(Icons.currency_rupee_outlined),
                      label: const Text('Collect Cash'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showCashRequestDialog(Map<String, dynamic> profile) async {
    final beneficiaryId = _userIdOf(profile);
    if (beneficiaryId.isEmpty) return;

    final amountController = TextEditingController();
    final moduleController = TextEditingController(text: 'ONBOARDING');
    final refController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Collect Cash'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount (INR)'),
            ),
            TextField(
              controller: moduleController,
              decoration: const InputDecoration(labelText: 'Module'),
            ),
            TextField(
              controller: refController,
              decoration: const InputDecoration(labelText: 'Module Ref ID'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = num.tryParse(amountController.text.trim());
              if (amount == null) return;

              try {
                await _repository.requestCashSettlement(
                  beneficiaryId: beneficiaryId,
                  amount: amount,
                  module: moduleController.text.trim(),
                  moduleRefId: refController.text.trim(),
                );
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cash request submitted')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text(e.toString().replaceAll('Exception: ', ''))),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade500),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailImageRow(String label, String url) {
    if (url.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.image_outlined, size: 16, color: Colors.grey.shade500),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    url,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 120,
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported_outlined,
                          color: Colors.grey),
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

  Future<void> _startChat(Map<String, dynamic> user) async {
    final userId = _userIdOf(user);
    if (userId.isEmpty) return;
    final requesterId = context.read<AuthProvider>().userId ?? '';
    if (requesterId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login again to start chat.')),
      );
      return;
    }

    try {
      final response = await _repository.startCommunityChat(
        userId,
        topic: _nameOf(user),
        requesterId: requesterId,
      );
      final payload = _extractPayload(response);
      final chatData = payload['data'] is Map<String, dynamic>
          ? payload['data'] as Map<String, dynamic>
          : payload;
      final sessionId = _firstNonEmpty([
        chatData['_id'],
        chatData['id'],
        payload['_id'],
        payload['id'],
      ]);

      if (!mounted) return;
      if (sessionId.isEmpty) {
        throw Exception('Chat session was not returned by the server.');
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatRoomScreen(
            sessionId: sessionId,
            topic: _nameOf(user),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _verifyUser(Map<String, dynamic> user) async {
    final userId = _userIdOf(user);
    if (userId.isEmpty) return;

    try {
      await _repository.verifyUser(userId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account verified')),
      );
      _fetchCommunity(page: _page);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E5799),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'View Community',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const NotificationScreen()),
                  );
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                  child: const Text(
                    '4',
                    style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.account_circle, size: 32),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: Row(
              children: [
                const Text(
                  'Community Members',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const Spacer(),
                Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Total: $_total',
                    style: const TextStyle(
                      color: Color(0xFF1E5799),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_detailsLoading) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildErrorState()
                    : _buildList(),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildBottomActions(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.filter_list, size: 18, color: Color(0xFF1E5799)),
              SizedBox(width: 8),
              Text(
                'Filters',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E5799),
                ),
              ),
            ],
          ),
          const SizedBox(height: 0),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 5,
            crossAxisSpacing: 5,
            childAspectRatio: 4.4,
            children: [
              _filterDropdown(
                hint: 'District',
                value: _selectedDistrict,
                items: ['District 1', 'District 2'], // Should be dynamic
                onChanged: (v) => setState(() => _selectedDistrict = v),
              ),
              _filterDropdown(
                hint: 'Taluka',
                value: _selectedTaluka,
                items: ['Taluka 1', 'Taluka 2'], // Should be dynamic
                onChanged: (v) => setState(() => _selectedTaluka = v),
              ),
              _filterDropdown(
                hint: 'Role',
                value: _selectedRole,
                items:
                    _roleOptions.where((r) => r != null).map((r) => r!).toList(),
                onChanged: (v) => setState(() => _selectedRole = v),
              ),
              _filterDropdown(
                hint: 'Category',
                value: _selectedCategory,
                items: (_categoryOptions.isNotEmpty
                        ? _categoryOptions
                        : ["FARMER", "STUDENT", "WOMEN", "WORKER", "CITIZEN"])
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
              ),
            ],
          ),
          InkWell(
            onTap: () => _fetchCommunity(page: 1),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF1E5799)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2196F3).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.filter_list, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Apply Filter',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      color: const Color(0xFFF8F9FB),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _openDeletionManagement,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_outline, color: Colors.red, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Deleted Accounts',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AdminCategoryManagementScreen()),
                    );
                  },
                  icon: const Icon(Icons.add_box_outlined, size: 18),
                  label:
                      const Text('Create Category', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A085),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(hint, style: const TextStyle(fontSize: 12)),
          value: value,
          items: [
            ...items.map(
              (item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, size: 52, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          Text(
            _error ?? 'Something went wrong',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _fetchCommunity(page: 1),
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_users.isEmpty) {
      return const Center(
        child: Text(
          'No community members found',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
      itemCount: _users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _buildUserCard(_users[index]),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final role = _roleOf(user);
    final roleLabel = _displayRoleOf(user);
    final roleColor = _roleColor(role);
    final village = _firstNonEmpty([
      user['village'],
      _profileMap(user)['village'],
    ]);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: roleColor.withOpacity(0.1),
            child: Text(
              _nameOf(user).characters.first.toUpperCase(),
              style: TextStyle(
                color: roleColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nameOf(user),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.person, size: 14, color: Colors.blue.shade400),
                    const SizedBox(width: 4),
                    Text(
                      roleLabel,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.blue.shade900),
                    const SizedBox(width: 4),
                    Text(
                      'Village: ${village.isNotEmpty ? village : "Unknown"}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _openProfile(user),
          ),
        ],
      ),
    );
  }

  void _openDeletionManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DeletionManagementScreen()),
    );
  }
}
