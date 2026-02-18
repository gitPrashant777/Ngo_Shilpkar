// lib/features/admin/presentation/screens/admin_success_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdminSuccessScreen extends StatelessWidget {
  final String username;
  final String password;

  const AdminSuccessScreen({
    super.key,
    required this.username,
    required this.password,
  });

  void _copy(BuildContext context, String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$label copied to clipboard"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _copyAll(BuildContext context) {
    final combined = "Username: $username\nPassword: $password";
    Clipboard.setData(ClipboardData(text: combined));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Credentials copied successfully"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              const Text(
                "Shilpkar Foundation",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF55789A),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                "Admin Created Successfully",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7A9E6F),
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                "The credentials for the created admin are:",
                style: TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 24),

              // Username
              Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      "Username: $username",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () =>
                        _copy(context, username, "Username"),
                  )
                ],
              ),

              const SizedBox(height: 12),

              // Password
              Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      "Password: $password",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () =>
                        _copy(context, password, "Password"),
                  )
                ],
              ),

              const SizedBox(height: 40),

              Center(
                child: ElevatedButton.icon(
                  onPressed: () => _copyAll(context),
                  icon: const Icon(Icons.copy),
                  label: const Text(
                    "Copy All Credentials",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF55789A),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                  child: const Text(
                    "OK",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
