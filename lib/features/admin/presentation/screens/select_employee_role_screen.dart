import 'package:flutter/material.dart';
import 'package:shilpkar/core/constants/user_roles.dart';
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

  List<_RoleOption> _roleOptions(AppLocalizations l10n) => [
        const _RoleOption(
          role: UserRole.districtCoordinator,
          title: 'District Coordinator',
          subtitle: 'Coordinates district-level operations',
        ),
        const _RoleOption(
          role: UserRole.talukaCoordinator,
          title: 'Taluka Coordinator',
          subtitle: 'Coordinates taluka-level teams and activities',
        ),
        const _RoleOption(
          role: UserRole.villageCoordinator,
          title: 'Village Coordinator',
          subtitle: 'Coordinates village-level field activities',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final options = _roleOptions(l10n);

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
              'Select Coordinator Role',
              style: TextStyle(
                  fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose the type of coordinator to create',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),

            ...List.generate(options.length, (index) {
              final option = options[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == options.length - 1 ? 0 : 20,
                ),
                child: _buildRoleCard(
                  title: option.title,
                  subtitle: option.subtitle,
                  role: option.role,
                ),
              );
            }),

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
                        MakeCoordinatorScreen(role: selectedRole!),
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

class _RoleOption {
  final String role;
  final String title;
  final String subtitle;

  const _RoleOption({
    required this.role,
    required this.title,
    required this.subtitle,
  });
}
