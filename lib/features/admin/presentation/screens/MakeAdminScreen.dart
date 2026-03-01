// lib/features/admin/presentation/screens/make_admin_screen.dart

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/data/repository/user_repository.dart';
import 'SuperAdminSuccessScreen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/form_fields.dart';

class MakeAdminScreen extends StatefulWidget {
  const MakeAdminScreen({super.key});

  @override
  State<MakeAdminScreen> createState() => _MakeAdminScreenState();
}

class _MakeAdminScreenState extends State<MakeAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserRepository repository = UserRepository();

  bool _isLoading = false;

  // Controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  String? selectedDob;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Shilpkar Foundation",
          style: TextStyle(
            color: AppColors.appBarBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.makeAdmin,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.adminDetails,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),

                _buildLabeledTextField(
                  label: l10n.firstNameStar,
                  controller: firstNameController,
                  validator: (value) =>
                      value == null || value.isEmpty ? l10n.firstNameRequired : null,
                ),

                _buildLabeledTextField(
                  label: l10n.lastNameStar,
                  controller: lastNameController,
                  validator: (value) =>
                      value == null || value.isEmpty ? l10n.lastNameRequired : null,
                ),

                _buildLabeledDobField(l10n),

                _buildLabeledTextField(
                  label: l10n.mobileStar,
                  controller: mobileController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return l10n.mobileRequired;
                    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) return l10n.mobileMustBe10;
                    return null;
                  },
                ),

                _buildLabeledTextField(
                  label: l10n.emailStar, // Assuming email is not required based on screenshot (no *)
                  controller: emailController,
                  validator: (value) {
                    // Make email optional if it doesn't have a star, or validate if entered
                    if (value != null && value.isNotEmpty) {
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(value)) {
                        return l10n.enterValidEmail;
                      }
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 40),

                Center(
                  child: SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.appBarBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                await _submit(l10n);
                              }
                            },
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              l10n.makeAdmin,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
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
      final response = await repository.createAdmin(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        dob: selectedDob ?? "",
        mobile: mobileController.text.trim(),
        email: emailController.text.trim(),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              e.response?.data["message"] ?? l10n.errorCreatingAdmin),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildLabeledTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnly = false,
    Widget? suffixIcon,
    VoidCallback? onTap,
    String? hintText,
  }) {
    return LabeledTextField(
      label: label,
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      readOnly: readOnly,
      suffixIcon: suffixIcon,
      onTap: onTap,
      hint: hintText,
    );
  }

  Widget _buildLabeledDobField(AppLocalizations l10n) {
    return _buildLabeledTextField(
      label: l10n.dobStar,
      controller: dobController,
      readOnly: true,
      hintText: "dd/mm/yyyy",
      validator: (value) =>
          value == null || value.isEmpty ? l10n.dobRequired : null,
      suffixIcon: const Icon(Icons.calendar_today_outlined, color: Colors.grey),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime(1995),
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: AppColors.appBarBlue,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          selectedDob =
              "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
          dobController.text =
              "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
        }
      },
    );
  }
}
