import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../l10n/app_localizations.dart';

class EmployeeSuccessScreen extends StatelessWidget {
  final String username;
  final String password;

  const EmployeeSuccessScreen({
    super.key,
    required this.username,
    required this.password,
  });

  void _copy(BuildContext context, String value, String label, AppLocalizations l10n) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.copiedToClipboard(label)),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _copyAll(BuildContext context, AppLocalizations l10n) {
    final combined = "Username: $username\nPassword: $password";
    Clipboard.setData(ClipboardData(text: combined));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.credentialsCopied),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              Text(
                l10n.appName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF55789A),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                l10n.employeeCreatedSuccess,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7A9E6F),
                ),
              ),

              const SizedBox(height: 32),

              Text(
                l10n.credentialsForEmployee,
                style: const TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 24),

              // Username
              Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      l10n.usernameLabel(username),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () =>
                        _copy(context, username, "Username", l10n),
                  )
                ],
              ),

              const SizedBox(height: 12),

              // Password
              Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      l10n.passwordLabel(password),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () =>
                        _copy(context, password, "Password", l10n),
                  )
                ],
              ),

              const SizedBox(height: 40),

              Center(
                child: ElevatedButton.icon(
                  onPressed: () => _copyAll(context, l10n),
                  icon: const Icon(Icons.copy),
                  label: Text(
                    l10n.copyAllCredentials,
                    style: const TextStyle(color: Colors.white),
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
                  child: Text(
                    l10n.ok,
                    style: const TextStyle(color: Colors.white),
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

