// lib/features/auth/presentation/screens/employee_login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../employee/presentation/screens/employee_dashboard.dart';
import '../providers/auth_provider.dart';
import '../../data/models/login_request.dart';
import '../../../../shared/widgets/SelectableItemCard.dart';
import '../../../../shared/widgets/custom_button.dart';

class EmployeeLoginScreen extends StatefulWidget {
  const EmployeeLoginScreen({super.key});

  @override
  State<EmployeeLoginScreen> createState() => _EmployeeLoginScreenState();
}

class _EmployeeLoginScreenState extends State<EmployeeLoginScreen> {
  String? selectedRole; // This is nullable
  bool showLoginForm = false;

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB), // Matches design background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "Login As Employee",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Select your job role to continue",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 30),

            // STEP 1: SELECT YOUR ROLE CARD
            Container(
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
                      "Select Your Role",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SelectableItemCard(
                    title: "Field work",
                    subtitle: "Works at ground/village level",
                    isSelected: selectedRole == "FIELD",
                    onTap: () {
                      setState(() {
                        selectedRole = "FIELD";
                        showLoginForm = false;
                      });
                    },
                  ),
                  SelectableItemCard(
                    title: "Co-ordinator",
                    subtitle: "Coordinates the working of office and ground team",
                    isSelected: selectedRole == "COORDINATOR",
                    onTap: () {
                      setState(() {
                        selectedRole = "COORDINATOR";
                        showLoginForm = false;
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: CustomButton(
                      text: "Continue",
                      onPressed: selectedRole == null
                          ? null
                          : () => setState(() => showLoginForm = true),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // STEP 2: LOGIN FORM (Appears after clicking Continue)
            if (showLoginForm)
              _buildLoginCard(authProvider)
            else
              const SizedBox(height: 40),
          ],
        ),
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
              "Employee Access Only",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            _buildInputLabel("Employee ID"),
            const SizedBox(height: 8),
            TextFormField(
              controller: _idController,
              decoration: _inputDecoration("Employee ID"),
              validator: (v) => v == null || v.isEmpty ? "Required" : null,
            ),

            const SizedBox(height: 20),

            _buildInputLabel("Password"),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: _inputDecoration("Enter Password"),
              validator: (v) => v == null || v.isEmpty ? "Required" : null,
            ),



            const SizedBox(height: 10),

            authProvider.isLoading
                ? const CircularProgressIndicator()
                : CustomButton(
              text: "Continue",
              // Update the onPressed logic in your _buildLoginCard
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;

                // selectedRole! is safe here because showLoginForm is only true after a selection
                final request = LoginRequest(
                  username: _idController.text.trim(),
                  password: _passwordController.text.trim(),
                  loginAsRole: selectedRole!,
                );

                final success = await authProvider.login(request);

                if (success && mounted) {
                  // 1. Clears navigation stack and moves to Employee Dashboard
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const EmployeeDashboard()),
                        (route) => false,
                  );
                } else if (mounted) {
                  // 2. Displays specific backend error (e.g., "Invalid credentials")
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(authProvider.errorMessage ?? "Login failed"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: 20),
            const Text(
              "Use Employee ID and Password Created by the Admin Panel",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

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
}