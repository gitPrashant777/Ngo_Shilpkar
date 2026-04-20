import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import 'job_list_screen.dart';

/// User must submit resume + live photo + personal info before viewing jobs
class JobApplicationPreScreen extends StatefulWidget {
  const JobApplicationPreScreen({super.key});

  @override
  State<JobApplicationPreScreen> createState() =>
      _JobApplicationPreScreenState();
}

class _JobApplicationPreScreenState extends State<JobApplicationPreScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _skillsController = TextEditingController();

  File? _livePhoto;
  File? _resumeFile;
  String? _resumeFileName;
  bool _submitting = false;
  bool _submitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _qualificationController.dispose();
    _experienceController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  Future<void> _takeLivePhoto() async {
    final result = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (result != null) {
      setState(() => _livePhoto = File(result.path));
    }
  }

  Future<void> _pickResume() async {
    // In a real app, use file_picker package for PDF/DOC
    // For now, simulate picking from gallery as image
    final result = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (result != null) {
      setState(() {
        _resumeFile = File(result.path);
        _resumeFileName = result.name;
      });
    }
  }

  void _submitApplication() async {
    if (_formKey.currentState!.validate()) {
      if (_livePhoto == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please take a live photo before proceeding.'),
          backgroundColor: Colors.orange,
        ));
        return;
      }
      setState(() => _submitting = true);
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _submitting = false;
        _submitted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return _buildSuccessScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: AppColors.appBarBlue,
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Apply for Job',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Submit your profile first',
                style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.appBarBlue),
        ),
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 2) {
              setState(() => _currentStep++);
            } else {
              _submitApplication();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) setState(() => _currentStep--);
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitting ? null : details.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.appBarBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Text(
                              _currentStep < 2 ? 'Continue' : 'Submit Profile',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: details.onStepCancel,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.appBarBlue,
                          side: const BorderSide(color: AppColors.appBarBlue),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            Step(
              title: const Text('Personal Info',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text('Basic contact details',
                  style: TextStyle(fontSize: 11)),
              isActive: _currentStep >= 0,
              state: _currentStep > 0
                  ? StepState.complete
                  : StepState.indexed,
              content: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildField('Full Name', _nameController, Icons.person_outline),
                    const SizedBox(height: 10),
                    _buildField('Email Address', _emailController,
                        Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 10),
                    _buildField('Phone Number', _phoneController,
                        Icons.phone_outlined,
                        keyboardType: TextInputType.phone),
                    const SizedBox(height: 10),
                    _buildField('Address', _addressController,
                        Icons.home_outlined,
                        maxLines: 2),
                  ],
                ),
              ),
            ),
            Step(
              title: const Text('Qualifications',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle:
                  const Text('Education & experience', style: TextStyle(fontSize: 11)),
              isActive: _currentStep >= 1,
              state: _currentStep > 1
                  ? StepState.complete
                  : StepState.indexed,
              content: Column(
                children: [
                  _buildField('Highest Qualification',
                      _qualificationController, Icons.school_outlined),
                  const SizedBox(height: 10),
                  _buildField(
                      'Years of Experience', _experienceController, Icons.work_outline,
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 10),
                  _buildField(
                      'Skills (comma separated)', _skillsController,
                      Icons.stars_outlined,
                      maxLines: 2),
                  const SizedBox(height: 10),

                  // Resume Upload
                  GestureDetector(
                    onTap: _pickResume,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: _resumeFile != null
                                ? Colors.green
                                : Colors.grey.shade300),
                        image: null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _resumeFile != null
                                ? Icons.check_circle_outline
                                : Icons.upload_file_outlined,
                            color: _resumeFile != null
                                ? Colors.green
                                : Colors.grey.shade500,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _resumeFile != null
                                  ? 'Resume: $_resumeFileName'
                                  : 'Tap to upload Resume (PDF/DOC)',
                              style: TextStyle(
                                  color: _resumeFile != null
                                      ? Colors.green
                                      : Colors.grey.shade600,
                                  fontSize: 13),
                            ),
                          ),
                          if (_resumeFile == null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.appBarBlue,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('Upload',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 11)),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Step(
              title: const Text('Live Photo',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text('Take a selfie for verification',
                  style: TextStyle(fontSize: 11)),
              isActive: _currentStep >= 2,
              state: StepState.indexed,
              content: Column(
                children: [
                  // Info box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.orange, size: 18),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'A live photo is required for identity verification. Please take a clear selfie.',
                            style: TextStyle(fontSize: 12, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Camera button / preview
                  GestureDetector(
                    onTap: _takeLivePhoto,
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: _livePhoto != null
                                ? Colors.green
                                : Colors.grey.shade300,
                            width: 2),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _livePhoto != null
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(_livePhoto!, fit: BoxFit.cover),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check, color: Colors.white, size: 12),
                                        SizedBox(width: 4),
                                        Text('Live Photo',
                                            style: TextStyle(
                                                color: Colors.white, fontSize: 11)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt_outlined,
                                    size: 48, color: Colors.grey.shade400),
                                const SizedBox(height: 8),
                                Text('Tap to take Live Photo',
                                    style: TextStyle(
                                        color: Colors.grey.shade500, fontSize: 13)),
                                const SizedBox(height: 4),
                                Text('(Front camera will be used)',
                                    style: TextStyle(
                                        color: Colors.grey.shade400, fontSize: 11)),
                              ],
                            ),
                    ),
                  ),

                  if (_livePhoto != null) ...[
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: _takeLivePhoto,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Retake Photo'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (v) => v == null || v.trim().isEmpty ? '$label is required' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: Colors.grey.shade500),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: AppColors.appBarBlue,
        foregroundColor: Colors.white,
        title: const Text('Profile Submitted'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline,
                    color: Colors.green, size: 50),
              ),
              const SizedBox(height: 24),
              const Text(
                'Profile Submitted Successfully!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Your resume, live photo, and personal information have been submitted. You can now browse and apply for available jobs.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const JobListScreen()),
                  ),
                  icon: const Icon(Icons.work_outline),
                  label: const Text('Browse Available Jobs',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appBarBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
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
