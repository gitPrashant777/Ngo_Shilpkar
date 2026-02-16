import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class MakeCoordinatorScreen extends StatefulWidget {
  const MakeCoordinatorScreen({super.key});

  @override
  State<MakeCoordinatorScreen> createState() =>
      _MakeCoordinatorScreenState();
}

class _MakeCoordinatorScreenState
    extends State<MakeCoordinatorScreen> {
  int _currentStep = 1;

  final _formKey = GlobalKey<FormState>();

  // STEP 1 Controllers
  final TextEditingController firstNameController =
  TextEditingController();
  final TextEditingController lastNameController =
  TextEditingController();
  final TextEditingController usernameController =
  TextEditingController();
  final TextEditingController passwordController =
  TextEditingController();
  final TextEditingController emailController =
  TextEditingController();

  // STEP 2 Controllers
  final TextEditingController stateController =
  TextEditingController();
  final TextEditingController districtController =
  TextEditingController();
  final TextEditingController talukaController =
  TextEditingController();
  final TextEditingController villageController =
  TextEditingController();
  final TextEditingController addressController =
  TextEditingController();

  // STEP 3 Controllers
  final TextEditingController accountNumberController =
  TextEditingController();
  final TextEditingController accountHolderController =
  TextEditingController();
  final TextEditingController ifscController =
  TextEditingController();
  final TextEditingController accountTypeController =
  TextEditingController();
  final TextEditingController upiController =
  TextEditingController();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: "https://ngo-project-r7cc.onrender.com/api",
    headers: {"Content-Type": "application/json"},
  ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Make Coordinator")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: _buildCurrentStep(),
          ),
        ),
      ),
    );
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
        _buildField(usernameController, "Username*"),
        _buildField(emailController, "Email*"),
        _buildField(passwordController, "Password*", isPassword: true),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            if (_validateStep1()) {
              setState(() => _currentStep = 2);
            }
          },
          child: const Text("Continue"),
        )
      ],
    );
  }

  // ---------------- STEP 2 ----------------
  Widget _buildLocationStep() {
    return Column(
      children: [
        _buildField(stateController, "State*"),
        _buildField(districtController, "District*"),
        _buildField(talukaController, "Taluka*"),
        _buildField(villageController, "Village*"),
        _buildField(addressController, "Address*"),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            if (_validateStep2()) {
              setState(() => _currentStep = 3);
            }
          },
          child: const Text("Continue"),
        )
      ],
    );
  }

  // ---------------- STEP 3 ----------------
  Widget _buildBankStep() {
    return Column(
      children: [
        _buildField(accountNumberController, "Account Number*"),
        _buildField(accountHolderController,
            "Account Holder Name*"),
        _buildField(ifscController, "IFSC Code*"),
        _buildField(accountTypeController, "Account Type*"),
        _buildField(upiController, "UPI ID"),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _handleFinalSubmit,
          child: const Text("Create Coordinator"),
        )
      ],
    );
  }

  // ---------------- FIELD BUILDER ----------------
  Widget _buildField(TextEditingController controller,
      String label,
      {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  // ---------------- VALIDATION ----------------
  bool _validateStep1() {
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        usernameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      _showMessage("Please fill all required fields in Step 1");
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

    try {
      final body = {
        "firstName": firstNameController.text.trim(),
        "lastName": lastNameController.text.trim(),
        "username": usernameController.text.trim(),
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
        "role": "COORDINATOR",
        "location": {
          "state": stateController.text.trim(),
          "district": districtController.text.trim(),
          "taluka": talukaController.text.trim(),
          "village": villageController.text.trim(),
          "address": addressController.text.trim(),
        },
        "bankDetails": {
          "accountNumber":
          accountNumberController.text.trim(),
          "accountHolderName":
          accountHolderController.text.trim(),
          "ifscCode": ifscController.text.trim(),
          "accountType":
          accountTypeController.text.trim(),
          "upiId": upiController.text.trim(),
        }
      };

      print("Creating Coordinator: $body");

      final response =
      await _dio.post("/super-admin/create-user",
          data: body);

      _showMessage("Coordinator created successfully!");

      Navigator.pop(context);
    } on DioException catch (e) {
      _showMessage(
          e.response?.data["message"] ?? "Server error");
    } catch (_) {
      _showMessage("Unexpected error occurred");
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
