// lib/features/auth/presentation/screens/employee_login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/user_roles.dart';
import '../../../../core/navigation/main_navigation.dart';
import '../../../../l10n/app_localizations.dart';
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
  String? selectedRole;
  bool showLoginForm = false;

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
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
            Text(
              l10n.loginAsEmployeeFull,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.selectRoleToContinue,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 30),

            // STEP 1: SELECT YOUR ROLE CARD
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      l10n.selectYourRole,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SelectableItemCard(
                    title: 'District Coordinator',
                    subtitle: 'Coordinates district-level operations',
                    isSelected: selectedRole == UserRole.districtCoordinator,
                    onTap: () {
                      setState(() {
                        selectedRole = UserRole.districtCoordinator;
                        showLoginForm = false;
                      });
                    },
                  ),
                  SelectableItemCard(
                    title: 'Taluka Coordinator',
                    subtitle: 'Coordinates taluka-level teams and activities',
                    isSelected: selectedRole == UserRole.talukaCoordinator,
                    onTap: () {
                      setState(() {
                        selectedRole = UserRole.talukaCoordinator;
                        showLoginForm = false;
                      });
                    },
                  ),
                  SelectableItemCard(
                    title: 'Village Coordinator',
                    subtitle: 'Coordinates village-level field activities',
                    isSelected: selectedRole == UserRole.villageCoordinator,
                    onTap: () {
                      setState(() {
                        selectedRole = UserRole.villageCoordinator;
                        showLoginForm = false;
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: CustomButton(
                      text: l10n.continue_btn,
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
              _buildLoginCard(authProvider, l10n)
            else
              const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginCard(AuthProvider authProvider, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text(
              l10n.shilpkarMaharashtra,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              l10n.employeeAccessOnly,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            _buildInputLabel(l10n.employeeId),
            const SizedBox(height: 8),
            TextFormField(
              controller: _idController,
              decoration: _inputDecoration(l10n.enterEmployeeId),
              validator: (v) =>
                  v == null || v.isEmpty ? l10n.required : null,
            ),

            const SizedBox(height: 20),

            _buildInputLabel(l10n.password),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: _inputDecoration(l10n.enterPassword),
              validator: (v) =>
                  v == null || v.isEmpty ? l10n.required : null,
            ),

            const SizedBox(height: 10),

            authProvider.isLoading
                ? const CircularProgressIndicator()
                : CustomButton(
                    text: l10n.continue_btn,
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;

                      final request = LoginRequest(
                        username: _idController.text.trim(),
                        password: _passwordController.text.trim(),
                        loginAsRole: selectedRole!,
                      );

                      final success = await authProvider.login(request);

                      if (success && mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MainNavigationScreen(
                                  initialIndex: 1)),
                          (route) => false,
                        );
                      } else if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(authProvider.errorMessage ??
                                l10n.loginFailed),
                            backgroundColor: AppColors.errorRed,
                          ),
                        );
                      }
                    },
                  ),

            const SizedBox(height: 20),
            Text(
              l10n.useEmployeeIdNote,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            // Debug Autofill
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(
                    color: AppColors.errorRed.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(8),
                color: AppColors.debugRedBg,
              ),
              child: Column(
                children: [
                  const Text(
                    "Debug Autofill (Tap to fill)",
                    style: TextStyle(
                        color: AppColors.errorRed,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
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
        style: const TextStyle(
            fontWeight: FontWeight.w600, color: Colors.black87),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
