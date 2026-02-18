import 'package:flutter/material.dart';
import '../../../../shared/widgets/SelectableItemCard.dart';
import '../../../../shared/widgets/custom_button.dart';
import 'SuperMakeEmployeeScreen.dart';

class SelectEmployeeRoleScreen extends StatefulWidget {
  const SelectEmployeeRoleScreen({super.key});

  @override
  State<SelectEmployeeRoleScreen> createState() =>
      _SelectEmployeeRoleScreenState();
}

class _SelectEmployeeRoleScreenState
    extends State<SelectEmployeeRoleScreen> {

  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text(
              "Select Employee Role",
              style: TextStyle(
                  fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Choose the type of employee to create",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),

            _buildRoleCard(
              title: "Field Employee",
              subtitle: "Works on ground operations",
              role: "FIELD",
            ),

            const SizedBox(height: 20),

            _buildRoleCard(
              title: "Coordinator",
              subtitle: "Manages field employees",
              role: "COORDINATOR",
            ),

            const Spacer(),

            CustomButton(
              text: "Continue",
              onPressed: selectedRole == null
                  ? null
                  : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        MakeEmployeeScreen(role: selectedRole!),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String subtitle,
    required String role,
  }) {
    return SelectableItemCard(
      title: title,
      subtitle: subtitle,
      isSelected: selectedRole == role,
      onTap: () {
        setState(() {
          selectedRole = role;
        });
      },
    );
  }
}
