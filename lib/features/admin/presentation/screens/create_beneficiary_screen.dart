import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../auth/data/repository/user_repository.dart';
import 'SuperEmployeeSuccessScreen.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/form_fields.dart';
import '../../../../core/api/api_client.dart';

class CreateBeneficiaryScreen extends StatefulWidget {
  const CreateBeneficiaryScreen({super.key});

  @override
  State<CreateBeneficiaryScreen> createState() => _CreateBeneficiaryScreenState();
}

class _CreateBeneficiaryScreenState extends State<CreateBeneficiaryScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  bool _termsAccepted = false;
  bool _showTermsError = false;
  bool _loadingCategories = false;
  bool _onlineMode = true;
  bool _otpSent = false;
  String _onlineUsername = '';
  bool _otpVerified = false;
  bool _uploadingAadhar = false;

  List<String> _categories = [];

  // Controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final mobileController = TextEditingController();
  final dobController = TextEditingController();
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  final aadharController = TextEditingController();
  final aadharPhotoController = TextEditingController();
  final panController = TextEditingController();
  final panPhotoController = TextEditingController();
  final otpController = TextEditingController();
  bool _uploadingPan = false;

  String? selectedDistrict,
      selectedTaluka,
      selectedVillage,
      selectedCategory,
      selectedGender;

  final Map<String, List<String>> districtTalukaMap = {
    "Latur": ["Latur", "Ausa", "Nilanga"],
    "Pune": ["Haveli", "Shirur", "Mulshi"],
  };

  final Map<String, List<String>> talukaVillageMap = {
    "Latur": ["Village A", "Village B"],
    "Ausa": ["Village C", "Village D"],
    "Nilanga": ["Village E"],
    "Haveli": ["Village F"],
    "Shirur": ["Village G"],
    "Mulshi": ["Village H"],
  };

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _loadingCategories = true);
    try {
      final repo = UserRepository();
      final data = await repo.getUserCategories();
      final names = data
          .map((e) => (e['name'] ?? '').toString())
          .where((e) => e.isNotEmpty)
          .toList();
      if (mounted) {
        setState(() {
          _categories = names;
          _loadingCategories = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _categories = [
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

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    mobileController.dispose();
    dobController.dispose();
    passwordController.dispose();
    emailController.dispose();
    aadharController.dispose();
    aadharPhotoController.dispose();
    panController.dispose();
    panPhotoController.dispose();
    otpController.dispose();
    super.dispose();
  }

  // --- UI: MODERN PROGRESS BAR (Horizontal Lines) ---
  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: List.generate(3, (index) {
          bool section1 = firstNameController.text.isNotEmpty &&
              (_onlineMode ? mobileController.text.isNotEmpty : true);
          bool section2 = selectedDistrict != null;
          bool section3 = selectedCategory != null && selectedGender != null;

          Color getColor(int i) {
            if (i == 0 && section1) return AppColors.appBarBlue;
            if (i == 1 && section2) return AppColors.appBarBlue;
            if (i == 2 && section3) return AppColors.appBarBlue;
            return Colors.grey.shade300;
          }

          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: getColor(index),
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repository = UserRepository();
    final l10n = AppLocalizations.of(context)!;
    final primaryLabel = _onlineMode
        ? (_otpVerified ? 'Create Beneficiary' : 'Complete OTP First')
        : l10n.createBeneficiaryBtn;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(
          l10n.createBeneficiary,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgressBar(),
                Text(
                  l10n.registrationForm,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.appBarBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.completeAllSections,
                  style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
                ),
                const SizedBox(height: 24),

                _buildModeToggle(),
                const SizedBox(height: 16),

                // PERSONAL INFORMATION
                FormSectionHeader(l10n.personalInformation),
                LabeledTextField(
                  label: l10n.firstName,
                  controller: firstNameController,
                  onChanged: (_) => setState(() {}),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                LabeledTextField(
                  label: l10n.lastName,
                  controller: lastNameController,
                  onChanged: (_) => setState(() {}),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                _buildDobField(),
                _buildGenderDropdown(),
                if (_onlineMode)
                  LabeledTextField(
                    label: "Password*",
                    controller: passwordController,
                    obscureText: true,
                    validator: (v) =>
                        v == null || v.isEmpty ? "Required" : null,
                  ),

                // LOCATION
                FormSectionHeader(l10n.locationDetails),
                LabeledDropdown<String>(
                  label: "District*",
                  value: selectedDistrict,
                  items: districtTalukaMap.keys
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => setState(() {
                    selectedDistrict = val;
                    selectedTaluka = null;
                    selectedVillage = null;
                  }),
                  validator: (val) => val == null ? "Required" : null,
                ),
                if (!_onlineMode) ...[
                  LabeledDropdown<String>(
                    label: "Taluka*",
                    value: selectedTaluka,
                    items: (selectedDistrict == null
                            ? <String>[]
                            : districtTalukaMap[selectedDistrict!]!)
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedTaluka = val),
                    validator: (val) => val == null ? "Required" : null,
                  ),
                  LabeledDropdown<String>(
                    label: "Village*",
                    value: selectedVillage,
                    items: (selectedTaluka == null
                            ? <String>[]
                            : talukaVillageMap[selectedTaluka!]!)
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedVillage = val),
                    validator: (val) => val == null ? "Required" : null,
                  ),
                ],

                // OTHER DETAILS
                FormSectionHeader(l10n.otherInformation),
                LabeledDropdown<String>(
                  label: l10n.categoryField,
                  value: selectedCategory,
                  items: (_categories.isNotEmpty
                          ? _categories
                          : ["FARMER", "STUDENT", "WOMEN", "WORKER", "CITIZEN"])
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => setState(() => selectedCategory = val),
                  validator: (val) => val == null ? "Required" : null,
                ),
                LabeledTextField(
                  label: "Aadhar Number",
                  controller: aadharController,
                  keyboardType: TextInputType.number,
                ),
                _buildAadharUploadButton(),
                if (aadharPhotoController.text.trim().isNotEmpty)
                  _buildAadharPreview(),
                LabeledTextField(
                  label: "PAN Number",
                  controller: panController,
                ),
                _buildPanUploadButton(),
                if (panPhotoController.text.trim().isNotEmpty)
                  _buildPanPreview(),
                const SizedBox(height: 8),

                if (_onlineMode) ...[
                  FormSectionHeader('Phone Verification'),
                  LabeledTextField(
                    label: "Email",
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return "Required";
                      final emailOk = RegExp(
                              r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$')
                          .hasMatch(v.trim());
                      if (!emailOk) return "Invalid email";
                      return null;
                    },
                  ),
                  LabeledTextField(
                    label: l10n.mobile,
                    controller: mobileController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    suffixIcon: _otpVerified
                        ? const Icon(Icons.verified, color: Colors.green)
                        : null,
                    onChanged: (_) => setState(() {
                      _otpSent = false;
                      _otpVerified = false;
                      otpController.clear();
                    }),
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Required";
                      return (v.length != 10) ? "10 digits required" : null;
                    },
                  ),
                  if (!_otpVerified)
                    SizedBox(
                      height: 36,
                      child: OutlinedButton.icon(
                        onPressed: _isSubmitting ||
                                _otpVerified ||
                                mobileController.text.trim().length != 10
                            ? null
                            : () => _sendOnlineOtp(repository),
                        icon: const Icon(Icons.sms_outlined, size: 16),
                        label: const Text(
                          'Send OTP',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  if (_otpSent && !_otpVerified)
                    LabeledTextField(
                      label: "OTP*",
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? "Required" : null,
                    ),
                  if (_otpSent && !_otpVerified)
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 36,
                            child: OutlinedButton.icon(
                              onPressed: _isSubmitting ||
                                      _otpVerified ||
                                      otpController.text.trim().isEmpty
                                  ? null
                                  : () => _verifyOnlineOtp(repository),
                              icon: const Icon(Icons.verified_outlined, size: 16),
                              label: const Text(
                                'Verify OTP',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: _isSubmitting
                              ? null
                              : () => _resendOnlineOtp(repository),
                          child: const Text('Resend OTP'),
                        ),
                      ],
                    ),
                ],

                // TERMS AND CONDITIONS
                const FormSectionHeader('Terms & Conditions'),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF1E5799).withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Please read and accept the following terms:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF1E5799),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '1. All information provided must be accurate and truthful.\n'
                        '2. The beneficiary agrees to use foundation benefits only for intended purposes.\n'
                        '3. Any misuse of benefits will result in account suspension.\n'
                        '4. The foundation reserves the right to verify submitted information.\n'
                        '5. The beneficiary must notify the foundation of any changes in personal information.\n'
                        '6. Benefits are non-transferable and cannot be assigned to third parties.\n'
                        '7. The foundation\'s decisions regarding approvals are final.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // T&C Checkbox
                GestureDetector(
                  onTap: () => setState(() {
                    _termsAccepted = !_termsAccepted;
                    _showTermsError = false;
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: _termsAccepted
                          ? const Color(0xFFE8F5E9)
                          : (_showTermsError ? const Color(0xFFFFEBEE) : Colors.white),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _termsAccepted
                            ? Colors.green
                            : (_showTermsError ? Colors.red : Colors.grey.shade300),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _termsAccepted ? Icons.check_box : Icons.check_box_outline_blank,
                          color: _termsAccepted ? Colors.green : Colors.grey,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'I have read and agree to the Terms and Conditions of Shilpakar Foundation',
                            style: TextStyle(fontSize: 13, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (_showTermsError)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 4),
                    child: Text(
                      'You must accept the Terms & Conditions to proceed.',
                      style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                    ),
                  ),

                const SizedBox(height: 16),
                PrimaryFormButton(
                  label: primaryLabel,
                  isLoading: _isSubmitting,
                  onPressed: () async {
                    if (_onlineMode && !_otpVerified) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please verify OTP before continuing.'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                    if (!_termsAccepted) {
                      setState(() => _showTermsError = true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please accept the Terms & Conditions to proceed.'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                    if (_formKey.currentState!.validate()) {
                      await _submit(repository);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.completeRequiredFields),
                          backgroundColor: AppColors.errorRed,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit(UserRepository repository) async {
    setState(() => _isSubmitting = true);
    try {
      final name =
          '${firstNameController.text.trim()} ${lastNameController.text.trim()}'
              .trim();
      if (_onlineMode) {
        if (!_otpVerified) {
          throw Exception('Please verify OTP before submitting.');
        }
        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Account Created'),
              content: Text(_onlineUsername.isNotEmpty
                  ? 'Username: $_onlineUsername'
                  : 'Beneficiary created successfully.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        }
      } else {
        final res = await repository.createOfflineBeneficiary(
          name: name,
          mobile: mobileController.text.trim().isEmpty
              ? null
              : mobileController.text.trim(),
          email: emailController.text.trim().isEmpty
              ? null
              : emailController.text.trim(),
          category: selectedCategory ?? '',
          dob: dobController.text.trim(),
          gender: selectedGender,
          aadharNumber: aadharController.text.trim(),
          aadharPhotoUrl: aadharPhotoController.text.trim(),
          panNumber: panController.text.trim(),
          panPhotoUrl: panPhotoController.text.trim(),
          state: "Maharashtra",
          district: selectedDistrict ?? '',
          village: selectedVillage ?? '',
        );
        final user = res['user'] as Map<String, dynamic>? ?? {};
        final username = user['username']?.toString() ?? '';
        final password = res['generatedPassword']?.toString() ?? '';
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CoordinatorSuccessScreen(
                username: username,
                password: password,
              ),
            ),
          );
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.response?.data["message"] ?? "Error creating beneficiary"),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _sendOnlineOtp(UserRepository repository) async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete required fields before sending OTP.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final name =
          '${firstNameController.text.trim()} ${lastNameController.text.trim()}'
              .trim();
      final res = await repository.initiateOnlineBeneficiary(
        name: name,
        mobile: mobileController.text.trim(),
        email: emailController.text.trim(),
        dob: dobController.text.trim(),
        gender: selectedGender ?? '',
        category: selectedCategory ?? '',
        password: passwordController.text.trim(),
        state: "Maharashtra",
        district: selectedDistrict ?? '',
        taluka: selectedTaluka,
        aadharNumber: aadharController.text.trim(),
        aadharPhotoUrl: aadharPhotoController.text.trim(),
        panNumber: panController.text.trim(),
        panPhotoUrl: panPhotoController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _otpSent = true;
        _onlineUsername = res['username']?.toString() ?? '';
      });
      final msg = res['message']?.toString() ?? 'OTP sent.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.response?.data["message"] ?? "Failed to send OTP"),
          backgroundColor: AppColors.errorRed,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.errorRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _resendOnlineOtp(UserRepository repository) async {
    final mobile = mobileController.text.trim();
    if (mobile.isEmpty || mobile.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10-digit mobile number.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await repository.resendOnlineBeneficiaryOtp(mobile: mobile);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP resent successfully.')),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.response?.data["message"] ?? "Failed to resend OTP"),
          backgroundColor: AppColors.errorRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _verifyOnlineOtp(UserRepository repository) async {
    final otp = otpController.text.trim();
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter OTP to verify.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await repository.verifyOnlineBeneficiary(
        mobile: mobileController.text.trim(),
        otp: otp,
      );
      if (!mounted) return;
      setState(() => _otpVerified = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP verified. You can submit now.')),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.response?.data["message"] ?? "Failed to verify OTP"),
          backgroundColor: AppColors.errorRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildModeToggle() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _onlineMode = true;
                _otpSent = false;
                _otpVerified = false;
                otpController.clear();
              }),
              child: _modeChip(
                title: 'Online (OTP)',
                selected: _onlineMode,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _onlineMode = false;
                _otpSent = false;
                _otpVerified = false;
                otpController.clear();
              }),
              child: _modeChip(
                title: 'Offline',
                selected: !_onlineMode,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeChip({required String title, required bool selected}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: selected ? AppColors.appBarBlue : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selected ? AppColors.appBarBlue : Colors.grey.shade300,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        style: TextStyle(
          color: selected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildDobField() {
    return LabeledTextField(
      label: 'DOB*',
      controller: dobController,
      readOnly: true,
      onTap: _pickDob,
      validator: (v) => v == null || v.isEmpty ? "Required" : null,
      suffixIcon: const Icon(Icons.calendar_today_outlined),
    );
  }

  Widget _buildGenderDropdown() {
    return LabeledDropdown<String>(
      label: 'Gender*',
      value: selectedGender,
      items: const [
        DropdownMenuItem(value: 'MALE', child: Text('MALE')),
        DropdownMenuItem(value: 'FEMALE', child: Text('FEMALE')),
        DropdownMenuItem(value: 'OTHER', child: Text('OTHER')),
      ],
      onChanged: (val) => setState(() => selectedGender = val),
      validator: (val) => val == null ? "Required" : null,
    );
  }

  Widget _buildAadharUploadButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _uploadingAadhar ? null : _pickAadharFromCamera,
        icon: _uploadingAadhar
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.camera_alt_outlined),
        label: Text(
          _uploadingAadhar ? 'Uploading...' : 'Upload Aadhar (Camera)',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildAadharPreview() {
    final url = aadharPhotoController.text.trim();
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              url,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 56,
                height: 56,
                color: Colors.grey.shade200,
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported_outlined,
                    color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Aadhar photo uploaded',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () => setState(() {
              aadharPhotoController.clear();
            }),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Widget _buildPanUploadButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _uploadingPan ? null : _pickPanFromCamera,
        icon: _uploadingPan
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.camera_alt_outlined),
        label: Text(
          _uploadingPan ? 'Uploading...' : 'Upload PAN (Camera)',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildPanPreview() {
    final url = panPhotoController.text.trim();
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              url,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 56,
                height: 56,
                color: Colors.grey.shade200,
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported_outlined,
                    color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'PAN photo uploaded',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () => setState(() {
              panPhotoController.clear();
            }),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickPanFromCamera() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (photo == null) return;
    await _uploadPan(photo.path);
  }

  Future<void> _uploadPan(String path) async {
    setState(() => _uploadingPan = true);
    try {
      final fileName = path.split(RegExp(r'[\\/]')).last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(path, filename: fileName),
        'module': 'beneficiaries',
      });
      final response = await ApiClient().dio.post(
        '/uploads',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final url =
          response.data['url']?.toString() ??
          response.data['data']?['url']?.toString() ??
          '';
      if (url.isEmpty) {
        throw Exception('Upload failed. Please try again.');
      }
      if (mounted) {
        setState(() {
          panPhotoController.text = url;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PAN photo uploaded.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _uploadingPan = false);
    }
  }
  Future<void> _pickAadharFromCamera() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (photo == null) return;
    await _uploadAadhar(photo.path);
  }

  Future<void> _uploadAadhar(String path) async {
    setState(() => _uploadingAadhar = true);
    try {
      final fileName = path.split(RegExp(r'[\\/]')).last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(path, filename: fileName),
        'module': 'beneficiaries',
      });
      final response = await ApiClient().dio.post(
        '/uploads',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final url =
          response.data['url']?.toString() ??
          response.data['data']?['url']?.toString() ??
          '';
      if (url.isEmpty) {
        throw Exception('Upload failed. Please try again.');
      }
      if (mounted) {
        setState(() {
          aadharPhotoController.text = url;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aadhar photo uploaded.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _uploadingAadhar = false);
    }
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final parsed = DateTime.tryParse(dobController.text.trim());
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
    dobController.text = formatted;
  }
}
