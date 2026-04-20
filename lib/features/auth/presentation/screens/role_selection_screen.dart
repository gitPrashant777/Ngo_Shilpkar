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
              "Login As Coordinator",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Select your coordinator level to continue",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),

            LoginRoleCard(
              title: "District Coordinator",
              subtitle: "District-level coordination",
              icon: Icons.apartment,
              isSelected: selectedRole == "DISTRICT_COORDINATOR",
              onTap: () =>
                  setState(() => selectedRole = "DISTRICT_COORDINATOR"),
            ),
            LoginRoleCard(
              title: "Taluka Coordinator",
              subtitle: "Taluka-level coordination",
              icon: Icons.map,
              isSelected: selectedRole == "TALUKA_COORDINATOR",
              onTap: () => setState(() => selectedRole = "TALUKA_COORDINATOR"),
            ),
            LoginRoleCard(
              title: "Village Coordinator",
              subtitle: "Village-level coordination",
              icon: Icons.location_on,
              isSelected: selectedRole == "VILLAGE_COORDINATOR",
              onTap: () => setState(() => selectedRole = "VILLAGE_COORDINATOR"),
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
