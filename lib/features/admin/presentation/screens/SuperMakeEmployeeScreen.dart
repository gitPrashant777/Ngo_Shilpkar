import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../auth/data/repository/user_repository.dart';
import 'SuperEmployeeSuccessScreen.dart';

class MakeEmployeeScreen extends StatefulWidget {
  final String role;

  const MakeEmployeeScreen({super.key, required this.role});

  @override
  State<MakeEmployeeScreen> createState() => _MakeEmployeeScreenState();
}

class _MakeEmployeeScreenState extends State<MakeEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _allFormData = {};
  final Color primaryBlue = const Color(0xFF55789A);

  // Controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final dobController = TextEditingController();
  final accountNumberController = TextEditingController();
  final accountHolderController = TextEditingController();
  final ifscController = TextEditingController();

  String? selectedDob, selectedDistrict, selectedTaluka, selectedVillage, selectedAccountType;

  final Map<String, List<String>> districtTalukaMap = {
    "Latur": ["Latur", "Ausa", "Nilanga"],
    "Pune": ["Haveli", "Shirur", "Mulshi"],
  };

  final Map<String, List<String>> talukaVillageMap = {
    "Latur": ["Village A", "Village B"],
    "Ausa": ["Village C", "Village D"],
    "Nilanga": ["Village E"],
    "Haveli": ["Village F"],
    "Shirur": ["Village G"],
    "Mulshi": ["Village H"],
  };

  @override
  void initState() {
    super.initState();
    _allFormData["role"] = widget.role;
  }

  // --- UI: MODERN PROGRESS BAR (Horizontal Lines) ---
  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: List.generate(3, (index) {
          // Logic to highlight sections based on filled data
          bool section1 = firstNameController.text.isNotEmpty && mobileController.text.isNotEmpty;
          bool section2 = selectedDistrict != null && selectedTaluka != null;
          bool section3 = accountNumberController.text.isNotEmpty && selectedAccountType != null;

          Color getColor(int i) {
            if (i == 0 && section1) return primaryBlue;
            if (i == 1 && section2) return primaryBlue;
            if (i == 2 && section3) return primaryBlue;
            return Colors.grey.shade300;
          }

          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: getColor(index),
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repository = UserRepository();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(
          "Create ${widget.role}",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgressBar(),
                const Text(
                  "Registration Form",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF55789A)),
                ),
                const SizedBox(height: 8),
                const Text("Complete all sections to create the account.", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 25),

                // PERSONAL INFORMATION
                _sectionHeader("Personal Information"),
                _buildTextField("First Name*", firstNameController, validator: (v) => v!.isEmpty ? "Required" : null),
                _buildTextField("Last Name*", lastNameController, validator: (v) => v!.isEmpty ? "Required" : null),
                _buildTextField("Mobile*", mobileController,
                    keyboardType: TextInputType.number,
                    validator: (v) => (v!.length != 10) ? "10 digits required" : null),
                _buildTextField("Email*", emailController,
                    validator: (v) => !v!.contains("@") ? "Invalid email" : null),
                if (widget.role == "COORDINATOR") _buildDOBField(),

                const SizedBox(height: 20),

                // LOCATION
                _sectionHeader("Location Details"),
                _buildDropdown("District*", selectedDistrict, districtTalukaMap.keys.toList(), (val) {
                  setState(() {
                    selectedDistrict = val;
                    selectedTaluka = null;
                    selectedVillage = null;
                  });
                }),
                _buildDropdown("Taluka*", selectedTaluka,
                    selectedDistrict == null ? [] : districtTalukaMap[selectedDistrict!]!,
                        (val) => setState(() => selectedTaluka = val)),
                _buildDropdown("Village*", selectedVillage,
                    selectedTaluka == null ? [] : talukaVillageMap[selectedTaluka!]!,
                        (val) => setState(() => selectedVillage = val)),

                const SizedBox(height: 20),

                // BANK DETAILS
                _sectionHeader("Bank Information"),
                _buildTextField("Account Number*", accountNumberController,
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.length < 9 ? "Too short" : null),
                _buildTextField("Account Holder*", accountHolderController, validator: (v) => v!.isEmpty ? "Required" : null),
                _buildTextField("IFSC*", ifscController,
                    validator: (v) => (v!.length != 11) ? "11 characters required" : null),
                _buildDropdown("Account Type*", selectedAccountType, ["Savings", "Current"],
                        (val) => setState(() => selectedAccountType = val)),

                const SizedBox(height: 40),

                // SUBMIT BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () async {
                      // FIXED: Removed redundant manual null checks.
                      // Form validators now handle everything correctly.
                      if (_formKey.currentState!.validate()) {
                        await _submit(repository);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please complete all required fields"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: const Text(
                      "CREATE EMPLOYEE",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
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

  // --- WIDGET HELPERS ---

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, top: 10),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        onChanged: (_) => setState(() {}), // Refresh progress bar
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: value,
        validator: (val) => (val == null || val.isEmpty) ? "Required" : null,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (val) {
          onChanged(val);
          _formKey.currentState!.validate(); // Clear error highlight on selection
        },
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
        ),
      ),
    );
  }

  Widget _buildDOBField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: dobController,
        readOnly: true,
        validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
        decoration: InputDecoration(
          labelText: "Date of Birth*",
          suffixIcon: const Icon(Icons.calendar_today, size: 20),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
        ),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime(2000),
            firstDate: DateTime(1950),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            setState(() {
              selectedDob = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
              dobController.text = selectedDob!;
            });
          }
        },
      ),
    );
  }

  Future<void> _submit(UserRepository repository) async {
    _allFormData.addAll({
      "firstName": firstNameController.text,
      "lastName": lastNameController.text,
      "mobile": mobileController.text,
      "email": emailController.text,
      "dob": selectedDob,
      "district": selectedDistrict,
      "taluka": selectedTaluka,
      "village": selectedVillage,
      "state": "Maharashtra",
      "accountNumber": accountNumberController.text,
      "accountHolderName": accountHolderController.text,
      "ifsc": ifscController.text.toUpperCase(),
      "accountType": selectedAccountType,
    });

    try {
      final res = await repository.createEmployee(_allFormData);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => EmployeeSuccessScreen(
              username: res["username"],
              password: res["password"],
            ),
          ),
        );
      }
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.response?.data["message"] ?? "Error creating employee"), backgroundColor: Colors.red),
      );
    }
  }
}