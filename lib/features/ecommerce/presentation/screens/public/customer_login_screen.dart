import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../providers/customer_auth_provider.dart';

class CustomerLoginScreen extends StatefulWidget {
  const CustomerLoginScreen({super.key});

  @override
  State<CustomerLoginScreen> createState() => _CustomerLoginScreenState();
}

class _CustomerLoginScreenState extends State<CustomerLoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final _loginFormKey = GlobalKey<FormState>();
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  final _registerFormKey = GlobalKey<FormState>();
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerMobileController = TextEditingController();
  final _registerPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerMobileController.dispose();
    _registerPasswordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_loginFormKey.currentState!.validate()) return;
    final provider = context.read<CustomerAuthProvider>();
    final success = await provider.login(
      _loginEmailController.text.trim(),
      _loginPasswordController.text.trim(),
    );
    if (!mounted) return;
    _handleResult(success, provider.error);
  }

  Future<void> _loginWithGoogle() async {
    final provider = context.read<CustomerAuthProvider>();
    final success = await provider.loginWithGoogle();
    if (!mounted) return;
    _handleResult(success, provider.error);
  }

  Future<void> _register() async {
    if (!_registerFormKey.currentState!.validate()) return;
    final provider = context.read<CustomerAuthProvider>();
    final success = await provider.register(
      _registerNameController.text.trim(),
      _registerEmailController.text.trim(),
      _registerPasswordController.text.trim(),
      _registerMobileController.text.trim(),
    );
    if (!mounted) return;
    _handleResult(success, provider.error);
  }

  void _handleResult(bool success, String? error) {
    final l10n = AppLocalizations.of(context)!;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.successProceeding), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? l10n.actionFailed), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.customerAccount),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: l10n.login.toUpperCase()),
            Tab(text: l10n.register.toUpperCase()),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLoginForm(l10n),
          _buildRegisterForm(l10n),
        ],
      ),
    );
  }

  Widget _buildLoginForm(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _loginFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              l10n.loginToContinue,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _loginEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: l10n.email,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.email),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return l10n.pleaseEnterEmail;
                if (!value.contains("@")) return l10n.pleaseEnterValidEmail;
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _loginPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: l10n.password,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return l10n.pleaseEnterPassword;
                return null;
              },
            ),
            const SizedBox(height: 32),
            Consumer<CustomerAuthProvider>(
              builder: (context, provider, child) {
                return ElevatedButton(
                  onPressed: provider.isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appBarBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: provider.isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(l10n.login.toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                );
              },
            ),
            const SizedBox(height: 12),
            Consumer<CustomerAuthProvider>(
              builder: (context, provider, child) {
                return OutlinedButton.icon(
                  onPressed: provider.isLoading ? null : _loginWithGoogle,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: AppColors.appBarBlue.withOpacity(0.3)),
                  ),
                  icon: const Icon(Icons.g_mobiledata, size: 28),
                  label: const Text(
                    'Continue with Google',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterForm(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _registerFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              l10n.createCustomerAccount,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _registerNameController,
              decoration: InputDecoration(
                labelText: l10n.fullName,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.person),
              ),
              validator: (v) => v!.isEmpty ? l10n.required : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _registerEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: l10n.email,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.email),
              ),
              validator: (v) => (v == null || !v.contains("@")) ? l10n.validEmailRequired : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _registerMobileController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: l10n.mobile,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.phone),
              ),
              validator: (v) => v!.isEmpty ? l10n.required : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _registerPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: l10n.password,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
              ),
              validator: (v) => (v == null || v.length < 6) ? l10n.minSixChars : null,
            ),
            const SizedBox(height: 32),
            Consumer<CustomerAuthProvider>(
              builder: (context, provider, child) {
                return ElevatedButton(
                  onPressed: provider.isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: provider.isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(l10n.register.toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
