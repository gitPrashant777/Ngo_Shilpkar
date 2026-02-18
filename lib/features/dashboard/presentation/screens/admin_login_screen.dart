// lib/features/auth/presentation/screens/admin_login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/navigation/main_navigation.dart';
import '../../../../shared/widgets/SelectableItemCard.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../admin/presentation/screens/admin_dashboard.dart'; // Standard Admin Dashboard
import '../../../auth/data/models/login_request.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/forgot_password_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  String? selectedRole;
  bool showLoginForm = false;
  bool _isObscure = true; // Added for password visibility toggle

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Login As Admin",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Select your administration level",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 30),

            _buildRoleSelectionCard(),

            const SizedBox(height: 20),

            if (showLoginForm)
              _buildLoginCard(authProvider)
            else
              const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSelectionCard() {
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
              "Select Admin Type",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SelectableItemCard(
            title: "Super Admin",
            subtitle: "Full system access & user management",
            isSelected: selectedRole == "SUPER_ADMIN",
            onTap: () {
              setState(() {
                selectedRole = "SUPER_ADMIN";
                showLoginForm = false;
              });
            },
          ),
          SelectableItemCard(
            title: "Admin",
            subtitle: "Manage jobs, schemes, and beneficiaries", // Updated subtitle
            isSelected: selectedRole == "ADMIN",
            onTap: () {
              setState(() {
                selectedRole = "ADMIN";
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
    );
  }

  Widget _buildLoginCard(AuthProvider authProvider) {
    final bool isSuperAdmin = selectedRole == "SUPER_ADMIN";

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
              "Admin Panel Access",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Authorized Personnel Only",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            TextFormField(
              controller: _idController,
              decoration: InputDecoration(
                labelText: isSuperAdmin ? "Email Address" : "Admin ID",
                prefixIcon: Icon(isSuperAdmin ? Icons.email_outlined : Icons.badge_outlined),
                border: const OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.isEmpty ? "Required" : null,
            ),

            const SizedBox(height: 20),

            TextFormField(
              controller: _passwordController,
              obscureText: _isObscure,
              decoration: InputDecoration(
                labelText: "Password",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _isObscure = !_isObscure),
                ),
              ),
              validator: (v) => v == null || v.isEmpty ? "Required" : null,
            ),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                  );
                },
                child: const Text("Forgot Password?"),
              ),
            ),

            const SizedBox(height: 20),

            authProvider.isLoading
                ? const CircularProgressIndicator()
                : CustomButton(
              text: "Login",
              onPressed: () => _handleLogin(authProvider),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogin(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    final bool isSuperAdmin = selectedRole == "SUPER_ADMIN";

    final request = LoginRequest(
      email: isSuperAdmin ? _idController.text.trim() : null,
      username: isSuperAdmin ? null : _idController.text.trim(),
      password: _passwordController.text.trim(),
      loginAsRole: selectedRole!,
    );

    final success = await authProvider.login(request);

    if (success && mounted) {
      final authenticatedRole = authProvider.role;

      // Conditional Navigation based on authenticated role
      if (authenticatedRole == "SUPER_ADMIN") {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
              (route) => false,
        );
      } else if (authenticatedRole == "ADMIN") {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboard()),
              (route) => false,
        );
      }
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