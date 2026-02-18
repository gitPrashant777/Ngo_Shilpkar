import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/navigation/main_navigation.dart';
import '../providers/auth_provider.dart';
import '../../data/models/login_request.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  final String role;

  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isObscure = true;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                "Login as ${widget.role}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(
                  labelText: "Username / Email",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? "Enter ID" : null,
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _passwordController,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _isObscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  ),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? "Enter Password" : null,
              ),

              // Align(
              //   alignment: Alignment.centerRight,
              //   child: TextButton(
              //     onPressed: () {
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //           builder: (_) => const ForgotPasswordScreen(),
              //         ),
              //       );
              //     },
              //     child: const Text("Forgot Password?"),
              //   ),
              // ),

              const SizedBox(height: 20),

              authProvider.isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    print("====== LOGIN START ======");
                    print("Role: ${widget.role}");
                    print("ID Entered: ${_idController.text}");
                    print("Password Entered: ${_passwordController.text}");

                    final request = LoginRequest(
                      username: widget.role == "SUPER_ADMIN"
                          ? null
                          : _idController.text.trim(),
                      email: widget.role == "SUPER_ADMIN"
                          ? _idController.text.trim()
                          : null,
                      password:
                      _passwordController.text.trim(),
                      loginAsRole: widget.role,
                    );

                    print("Request JSON: ${request.toJson()}");

                    final success =
                    await context.read<AuthProvider>().login(request);

                    print("Login Success: $success");
                    print("Provider Role: ${context.read<AuthProvider>().role}");
                    print("Provider Error: ${authProvider.errorMessage}");
                    print("====== LOGIN END ======");

                    if (!mounted) return;

                    if (success) {
                      final role =
                          context.read<AuthProvider>().role;

                      if (role == "SUPER_ADMIN" ||
                          role == "ADMIN") {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MainNavigationScreen()),
                              (route) => false,
                        );

                      } else {
                        Navigator.pushReplacementNamed(
                            context, "/home");
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            authProvider.errorMessage ??
                                "Login failed",
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text("Login"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
