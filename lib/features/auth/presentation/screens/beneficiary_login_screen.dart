// lib/features/auth/presentation/screens/beneficiary_login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/SelectableItemCard.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../core/navigation/main_navigation.dart';
import '../providers/auth_provider.dart';
import '../../data/models/login_request.dart';
import 'forgot_password_screen.dart';

class BeneficiaryLoginScreen extends StatefulWidget {
  const BeneficiaryLoginScreen({super.key});

  @override
  State<BeneficiaryLoginScreen> createState() => _BeneficiaryLoginScreenState();
}

class _BeneficiaryLoginScreenState extends State<BeneficiaryLoginScreen> {
  String? selectedCategory;
  bool showLoginForm = false;
  bool _isObscure = true;

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
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Text(
              l10n.loginAsBeneficiaryFull,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.selectCategoryToContinue,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 30),

            // STEP 1: CATEGORY SELECTION CARD
            _buildCategorySelectionCard(l10n),

            const SizedBox(height: 20),

            // STEP 2: LOGIN CREDENTIALS CARD
            if (showLoginForm)
              _buildLoginCard(authProvider, l10n)
            else
              const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelectionCard(AppLocalizations l10n) {
    return Container(
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
              l10n.selectYourCategory,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          _buildCategoryList(l10n),
          Padding(
            padding: const EdgeInsets.all(20),
            child: CustomButton(
              text: l10n.continue_btn,
              onPressed: selectedCategory == null
                  ? null
                  : () => setState(() => showLoginForm = true),
            ),
          ),
        ],
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
              l10n.beneficiaryAccessOnly,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            _buildInputLabel(l10n.beneficiaryId),
            const SizedBox(height: 8),
            TextFormField(
              controller: _idController,
              decoration: _inputDecoration(l10n.enterId),
              validator: (v) =>
                  v == null || v.isEmpty ? l10n.required : null,
            ),

            const SizedBox(height: 20),

            _buildInputLabel(l10n.password),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: _isObscure,
              decoration: InputDecoration(
                hintText: l10n.enterPassword,
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300)),
                suffixIcon: IconButton(
                  icon: Icon(
                      _isObscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () =>
                      setState(() => _isObscure = !_isObscure),
                ),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? l10n.required : null,
            ),

            const SizedBox(height: 10),

            authProvider.isLoading
                ? const CircularProgressIndicator()
                : CustomButton(
                    text: l10n.continue_btn,
                    onPressed: () => _handleLogin(authProvider, l10n),
                  ),

            const SizedBox(height: 20),
            Text(
              l10n.useBeneficiaryIdNote,
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
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        _idController.text = "BEN0003";
                        _passwordController.text = "vkLVs6CjWu";
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.errorRed,
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text("Fill Beneficiary (BEN0003)"),
                    ),
                  ),
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

  Widget _buildCategoryList(AppLocalizations l10n) {
    final categories = {
      l10n.farmer: l10n.farmerSubtitle,
      l10n.student: l10n.studentSubtitle,
      l10n.women: l10n.womenSubtitle,
      l10n.worker: l10n.workerSubtitle,
      l10n.citizen: l10n.citizenSubtitle,
    };

    return Column(
      children: categories.entries
          .map((e) => SelectableItemCard(
                title: e.key,
                subtitle: e.value,
                isSelected: selectedCategory == e.key,
                onTap: () {
                  setState(() {
                    selectedCategory = e.key;
                    showLoginForm = false;
                  });
                },
              ))
          .toList(),
    );
  }

  void _handleLogin(AuthProvider authProvider, AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;

    final request = LoginRequest(
      username: _idController.text.trim(),
      password: _passwordController.text.trim(),
      loginAsRole: "BENEFICIARY",
    );

    final success = await authProvider.login(request);

    if (success && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (_) => const MainNavigationScreen(initialIndex: 1)),
        (route) => false,
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? l10n.loginFailed),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }
}