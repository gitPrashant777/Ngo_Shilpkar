import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../auth/data/repository/user_repository.dart';

class OfflineBeneficiaryScreen extends StatefulWidget {
  const OfflineBeneficiaryScreen({super.key});

  @override
  State<OfflineBeneficiaryScreen> createState() =>
      _OfflineBeneficiaryScreenState();
}

class _OfflineBeneficiaryScreenState extends State<OfflineBeneficiaryScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserRepository _repository = UserRepository();

  List<String> _beneficiaryCategories = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _stateController =
      TextEditingController(text: 'Maharashtra');
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();
  String? _category;
  String? _gender;

  bool _loading = false;
  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _aadharController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    _villageController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _repository.getUserCategories();
      final names = categories
          .map((e) => (e['name'] ?? '').toString())
          .where((e) => e.isNotEmpty)
          .toList();
      if (mounted) {
        setState(() {
          _beneficiaryCategories = names;
        });
      }
    } catch (_) {
      if (mounted && _beneficiaryCategories.isEmpty) {
        setState(() {
          _beneficiaryCategories = [
            'FARMER',
            'STUDENT',
            'WOMEN',
            'WORKER',
            'CITIZEN',
          ];
        });
      }
    }
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final parsed = DateTime.tryParse(_dobController.text.trim());
    final initial = parsed ?? DateTime(now.year - 20, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked == null) return;
    final formatted =
        '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    _dobController.text = formatted;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final response = await _repository.createOfflineBeneficiary(
        name: _nameController.text.trim(),
        mobile: null,
        email: null,
        category: _category ?? '',
        dob: _dobController.text.trim(),
        gender: _gender,
        aadharNumber: _aadharController.text.trim(),
        state: _stateController.text.trim(),
        district: _districtController.text.trim(),
        village: _villageController.text.trim(),
      );

      final payload = response['data'] is Map<String, dynamic>
          ? response['data'] as Map<String, dynamic>
          : response;
      final username = payload['username']?.toString() ?? '';
      final password = payload['password']?.toString() ?? '';

      if (!mounted) return;
      _showSuccess(username, password);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSuccess(String username, String password) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Offline Member Created'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Username: $username'),
            const SizedBox(height: 6),
            Text('Password: $password'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(
                ClipboardData(text: 'Username: $username\nPassword: $password'),
              );
              Navigator.pop(context);
            },
            child: const Text('Copy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Offline Member'),
        backgroundColor: const Color(0xFF55789A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _field(_nameController, 'Full Name', validator: _required),
              _dobField(),
              _genderDropdown(),
              _categoryDropdown(),
              _field(_aadharController, 'Aadhar Number',
                  keyboardType: TextInputType.number),
              _field(_stateController, 'State', validator: _required),
              _field(_districtController, 'District', validator: _required),
              _field(_villageController, 'Village', validator: _required),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF55789A),
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Create Offline Member'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        key: ValueKey(_category),
        initialValue: _category,
        items: _beneficiaryCategories
            .map((value) => DropdownMenuItem(
                  value: value,
                  child: Text(value),
                ))
            .toList(),
        onChanged: (value) => setState(() => _category = value),
        validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
        decoration: const InputDecoration(
          labelText: 'Category',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _genderDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        key: ValueKey(_gender),
        initialValue: _gender,
        items: const [
          DropdownMenuItem(value: 'MALE', child: Text('MALE')),
          DropdownMenuItem(value: 'FEMALE', child: Text('FEMALE')),
          DropdownMenuItem(value: 'OTHER', child: Text('OTHER')),
        ],
        onChanged: (value) => setState(() => _gender = value),
        validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
        decoration: const InputDecoration(
          labelText: 'Gender',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _dobField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: _dobController,
        readOnly: true,
        onTap: _pickDob,
        validator: _required,
        decoration: const InputDecoration(
          labelText: 'DOB (YYYY-MM-DD)',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today_outlined),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;

}
