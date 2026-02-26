// lib/features/admin/presentation/screens/make_admin_screen.dart

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/data/repository/user_repository.dart';
import 'SuperAdminSuccessScreen.dart';

class MakeAdminScreen extends StatefulWidget {
  const MakeAdminScreen({super.key});

  @override
  State<MakeAdminScreen> createState() => _MakeAdminScreenState();
}

class _MakeAdminScreenState extends State<MakeAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserRepository repository = UserRepository();

  bool _isLoading = false;

  final Color primaryBlue = const Color(0xFF55789A);

  // Controllers
  final TextEditingController firstNameController =
  TextEditingController();
  final TextEditingController lastNameController =
  TextEditingController();
  final TextEditingController mobileController =
  TextEditingController();
  final TextEditingController emailController =
  TextEditingController();
  final TextEditingController dobController =
  TextEditingController();

  String? selectedDob;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: Text(l10n.makeAdmin),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [

                Text(
                  l10n.adminDetails,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                _buildTextField(
                  l10n.firstNameStar,
                  firstNameController,
                  validator: (value) =>
                  value == null || value.isEmpty
                      ? l10n.firstNameRequired
                      : null,
                ),

                _buildTextField(
                  l10n.lastNameStar,
                  lastNameController,
                  validator: (value) =>
                  value == null || value.isEmpty
                      ? l10n.lastNameRequired
                      : null,
                ),

                _buildTextField(
                  l10n.mobileStar,
                  mobileController,
                  keyboardType:
                  TextInputType.number,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty)
                      return l10n.mobileRequired;
                    if (!RegExp(
                        r'^[0-9]{10}$')
                        .hasMatch(value))
                      return l10n.mobileMustBe10;
                    return null;
                  },
                ),

                _buildTextField(
                  l10n.emailStar,
                  emailController,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty)
                      return l10n.emailRequired;
                    if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$')
                        .hasMatch(value))
                      return l10n.enterValidEmail;
                    return null;
                  },
                ),

                _buildDOBField(l10n),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton
                        .styleFrom(
                      backgroundColor:
                      primaryBlue,
                      padding:
                      const EdgeInsets
                          .symmetric(
                          vertical: 14),
                    ),
                    onPressed: _isLoading
                        ? null
                        : () async {
                      if (_formKey
                          .currentState!
                          .validate()) {
                        await _submit(l10n);
                      }
                    },
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                        color:
                        Colors.white,
                      ),
                    )
                        : Text(
                      l10n.makeAdmin,
                      style: const TextStyle(
                          color: Colors
                              .white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit(AppLocalizations l10n) async {
    setState(() => _isLoading = true);

    try {
      final response =
      await repository.createAdmin(
        firstName:
        firstNameController.text.trim(),
        lastName:
        lastNameController.text.trim(),
        dob: selectedDob ?? "",
        mobile:
        mobileController.text.trim(),
        email:
        emailController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AdminSuccessScreen(
            username: response["username"],
            password: response["password"],
          ),
        ),
      );
    } on DioException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
              e.response?.data["message"] ??
                  l10n.errorCreatingAdmin),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller, {
        TextInputType keyboardType =
            TextInputType.text,
        String? Function(String?)? validator,
      }) {
    return Padding(
      padding:
      const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildDOBField(AppLocalizations l10n) {
    return Padding(
      padding:
      const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: dobController,
        readOnly: true,
        validator: (value) =>
        value == null ||
            value.isEmpty
            ? l10n.dobRequired
            : null,
        decoration:
        InputDecoration(
          labelText: l10n.dobStar,
          border:
          const OutlineInputBorder(),
          suffixIcon: const Icon(
              Icons.calendar_today),
        ),
        onTap: () async {
          final picked =
          await showDatePicker(
            context: context,
            initialDate:
            DateTime(1995),
            firstDate:
            DateTime(1950),
            lastDate:
            DateTime.now(),
          );
          if (picked != null) {
            selectedDob =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
            dobController.text =
            selectedDob!;
          }
        },
      ),
    );
  }
}

