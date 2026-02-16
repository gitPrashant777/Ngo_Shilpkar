import 'package:flutter/material.dart';

import '../../../../shared/widgets/UserCreationForm.dart';
class MakeAdminScreen extends StatelessWidget {
  const MakeAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return UserCreationForm(
      title: "Make Admin",
      subTitle: "Admin Details",
      actionButtonText: "Make Admin",
      onActionPressed: () {
        // Handle POST /api/super-admin/create-user logic
      },
    );
  }
}