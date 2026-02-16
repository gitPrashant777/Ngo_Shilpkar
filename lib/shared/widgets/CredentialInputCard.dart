import 'package:flutter/material.dart';
import '../../../../shared/widgets/custom_button.dart';

class CredentialInputCard extends StatelessWidget {
  final String headerTitle;
  final String headerSubtitle;
  final String idHint;
  final TextEditingController idController;
  final TextEditingController passwordController;
  final VoidCallback onContinue;

  const CredentialInputCard({
    super.key,
    required this.headerTitle,
    required this.headerSubtitle,
    required this.idHint,
    required this.idController,
    required this.passwordController,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
          children: [
          Text(headerTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      Text(headerSubtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      const SizedBox(height: 20),
      _buildField(idHint, idController),
      const SizedBox(height: 16),
      _buildField("Password", passwordController, isPassword: true),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton(
            onPressed: () {}, // Matches "Forgot Password?" [cite: 5, 9]
        child: const Text("Forgot Password?", style: TextStyle(color: Color(0xFF4A749B))),
      ),
    ),
    CustomButton(text: "Continue", onPressed: onContinue),
    const SizedBox(height: 12),
    Text(
    "Use $idHint and Password Created by the Admin Panel",
    textAlign: TextAlign.center,
    style: const TextStyle(fontSize: 10, color: Colors.grey),
    ),
    ],
    ),
    );
  }

  Widget _buildField(String hint, TextEditingController controller, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(hint, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
          ),
        ),
      ],
    );
  }
}