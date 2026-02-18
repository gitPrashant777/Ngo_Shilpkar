// lib/features/admin/presentation/screens/make_admin_screen.dart

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: const Text("Make Admin"),
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

                const Text(
                  "Admin Details",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                _buildTextField(
                  "First Name*",
                  firstNameController,
                  validator: (value) =>
                  value == null || value.isEmpty
                      ? "First name required"
                      : null,
                ),

                _buildTextField(
                  "Last Name*",
                  lastNameController,
                  validator: (value) =>
                  value == null || value.isEmpty
                      ? "Last name required"
                      : null,
                ),

                _buildTextField(
                  "Mobile*",
                  mobileController,
                  keyboardType:
                  TextInputType.number,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty)
                      return "Mobile required";
                    if (!RegExp(
                        r'^[0-9]{10}$')
                        .hasMatch(value))
                      return "Mobile must be 10 digits";
                    return null;
                  },
                ),

                _buildTextField(
                  "Email*",
                  emailController,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty)
                      return "Email required";
                    if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$')
                        .hasMatch(value))
                      return "Enter valid email";
                    return null;
                  },
                ),

                _buildDOBField(),

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
                        await _submit();
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
                        : const Text(
                      "Make Admin",
                      style: TextStyle(
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

  Future<void> _submit() async {
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
                  "Error creating admin"),
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

  Widget _buildDOBField() {
    return Padding(
      padding:
      const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: dobController,
        readOnly: true,
        validator: (value) =>
        value == null ||
            value.isEmpty
            ? "DOB required"
            : null,
        decoration:
        const InputDecoration(
          labelText: "DOB*",
          border:
          OutlineInputBorder(),
          suffixIcon: Icon(
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
