import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

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
            Text(
              l10n.selectEmployeeRole,
              style: const TextStyle(
                  fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.chooseEmployeeType,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),

            _buildRoleCard(
              title: l10n.fieldEmployeeLabel,
              subtitle: l10n.worksOnGround,
              role: "FIELD",
            ),

            const SizedBox(height: 20),

            _buildRoleCard(
              title: l10n.coordinatorLabel,
              subtitle: l10n.managesFieldEmployees,
              role: "COORDINATOR",
            ),

            const Spacer(),

            CustomButton(
              text: l10n.continue_btn,
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

