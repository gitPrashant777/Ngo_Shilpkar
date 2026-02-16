import 'package:flutter/material.dart';
import '../../../../shared/widgets/UserCreationForm.dart';

class MakeEmployeeScreen extends StatelessWidget {
  const MakeEmployeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return UserCreationForm(
      title: "Make Employee",
      subTitle: "Location Details", // Changes based on current step
      actionButtonText: "Continue",
      additionalFields: [
        _buildDropdownField("State", "Maharashtra"),
        _buildDropdownField("District", "Latur"),
        // Add more fields for Taluka, Village, etc.
      ],
      onActionPressed: () {
        // Progress to Bank Details step
      },
    );
  }

  Widget _buildDropdownField(String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black54)),
          const SizedBox(height: 8),
          // Custom Dropdown implementation...
        ],
      ),
    );
  }
}

