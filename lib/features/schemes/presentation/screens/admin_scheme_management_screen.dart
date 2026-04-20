import 'package:flutter/material.dart';
import 'package:shilpkar/features/schemes/presentation/screens/Superadmin_scheme_management_screen.dart';

// We can reuse SuperAdminSchemeManagementScreen if the logic is same.
// SuperAdminSchemeManagementScreen likely has Create/Edit logic.
// Let's wrap it or use it directly.

class AdminSchemeManagementScreen extends StatelessWidget {
  const AdminSchemeManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Reusing the existing Super Admin screen as the functionality (Create/Edit/Publish) is identical for Admin.
    return const SuperAdminSchemeManagementScreen();
  }
}
