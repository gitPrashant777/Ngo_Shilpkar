import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/screens/beneficiary_login_screen.dart';
import '../../../ecommerce/presentation/screens/public/customer_login_screen.dart';
import 'apply_job_screen.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../ecommerce/presentation/providers/customer_auth_provider.dart';

import 'package:shilpkar/core/navigation/main_navigation.dart';

class JobAuthSelectionScreen extends StatelessWidget {
  final bool inline;
  const JobAuthSelectionScreen({super.key, this.inline = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: Text(l10n.applyForJob ?? 'Apply for Job'),
        backgroundColor: AppColors.appBarBlue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.work_outline,
                size: 80,
                color: AppColors.appBarBlue,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.loginToContinue ?? 'Login to Continue',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.appBarBlue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Please login as a Beneficiary or register as a Guest User to apply for jobs and submit your profile details.',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BeneficiaryLoginScreen(),
                    ),
                  );
                  // If login was successful, they will be navigated to BeneficiaryDashboard automatically by the login screen's logic usually...
                  // Wait! BeneficiaryLoginScreen uses a separate flow that replaces the whole screen with MainNavigationScreen. 
                  // Let's just check if authenticated after returning.
                  if (!inline && context.mounted && context.read<AuthProvider>().isAuthenticated) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const ApplyJobScreen(isPreScreen: true)),
                    );
                  }
                },
                icon: const Icon(Icons.group_add_rounded),
                label: const Text('Login as Beneficiary', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.beneficiaryGradient.first,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              
              const SizedBox(height: 16),
              
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CustomerLoginScreen(),
                    ),
                  );
                  if (!inline && result == true && context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const ApplyJobScreen(isPreScreen: true)),
                    );
                  }
                },
                icon: const Icon(Icons.person_outline),
                label: const Text('Login / Signup as Guest User', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
