import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../auth/data/repository/user_repository.dart';

class OnlineBeneficiaryScreen extends StatefulWidget {
  const OnlineBeneficiaryScreen({super.key});

  @override
  State<OnlineBeneficiaryScreen> createState() => _OnlineBeneficiaryScreenState();
}

class _OnlineBeneficiaryScreenState extends State<OnlineBeneficiaryScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserRepository _repository = UserRepository();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _stateController =
      TextEditingController(text: 'Maharashtra');
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _aadharPhotoController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  String? _category;
  String? _gender;
  List<String> _categories = [];
  bool _loading = false;
  bool _otpSent = false;
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _passwordController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    _aadharController.dispose();
    _aadharPhotoController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final data = await _repository.getUserCategories();
      final names = data
          .map((e) => (e['name'] ?? '').toString())
          .where((e) => e.isNotEmpty)
          .toList();
      if (mounted) {
        setState(() => _categories = names);
      }
    } catch (_) {
      if (mounted && _categories.isEmpty) {
        setState(() {
          _categories = ["FARMER", "STUDENT", "WOMEN", "WORKER", "CITIZEN"];
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

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final res = await _repository.initiateOnlineBeneficiary(
        name: _nameController.text.trim(),
        mobile: _mobileController.text.trim(),
        email: _emailController.text.trim(),
        dob: _dobController.text.trim(),
        gender: _gender ?? '',
        category: _category ?? '',
        password: _passwordController.text.trim(),
        state: _stateController.text.trim(),
        district: _districtController.text.trim(),
        aadharNumber: _aadharController.text.trim(),
        aadharPhotoUrl: _aadharPhotoController.text.trim(),
      );
      final username = res['username']?.toString() ?? '';
      if (mounted) {
        setState(() {
          _otpSent = true;
          _username = username;
        });
        final msg = res['message']?.toString() ?? 'OTP sent.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter OTP.')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await _repository.verifyOnlineBeneficiary(
        mobile: _mobileController.text.trim(),
        otp: otp,
      );
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Account Verified'),
          content: Text(_username.isNotEmpty
              ? 'Username: $_username'
              : 'Beneficiary verified successfully.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resendOtp() async {
    final mobile = _mobileController.text.trim();
    if (mobile.isEmpty || mobile.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid mobile number.')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await _repository.resendOnlineBeneficiaryOtp(mobile: mobile);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP resent successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Beneficiary (Online)'),
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
              _field(_mobileController, 'Mobile',
                  keyboardType: TextInputType.number,
                  validator: _required,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ]),
              _field(_emailController, 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: _emailRequired),
              _dobField(),
              _genderDropdown(),
              _categoryDropdown(),
              _field(_passwordController, 'Password',
                  keyboardType: TextInputType.visiblePassword,
                  validator: _required,
                  obscureText: true),
              _field(_stateController, 'State', validator: _required),
              _field(_districtController, 'District', validator: _required),
              _field(_aadharController, 'Aadhar Number',
                  keyboardType: TextInputType.number),
              _field(_aadharPhotoController, 'Aadhar Photo URL'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _sendOtp,
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
                      : const Text('Send OTP'),
                ),
              ),
              if (_otpSent) ...[
                const SizedBox(height: 16),
                _field(_otpController, 'OTP',
                    keyboardType: TextInputType.number),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _loading ? null : _verifyOtp,
                    child: const Text('Verify OTP'),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _loading ? null : _resendOtp,
                    child: const Text('Resend OTP'),
                  ),
                ),
              ],
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
        items: (_categories.isNotEmpty
                ? _categories
                : ["FARMER", "STUDENT", "WOMEN", "WORKER", "CITIZEN"])
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
    bool obscureText = false,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        obscureText: obscureText,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;

  String? _emailRequired(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    final ok = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$')
        .hasMatch(value.trim());
    return ok ? null : 'Invalid email';
  }
}
