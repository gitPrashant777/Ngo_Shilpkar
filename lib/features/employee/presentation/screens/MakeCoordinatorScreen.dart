import 'package:flutter/material.dart';

import '../../../auth/data/repository/user_repository.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/form_fields.dart';
import '../../../../core/services/location_service.dart';

class MakeCoordinatorScreen extends StatefulWidget {
  const MakeCoordinatorScreen({super.key});

  @override
  State<MakeCoordinatorScreen> createState() =>
      _MakeCoordinatorScreenState();
}

class _MakeCoordinatorScreenState extends State<MakeCoordinatorScreen> {
  int _currentStep = 1;

  final _formKey = GlobalKey<FormState>();

  // STEP 1 Controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // STEP 2 Controllers
  final TextEditingController stateController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController talukaController = TextEditingController();
  final TextEditingController villageController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // STEP 3 Controllers
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController accountHolderController = TextEditingController();
  final TextEditingController ifscController = TextEditingController();
  final TextEditingController accountTypeController = TextEditingController();
  final TextEditingController upiController = TextEditingController();

  final UserRepository _repository = UserRepository();

  bool _isLoading = false;
  bool _isLocating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Shilpkar Foundation",
          style: TextStyle(
            color: AppColors.appBarBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Make Coordinator",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getStepTitle(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildCurrentStep(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 1:
        return "Coordinator Details (Step 1 of 3)";
      case 2:
        return "Location Details (Step 2 of 3)";
      case 3:
        return "Bank Details (Step 3 of 3)";
      default:
        return "Coordinator Details";
    }
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 1:
        return _buildDetailsStep();
      case 2:
        return _buildLocationStep();
      case 3:
        return _buildBankStep();
      default:
        return _buildDetailsStep();
    }
  }

  // ---------------- STEP 1 ----------------
  Widget _buildDetailsStep() {
    return Column(
      children: [
        _buildField(firstNameController, "First Name*"),
        _buildField(lastNameController, "Last Name*"),
        _buildField(mobileController, "Mobile Number*", keyboardType: TextInputType.phone),
        _buildField(emailController, "Email*"),
        const SizedBox(height: 20),
        _buildButton("Continue", () {
          if (_validateStep1()) {
            setState(() => _currentStep = 2);
          }
        }),
      ],
    );
  }

  // ---------------- STEP 2 ----------------
  Widget _buildLocationStep() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Fill location details", style: TextStyle(color: Colors.grey)),
            _isLocating 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : TextButton.icon(
                    onPressed: _detectLocation,
                    icon: const Icon(Icons.my_location, size: 16),
                    label: const Text("Auto Detect"),
                  ),
          ],
        ),
        _buildField(stateController, "State*"),
        _buildField(districtController, "District*"),
        _buildField(talukaController, "Taluka*"),
        _buildField(villageController, "Village*"),
        _buildField(addressController, "Address*"),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildButton("Back", () {
              setState(() => _currentStep = 1);
            }, isOutlined: true),
            _buildButton("Continue", () {
              if (_validateStep2()) {
                setState(() => _currentStep = 3);
              }
            }),
          ],
        )
      ],
    );
  }

  // ---------------- STEP 3 ----------------
  Widget _buildBankStep() {
    return Column(
      children: [
        _buildField(accountNumberController, "Account Number*", keyboardType: TextInputType.number),
        _buildField(accountHolderController, "Account Holder Name*"),
        _buildField(ifscController, "IFSC Code*"),
        _buildField(accountTypeController, "Account Type*"),
        _buildField(upiController, "UPI ID"),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildButton("Back", () {
              if (!_isLoading) setState(() => _currentStep = 2);
            }, isOutlined: true),
            _isLoading
                ? const SizedBox(
                    height: 48,
                    width: 48,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _buildButton("Create Coordinator", _handleFinalSubmit),
          ],
        )
      ],
    );
  }

  // ---------------- FIELD BUILDER ----------------
  Widget _buildField(TextEditingController controller, String label,
      {bool isPassword = false, TextInputType keyboardType = TextInputType.text}) {
    return LabeledTextField(
      label: label,
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword,
      validator: (value) {
        if (label.contains("*") && (value == null || value.isEmpty)) {
          return "Required";
        }
        return null;
      },
    );
  }

  // ---------------- LOCATION LOGIC ----------------
  Future<void> _detectLocation() async {
    setState(() => _isLocating = true);
    try {
      final locData = await LocationService().detectAndResolveLocation();
      setState(() {
        stateController.text = locData['state'] ?? stateController.text;
        districtController.text = locData['district'] ?? districtController.text;
        talukaController.text = locData['taluka'] ?? talukaController.text;
        villageController.text = locData['village'] ?? villageController.text;
        addressController.text = locData['autoAddress'] ?? addressController.text;
      });
      _showMessage("Location updated successfully!");
    } catch (e) {
      _showMessage("Failed to detect location: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  // ---------------- BUTTON BUILDER ----------------
  Widget _buildButton(String text, VoidCallback onPressed, {bool isOutlined = false}) {
    if (isOutlined) {
      return OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.appBarBlue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.appBarBlue,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.appBarBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ---------------- VALIDATION ----------------
  bool _validateStep1() {
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        mobileController.text.isEmpty ||
        emailController.text.isEmpty) {
      _showMessage("Please fill all required fields in Step 1");
      return false;
    }
    if (mobileController.text.length != 10) {
      _showMessage("Mobile number must be 10 digits");
      return false;
    }
    return true;
  }

  bool _validateStep2() {
    if (stateController.text.isEmpty ||
        districtController.text.isEmpty ||
        talukaController.text.isEmpty ||
        villageController.text.isEmpty ||
        addressController.text.isEmpty) {
      _showMessage("Please fill all required fields in Step 2");
      return false;
    }
    return true;
  }

  // ---------------- FINAL SUBMIT ----------------
  Future<void> _handleFinalSubmit() async {
    if (accountNumberController.text.isEmpty ||
        accountHolderController.text.isEmpty ||
        ifscController.text.isEmpty ||
        accountTypeController.text.isEmpty) {
      _showMessage("Please fill all required bank details");
      return;
    }

    final formData = {
      "firstName": firstNameController.text.trim(),
      "lastName": lastNameController.text.trim(),
      "mobile": mobileController.text.trim(),
      "email": emailController.text.trim(),
      "role": "COORDINATOR",
      "state": stateController.text.trim(),
      "district": districtController.text.trim(),
      "taluka": talukaController.text.trim(),
      "village": villageController.text.trim(),
      "address": addressController.text.trim(),
    };

    setState(() => _isLoading = true);

    try {
      final res = await _repository.createEmployee(formData);
      _showMessage("Coordinator created successfully! ID: ${res['username']}");
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showMessage(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
