import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../../../../l10n/app_localizations.dart';

class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({super.key});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final Color primaryBlue = const Color(0xFF55789A);

  final _titleController = TextEditingController();
  final _orgController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _skillsController = TextEditingController();
  final _cityController = TextEditingController();
  final _durationController = TextEditingController();
  final _stipendController = TextEditingController();

  String _selectedCategory = 'TECH';
  final List<String> _categories = ['TECH', 'NON_TECH', 'MANAGERIAL', 'FIELD', 'INTERNSHIP'];

  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _orgController.dispose();
    _descriptionController.dispose();
    _skillsController.dispose();
    _cityController.dispose();
    _durationController.dispose();
    _stipendController.dispose();
    super.dispose();
  }

  Future<void> _submitJob() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final l10n = AppLocalizations.of(context)!;

    try {
      List<String> skills = _skillsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final jobData = {
        "title": _titleController.text.trim(),
        "organization": _orgController.text.trim(),
        "description": _descriptionController.text.trim(),
        "requiredSkills": skills,
        "category": _selectedCategory,
        "city": _cityController.text.trim(),
        "duration": _durationController.text.trim(),
        "stipend": _stipendController.text.trim(),
        "status": "OPEN",
      };

      await Provider.of<JobProvider>(context, listen: false).createJob(jobData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.jobCreatedSuccess), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(l10n.postANewJob, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(l10n.basicInformation, Icons.info_outline),
              _buildModernTextField(l10n.jobTitle, _titleController, Icons.work_outline),
              _buildModernTextField(l10n.organization, _orgController, Icons.business),

              const SizedBox(height: 16),
              _buildSectionHeader(l10n.jobSpecifications, Icons.settings_outlined),
              _buildModernDropdown(l10n),
              const SizedBox(height: 16),
              _buildModernTextField(l10n.city, _cityController, Icons.location_on_outlined),
              _buildModernTextField(l10n.duration, _durationController, Icons.timer_outlined, hint: l10n.durationHint),
              _buildModernTextField(l10n.stipend, _stipendController, Icons.payments_outlined, isNumber: true, hint: l10n.stipendHint),

              const SizedBox(height: 16),
              _buildSectionHeader(l10n.requirementsAndDetails, Icons.description_outlined),
              _buildModernTextField(l10n.requiredSkills, _skillsController, Icons.psychology_outlined, hint: l10n.skillsHint),
              _buildModernTextField(l10n.jobDescription, _descriptionController, Icons.notes, maxLines: 5),

              const SizedBox(height: 32),
              _buildSubmitButton(l10n),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: primaryBlue),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryBlue)),
        ],
      ),
    );
  }

  Widget _buildModernTextField(String label, TextEditingController controller, IconData icon,
      {int maxLines = 1, bool isNumber = false, String? hint}) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, size: 20),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryBlue, width: 1.5)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent)),
        ),
        validator: (value) => (value == null || value.trim().isEmpty) ? l10n.required : null,
      ),
    );
  }

  Widget _buildModernDropdown(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        decoration: InputDecoration(
          labelText: l10n.jobCategory,
          prefixIcon: const Icon(Icons.category_outlined, size: 20),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        ),
        items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
        onChanged: (val) => setState(() => _selectedCategory = val!),
      ),
    );
  }

  Widget _buildSubmitButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitJob,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(l10n.postJobOpportunity, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
    );
  }
}