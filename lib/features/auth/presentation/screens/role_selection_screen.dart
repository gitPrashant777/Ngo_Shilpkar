import 'package:flutter/material.dart';
import '../../widgets/login_role_card.dart';
import '../../../../shared/widgets/custom_button.dart';
import 'login_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Login As Employee",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text("Select your job role to continue", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),

            LoginRoleCard(
              title: "Field work",
              subtitle: "Works at ground/village level",
              icon: Icons.engineering,
              isSelected: selectedRole == "FIELD",
              onTap: () => setState(() => selectedRole = "FIELD"),
            ),
            LoginRoleCard(
              title: "Co-ordinator",
              subtitle: "Coordinates office and ground team",
              icon: Icons.computer,
              isSelected: selectedRole == "COORDINATOR",
              onTap: () => setState(() => selectedRole = "COORDINATOR"),
            ),

            const SizedBox(height: 20),
            CustomButton(
              text: "Continue",
              onPressed: selectedRole == null
                  ? () {}
                  : () => Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen(role: selectedRole!))),
            ),
          ],
        ),
      ),
    );
  }
}