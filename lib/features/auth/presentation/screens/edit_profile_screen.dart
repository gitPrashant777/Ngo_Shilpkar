import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:shilpkar/core/constants/app_colors.dart';
import 'package:shilpkar/core/api/api_client.dart';
import 'package:shilpkar/features/auth/presentation/providers/auth_provider.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/services/location_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Personal
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();

  // Location
  String _state = 'Maharashtra';
  final _districtCtrl = TextEditingController();
  final _talukaCtrl = TextEditingController();
  final _villageCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  bool _isLocating = false;
  double? _latitude;
  double? _longitude;

  // Bank
  final _accountNameCtrl = TextEditingController();
  final _accountNumberCtrl = TextEditingController();
  final _ifscCtrl = TextEditingController();
  final _accountTypeCtrl = TextEditingController(); // Savings/Current
  final _upiIdCtrl = TextEditingController();

  File? _newAvatarFile;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final auth = context.read<AuthProvider>();
    final user = auth.userProfile?.user;
    final profile = auth.userProfile?.profile;

    if (profile != null) {
      _firstNameCtrl.text = profile.firstName ?? '';
      _lastNameCtrl.text = profile.lastName ?? '';
      _dobCtrl.text = profile.dob ?? '';

      _state = profile.location.state ?? 'Maharashtra';
      _districtCtrl.text = profile.location.district ?? '';
      _talukaCtrl.text = profile.location.taluka ?? '';
      _villageCtrl.text = profile.location.village ?? '';
      _addressCtrl.text = profile.location.address ?? '';

      _accountNameCtrl.text = profile.bankDetails.accountHolderName ?? '';
      _accountNumberCtrl.text = profile.bankDetails.accountNumber ?? '';
      _ifscCtrl.text = profile.bankDetails.ifsc ?? '';
      _accountTypeCtrl.text = profile.bankDetails.accountType ?? '';
      _upiIdCtrl.text = profile.bankDetails.upiId ?? '';
    }

    if (user != null) {
      _mobileCtrl.text = user.mobile ?? '';
      _emailCtrl.text = user.email ?? '';
    }
  }

  // Pick Date for DOB to fix format issues
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000), // Default view date
      firstDate: DateTime(1900), // Earliest allowable date
      lastDate: DateTime.now(), // Latest allowable date (today)
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        // Formats strictly to YYYY-MM-DD
        _dobCtrl.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _pickAvatar() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _newAvatarFile = File(result.files.single.path!);
      });
      await _uploadAvatar(_newAvatarFile!.path);
    }
  }

  Future<void> _uploadAvatar(String path) async {
    final success = await context.read<AuthProvider>().updateAvatar(path);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Avatar updated!")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.read<AuthProvider>().errorMessage ?? "Failed")));
    }
  }

  Future<void> _detectLocation() async {
    setState(() => _isLocating = true);

    try {
      final locData = await LocationService().detectAndResolveLocation();
      if (mounted) {
        setState(() {
          _latitude = locData['latitude'];
          _longitude = locData['longitude'];
          
          _state = locData['state'] ?? _state;
          _districtCtrl.text = locData['district'] ?? _districtCtrl.text;
          _talukaCtrl.text = locData['taluka'] ?? _talukaCtrl.text;
          _villageCtrl.text = locData['village'] ?? _villageCtrl.text;
          _addressCtrl.text = locData['autoAddress'] ?? _addressCtrl.text;
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location updated successfully!')));
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error detecting location: ${e.toString().replaceAll("Exception: ", "")}')));
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }


  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final user = auth.userProfile?.user;

    final isBeneficiary = user?.role == "BENEFICIARY";

    // Build location payload dynamically (only include filled fields)
    Map<String, dynamic> locationData = {};
    if (_state.isNotEmpty) locationData["state"] = _state;
    if (_districtCtrl.text.trim().isNotEmpty) locationData["district"] = _districtCtrl.text.trim();
    if (_talukaCtrl.text.trim().isNotEmpty) locationData["taluka"] = _talukaCtrl.text.trim();
    if (_villageCtrl.text.trim().isNotEmpty) locationData["village"] = _villageCtrl.text.trim();
    if (_addressCtrl.text.trim().isNotEmpty) locationData["address"] = _addressCtrl.text.trim();
    if (_latitude != null) locationData["latitude"] = _latitude;
    if (_longitude != null) locationData["longitude"] = _longitude;

    // Build bank payload dynamically (only include filled fields)
    Map<String, dynamic> bankData = {};
    if (_accountNameCtrl.text.trim().isNotEmpty) bankData["accountHolderName"] = _accountNameCtrl.text.trim();
    if (_accountNumberCtrl.text.trim().isNotEmpty) bankData["accountNumber"] = _accountNumberCtrl.text.trim();
    if (_ifscCtrl.text.trim().isNotEmpty) bankData["ifsc"] = _ifscCtrl.text.trim();
    if (_accountTypeCtrl.text.trim().isNotEmpty) bankData["accountType"] = _accountTypeCtrl.text.trim();
    if (_upiIdCtrl.text.trim().isNotEmpty) bankData["upiId"] = _upiIdCtrl.text.trim();

    // Build base profile dynamically
    final baseProfileData = {
      if (_firstNameCtrl.text.trim().isNotEmpty) "firstName": _firstNameCtrl.text.trim(),
      if (_lastNameCtrl.text.trim().isNotEmpty) "lastName": _lastNameCtrl.text.trim(),
      if (_dobCtrl.text.trim().isNotEmpty) "dob": _dobCtrl.text.trim(),
      if (locationData.isNotEmpty) "location": locationData,
      if (bankData.isNotEmpty) "bankDetails": bankData,
    };

    final data = {
      if (_emailCtrl.text.trim().isNotEmpty) "email": _emailCtrl.text.trim(),
      if (_mobileCtrl.text.trim().isNotEmpty) "mobile": _mobileCtrl.text.trim(),
      ...baseProfileData,
    };

    print("=========== PATCH /profile/me UPDATE PAYLOAD ===========");
    print(data);
    print("========================================================");

    final success = await auth.updateProfile(data);
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Updated!")));
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.read<AuthProvider>().errorMessage ?? "Failed")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final avatarUrl = auth.userProfile?.profile.avatarUrl;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: auth.isLoading ? null : _saveProfile,
            child: auth.isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text("Save", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: _newAvatarFile != null
                          ? FileImage(_newAvatarFile!)
                          : (avatarUrl != null ? NetworkImage(avatarUrl) : null) as ImageProvider?,
                      child: (_newAvatarFile == null && avatarUrl == null)
                          ? const Icon(Icons.person, size: 50, color: Colors.grey)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickAvatar,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primaryBlue,
                          child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionTitle("Personal Details"),
              if (auth.userProfile?.user?.username != null && auth.userProfile!.user!.username.isNotEmpty)
                _buildTextField("Beneficiary ID (Username)", null, initialValue: auth.userProfile!.user!.username, readOnly: true),
              Row(
                children: [
                  Expanded(child: _buildTextField("First Name", _firstNameCtrl)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField("Last Name", _lastNameCtrl)),
                ],
              ),

              // NEW: Date of Birth with DatePicker Trigger
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer( // Absorbs taps so keyboard doesn't open
                  child: _buildTextField("Date of Birth (YYYY-MM-DD)", _dobCtrl, readOnly: false), // readOnly styling isn't applied but keyboard blocked
                ),
              ),

              _buildTextField("Email", _emailCtrl),
              _buildTextField("Mobile", _mobileCtrl),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle("Location"),
                  TextButton.icon(
                    onPressed: _isLocating ? null : _detectLocation,
                    icon: _isLocating
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.my_location, size: 18),
                    label: Text(_isLocating ? "Detecting..." : "Auto Detect", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildTextField("State", null, initialValue: _state, readOnly: true),
              Row(
                children: [
                  Expanded(child: _buildTextField("District", _districtCtrl)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField("Taluka", _talukaCtrl)),
                ],
              ),
              _buildTextField("Village", _villageCtrl),
              _buildTextField("Address", _addressCtrl, maxLines: 2),

              const SizedBox(height: 24),
              _buildSectionTitle("Bank Details"),
              _buildTextField("Account Holder Name", _accountNameCtrl),
              _buildTextField("Account Number", _accountNumberCtrl),
              Row(
                children: [
                  Expanded(child: _buildTextField("IFSC Code", _ifscCtrl)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField("Account Type", _accountTypeCtrl)),
                ],
              ),
              _buildTextField("UPI ID", _upiIdCtrl),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.appBarBlue)),
          const SizedBox(height: 5),
          Container(height: 2, width: 36, color: AppColors.appBarBlue),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController? controller, {String? initialValue, bool readOnly = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF444444)),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            initialValue: controller == null ? initialValue : null,
            readOnly: readOnly,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              filled: true,
              fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.appBarBlue, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}