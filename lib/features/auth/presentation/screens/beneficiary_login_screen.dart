// lib/features/auth/presentation/screens/beneficiary_login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/widgets/SelectableItemCard.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../dashboard/presentation/screens/beneficiary_dashboard.dart';
import '../providers/auth_provider.dart';
import '../../data/models/login_request.dart';
import 'forgot_password_screen.dart';

class BeneficiaryLoginScreen extends StatefulWidget {
  const BeneficiaryLoginScreen({super.key});

  @override
  State<BeneficiaryLoginScreen> createState() => _BeneficiaryLoginScreenState();
}

class _BeneficiaryLoginScreenState extends State<BeneficiaryLoginScreen> {
  String? selectedCategory; // Nullable to handle initial state
  bool showLoginForm = false;
  bool _isObscure = true;

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Fixes unbounded height crash
          children: [
            const SizedBox(height: 20),
            const Text(
              "Login As Beneficiary",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Select your category and continue",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 30),

            // STEP 1: CATEGORY SELECTION CARD
            _buildCategorySelectionCard(),

            const SizedBox(height: 20),

            // STEP 2: LOGIN CREDENTIALS CARD
            if (showLoginForm)
              _buildLoginCard(authProvider)
            else
              const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelectionCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              "Select Your Category",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          _buildCategoryList(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: CustomButton(
              text: "Continue",
              onPressed: selectedCategory == null
                  ? null
                  : () => setState(() => showLoginForm = true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard(AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const Text(
              "Shilpkar Foundations - Maharashtra",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Beneficiary Access Only", // Matches design
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            _buildInputLabel("Beneficiary ID"),
            const SizedBox(height: 8),
            TextFormField(
              controller: _idController,
              decoration: _inputDecoration("Enter ID"),
              validator: (v) => v == null || v.isEmpty ? "Required" : null,
            ),

            const SizedBox(height: 20),

            _buildInputLabel("Password"),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: _isObscure,
              decoration: InputDecoration(
                hintText: "Enter Password",
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                suffixIcon: IconButton(
                    icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _isObscure = !_isObscure),
                ),
              ),
              validator: (v) => v == null || v.isEmpty ? "Required" : null,
            ),



            const SizedBox(height: 10),

            authProvider.isLoading
                ? const CircularProgressIndicator()
                : CustomButton(
              text: "Continue",
              onPressed: () => _handleLogin(authProvider),
            ),

            const SizedBox(height: 20),
            const Text(
              "Use ID and Password Created by the Admin Panel",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // UI Helpers to maintain consistency
  Widget _buildInputLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  Widget _buildCategoryList() {
    final categories = {
      "Farmer": "Works in a farm",
      "Student": "Studying in a higher institution",
      "Women": "Housewife or daily wage workers",
      "Worker": "Daily wage workers or labours",
      "Citizen": "Citizens of Latur"
    };

    return Column(
      children: categories.entries.map((e) => SelectableItemCard(
        title: e.key,
        subtitle: e.value,
        isSelected: selectedCategory == e.key,
        onTap: () {
          setState(() {
            selectedCategory = e.key;
            showLoginForm = false; // Reset form if category changes
          });
        },
      )).toList(),
    );
  }

  void _handleLogin(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    final request = LoginRequest(
      username: _idController.text.trim(),
      password: _passwordController.text.trim(),
      // API requires BENEFICIARY role for this flow
      loginAsRole: "BENEFICIARY",
    );

    final success = await authProvider.login(request);

    if (success && mounted) {
      // Navigate to Beneficiary Dashboard and remove all previous routes
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const BeneficiaryDashboard()),
            (route) => false,
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? "Login failed"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}