import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/location_service.dart';
import '../../data/models/job_model.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/job_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../ecommerce/presentation/providers/customer_auth_provider.dart';
import '../../../../core/utils/token_holder.dart';
import '../../../auth/presentation/screens/beneficiary_login_screen.dart';
import 'local_job_data.dart';
import 'job_list_screen.dart';

// ─── Colour aliases mapping old constants → AppColors ───────────────────────
const _kPrimary = AppColors.profileBlue; // 0xFF1E5799
const _kAccent = AppColors.lightBlueScheme; // 0xFF4A78B0
const _kBg = AppColors.lightBackground; // 0xFFF5F7F9
const _kCard = AppColors.cardBackground; // white
const _kLabel = AppColors.textPrimary; // 0xFF2D3134
const _kSubLabel = AppColors.textSecondary; // 0xFF6C757D
const _kBorder = AppColors.dividerGrey; // 0xFFE0E0E0

// ─── Step definitions ─────────────────────────────────────────────────────────
enum _Step { basic, location, education }

class ApplyJobScreen extends StatefulWidget {
  final String? jobId;
  final bool isPreScreen;
  const ApplyJobScreen({super.key, this.jobId, this.isPreScreen = false});

  @override
  State<ApplyJobScreen> createState() => _ApplyJobScreenState();
}

class _ApplyJobScreenState extends State<ApplyJobScreen>
    with SingleTickerProviderStateMixin {
  // ── controllers ──────────────────────────────────────────────────────────────
  final _basicKey = GlobalKey<FormState>();
  final _locationKey = GlobalKey<FormState>();
  final _educationKey = GlobalKey<FormState>();

  // Basic Details
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  // Location Details
  final _districtCtrl = TextEditingController();
  final _talukaCtrl = TextEditingController();
  final _villageCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String _state = 'Maharashtra';

  // Education & Experience
  String? _qualification;
  String? _experienceLevel;
  String? _jobType;
  bool _fieldLocations = false;
  bool _communities = false;
  bool _travelDistrict = false;
  File? _resumeFile;
  String? _resumeName;
  String? _resumeSize; // Human-readable file size
  File? _photoFile;
  String? _photoSize;
  String? _resumeUrl; // loaded from local
  String? _photoUrl; // loaded from local

  // Role Check
  bool _isBeneficiary = false;
  bool _isLocating = false;

  // ── step state ───────────────────────────────────────────────────────────────
  _Step _current = _Step.basic;
  late final AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  List<String> _getQualifications(AppLocalizations l10n) => [
    l10n.qual10thSSC,
    l10n.qual12thHSC,
    l10n.qualDiploma,
    l10n.qualGraduate,
    l10n.qualPostGraduate,
    l10n.qualOther,
  ];

  List<String> _getExperienceLevels(AppLocalizations l10n) => [
    l10n.expFresher,
    l10n.exp1To2Years,
    l10n.exp3To5Years,
    l10n.exp5PlusYears,
  ];

  List<String> _getJobTypes(AppLocalizations l10n) => [
    l10n.jobTypeFullTime,
    l10n.jobTypePartTime,
    l10n.jobTypeContract,
    l10n.jobTypeVolunteer,
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final customerauthProvider = Provider.of<CustomerAuthProvider>(
        context,
        listen: false,
      );

      final role = authProvider.role;

      if (role == 'BENEFICIARY') {
        setState(() {
          _isBeneficiary = true;
          _current = _Step.education; // Skip to Education for Beneficiaries
        });
      }

      // Fetch Profile to pre-fill from AuthProvider if Beneficiary
      if (role == 'BENEFICIARY' && authProvider.userProfile == null) {
        await authProvider.fetchUserProfile();
      }

      final profile = authProvider.userProfile?.profile;
      final user = authProvider.userProfile?.user;
      final customer = customerauthProvider.currentCustomer;

      if (profile != null) {
        setState(() {
          // Pre-fill fields from AuthProvider
          _firstNameCtrl.text = profile.firstName ?? user?.username ?? '';
          _lastNameCtrl.text = profile.lastName ?? '';
          _dobCtrl.text = profile.dob ?? '';
          _mobileCtrl.text = user?.mobile ?? '';
          _emailCtrl.text = user?.email ?? '';

          _state = profile.location.state ?? 'Maharashtra';
        });
      } else if (customer != null) {
        setState(() {
          // Pre-fill fields from CustomerAuthProvider
          final fullName = customer.fullName ?? '';
          if (fullName.contains(' ')) {
            final parts = fullName.split(' ');
            _firstNameCtrl.text = parts.first;
            _lastNameCtrl.text = parts.skip(1).join(' ');
          } else {
            _firstNameCtrl.text = fullName;
          }
          _mobileCtrl.text = customer.mobile ?? '';
          _emailCtrl.text = customer.email.isNotEmpty ? customer.email : '';
        });
      }

      // Load local data
      final localData = await LocalJobDataStorage.getJobData();
      if (localData != null) {
        setState(() {
          if (localData['firstName'] != null && _firstNameCtrl.text.isEmpty)
            _firstNameCtrl.text = localData['firstName'];
          if (localData['lastName'] != null && _lastNameCtrl.text.isEmpty)
            _lastNameCtrl.text = localData['lastName'];
          if (localData['dob'] != null && _dobCtrl.text.isEmpty) {
            String db = localData['dob'];
            if (db.contains('-')) {
              final p = db.split('-');
              _dobCtrl.text = '${p[2]}/${p[1]}/${p[0]}';
            } else {
              _dobCtrl.text = db;
            }
          }
          if (localData['mobile'] != null && _mobileCtrl.text.isEmpty)
            _mobileCtrl.text = localData['mobile'];
          if (localData['email'] != null && _emailCtrl.text.isEmpty)
            _emailCtrl.text = localData['email'];

          if (localData['location'] != null) {
            final loc = localData['location'];
            if (loc['state'] != null && _state == 'Maharashtra')
              _state = loc['state'];
            if (loc['district'] != null && _districtCtrl.text.isEmpty)
              _districtCtrl.text = loc['district'];
            if (loc['taluka'] != null && _talukaCtrl.text.isEmpty)
              _talukaCtrl.text = loc['taluka'];
            if (loc['village'] != null && _villageCtrl.text.isEmpty)
              _villageCtrl.text = loc['village'];
            if (loc['address'] != null && _addressCtrl.text.isEmpty)
              _addressCtrl.text = loc['address'];
          }

          if (localData['highestQualification'] != null &&
              _qualification == null)
            _qualification = localData['highestQualification'];
          if (localData['experienceLevel'] != null && _experienceLevel == null)
            _experienceLevel = localData['experienceLevel'];
          if (localData['jobType'] != null && _jobType == null)
            _jobType = localData['jobType'];

          if (localData['availability'] != null) {
            List avail = localData['availability'];
            _fieldLocations = avail.contains('field');
            _communities = avail.contains('community');
            _travelDistrict = avail.contains('travel');
          }

          if (localData['resumeUrl'] != null)
            _resumeUrl = localData['resumeUrl'];
          if (localData['photoUrl'] != null) _photoUrl = localData['photoUrl'];
        });
      }

      // Only forward animation if starting at Basic (Guest)
      // If Beneficiary, we are already at Education, no need for step transition animation immediately
      if (!_isBeneficiary) {
        _animCtrl.forward();
      } else {
        _animCtrl.value = 1.0; // Show immediately
      }
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _dobCtrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    _districtCtrl.dispose();
    _talukaCtrl.dispose();
    _villageCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _detectLocation() async {
    setState(() => _isLocating = true);
    try {
      final locData = await LocationService().detectAndResolveLocation();
      setState(() {
        _state = locData['state'] ?? _state;
        _districtCtrl.text = locData['district'] ?? _districtCtrl.text;
        _talukaCtrl.text = locData['taluka'] ?? _talukaCtrl.text;
        _villageCtrl.text = locData['village'] ?? _villageCtrl.text;
        _addressCtrl.text = locData['autoAddress'] ?? _addressCtrl.text;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to detect location: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  // ── navigation helpers ────────────────────────────────────────────────────────
  void _nextStep() {
    _animCtrl.reverse().then((_) {
      setState(() {
        if (_current == _Step.basic) {
          _current = _Step.location;
        } else if (_current == _Step.location) {
          _current = _Step.education;
        }
      });
      _animCtrl.forward();
    });
  }

  void _prevStep() {
    // If beneficiary, prevent going back to basic/location
    if (_isBeneficiary) {
      Navigator.pop(context);
      return;
    }

    _animCtrl.reverse().then((_) {
      setState(() {
        if (_current == _Step.location) {
          _current = _Step.basic;
        } else if (_current == _Step.education) {
          _current = _Step.location;
        }
      });
      _animCtrl.forward();
    });
  }

  // ── submission ────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_educationKey.currentState!.validate()) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final provider = context.read<JobProvider>();
      final authProvider = context.read<AuthProvider>();

      
      final user = authProvider.userProfile?.user;

      // ── Determine if this is a guest (no NGO admin token) ──────
      final bool isNgoUser = tokenHolder.hasAdminToken;

      // ── Upload files (NGO users only) ───────────────────────────
      // The /uploads endpoint requires an NGO admin token.
      // Guests skip file upload; resumeUrl/photoUrl are optional in the API.
      String? resumeUrl;
      String? photoUrl;

      if (!isNgoUser) {
        // Guest: re-use any pre-stored URL (e.g., from a previous session),
        // otherwise skip. File upload is not available without NGO login.
        resumeUrl = _resumeUrl;
        photoUrl = _photoUrl;

        if (_resumeFile != null || _photoFile != null) {
          // Inform the user that files can't be uploaded as guest
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  '📎 File upload requires a Beneficiary login. '
                  'Your application will be submitted without attachments.',
                ),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 5),
              ),
            );
          }
          // Small delay so the snack is visible before submit continues
          await Future.delayed(const Duration(milliseconds: 400));
        }
      } else {
        // NGO user — upload normally with admin token
        if (_resumeFile != null) {
          final result = await provider.uploadFile(_resumeFile!.path, 'jobs');
          resumeUrl = result['url'];
        } else if (_resumeUrl != null) {
          resumeUrl = _resumeUrl;
        }

        if (_photoFile != null) {
          final result = await provider.uploadFile(_photoFile!.path, 'jobs');
          photoUrl = result['url'];
        } else if (_photoUrl != null) {
          photoUrl = _photoUrl;
        }
      }


        // Convert date from dd/mm/yyyy to yyyy-mm-dd for API
        String dobForApi = _dobCtrl.text.trim();
        if (dobForApi.contains('/')) {
          final parts = dobForApi.split('/');
          if (parts.length == 3) {
            dobForApi = '${parts[2]}-${parts[1]}-${parts[0]}';
          }
        }

        final List<String> availability = [];
        if (_fieldLocations) availability.add("field");
        if (_communities) availability.add("community");
        if (_travelDistrict) availability.add("travel");

        // ── Build payload ───────────────────────────────────────────
        // Matches the API spec exactly.
        // Guest  → no userId field, skipAuth fired in repository
        // NGO user → userId included, admin token sent
        final String? resolvedUserId =
            (user != null && user.id.isNotEmpty) ? user.id
            : (authProvider.userId?.isNotEmpty == true) ? authProvider.userId
            : null;
        final bool isGuestApply = resolvedUserId == null || resolvedUserId.isEmpty;

        final Map<String, dynamic> payload = {
          'firstName': _firstNameCtrl.text.trim(),
          'lastName': _lastNameCtrl.text.trim(),
          'dob': dobForApi,
          'mobile': _mobileCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'location': {
            'state': _state,
            'district': _districtCtrl.text.trim(),
            'taluka': _talukaCtrl.text.trim(),
            'village': _villageCtrl.text.trim(),
            'address': _addressCtrl.text.trim(),
          },
          'highestQualification': _qualification ?? '',
          'experienceLevel': _experienceLevel ?? '',
          'jobType': _jobType ?? '',
          'availability': availability,
          if (resumeUrl != null) 'resumeUrl': resumeUrl,
          if (photoUrl != null) 'photoUrl': photoUrl,
          // NGO Beneficiary: send userId + admin token (interceptor handles token)
          // Guest / Customer: send isGuest:true + customer token (interceptor handles token)
          'isGuest': isGuestApply,
          if (!isGuestApply) 'userId': resolvedUserId,
        };

      debugPrint("📤 APPLY JOB PAYLOAD: $payload");

      // Always save form data locally — so it's pre-filled next time
      await LocalJobDataStorage.saveJobData(payload);

      // ── Pre-screen: just save + go to job list ─────────────────
      if (widget.isPreScreen) {
        if (mounted) Navigator.pop(context); // close loading dialog
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const JobListScreen()),
          );
        }
        return;
      }

      // ── Submit to API ─────────────────────────────────────────────
      // NGO Beneficiary : admin token (interceptor) + userId in body
      // Guest / Customer: customer token (interceptor) + isGuest:true in body
      // The interceptor prefers adminToken, falls back to customerToken.
      final result = await provider.applyJob(widget.jobId!, payload);
      final applicationId = result['applicationId']?.toString();
      debugPrint("✅ Application submitted — ID: $applicationId");

      // Dismiss loading dialog
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              applicationId != null
                  ? "✅ Application submitted! ID: $applicationId"
                  : "✅ ${AppLocalizations.of(context)!.applicationSubmittedSuccess}",
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // pop the screen
      }
    } catch (e) {
      // Dismiss loading dialog
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ ${e.toString().replaceAll('Exception: ', '')}"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // ── date picker ───────────────────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(
          context,
        ).copyWith(colorScheme: const ColorScheme.light(primary: _kPrimary)),
        child: child!,
      ),
    );
    if (picked != null) {
      _dobCtrl.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  // ── file pickers ──────────────────────────────────────────────────────────────
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _pickResume() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final sizeBytes = await file.length();
      const maxBytes = 5 * 1024 * 1024; // 5 MB

      if (sizeBytes > maxBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '❌ ${AppLocalizations.of(context)!.resumeTooLarge(_formatFileSize(sizeBytes))}',
              ),
              backgroundColor: Colors.redAccent,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      setState(() {
        _resumeFile = file;
        _resumeName = result.files.single.name;
        _resumeSize = _formatFileSize(sizeBytes);
      });
    }
  }

  Future<void> _openCamera() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70, // Compress to reduce size automatically
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (img != null) {
      final file = File(img.path);
      final sizeBytes = await file.length();
      const maxBytes = 2 * 1024 * 1024; // 2 MB

      if (sizeBytes > maxBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '❌ ${AppLocalizations.of(context)!.photoTooLarge(_formatFileSize(sizeBytes))}',
              ),
              backgroundColor: Colors.redAccent,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      setState(() {
        _photoFile = file;
        _photoSize = _formatFileSize(sizeBytes);
      });
    }
  }

  // ── progress bar ──────────────────────────────────────────────────────────────
  int get _stepIndex => _current.index;
  double get _progress => (_stepIndex + 1) / 3;

  // ────────────────────────────────────────────────────────────────────────────
  //  BUILD
  // ────────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: _kBg,
      appBar: _buildAppBar(l10n),
      body: Column(
        children: [
          _StepIndicator(currentStep: _stepIndex),
          if (_isBeneficiary)
            Container(
              width: double.infinity,
              color: Colors.green.shade50,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    l10n.loggedInAs(
                      '${_firstNameCtrl.text} ${_lastNameCtrl.text}',
                    ),
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: _buildCurrentStep(l10n),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n) {
    return AppBar(
      elevation: 0,
      backgroundColor: _kCard,
      foregroundColor: _kPrimary,
      leading: _stepIndex > 0
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: _prevStep,
            )
          : null,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.shilpkarFoundation,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _kPrimary,
              letterSpacing: 0.3,
            ),
          ),
          Text(
            widget.isPreScreen ? "Pre-Screen Profile" : l10n.jobApplication,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _kLabel,
            ),
          ),
        ],
      ),
      titleSpacing: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: _progress),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          builder: (_, val, __) => LinearProgressIndicator(
            value: val,
            backgroundColor: const Color(0xFFE0E7EF),
            valueColor: const AlwaysStoppedAnimation(_kAccent),
            minHeight: 4,
          ),
        ),
      ),
    );
  }

  // ── step router
  Widget _buildCurrentStep(AppLocalizations l10n) {
    switch (_current) {
      case _Step.basic:
        return _BasicDetailsStep(
          formKey: _basicKey,
          firstNameCtrl: _firstNameCtrl,
          lastNameCtrl: _lastNameCtrl,
          dobCtrl: _dobCtrl,
          mobileCtrl: _mobileCtrl,
          emailCtrl: _emailCtrl,
          onPickDate: _pickDate,
          onContinue: () {
            if (_basicKey.currentState!.validate()) _nextStep();
          },
        );
      case _Step.location:
        return _LocationStep(
          formKey: _locationKey,
          state: _state,
          districtCtrl: _districtCtrl,
          talukaCtrl: _talukaCtrl,
          villageCtrl: _villageCtrl,
          addressCtrl: _addressCtrl,
          isLocating: _isLocating,
          onDetectLocation: _detectLocation,
          onContinue: () {
            if (_locationKey.currentState!.validate()) _nextStep();
          },
        );
      case _Step.education:
        return _EducationStep(
          formKey: _educationKey,
          qualifications: _getQualifications(l10n),
          experienceLevels: _getExperienceLevels(l10n),
          jobTypes: _getJobTypes(l10n),
          selectedQualification: _qualification,
          selectedExperience: _experienceLevel,
          selectedJobType: _jobType,
          fieldLocations: _fieldLocations,
          communities: _communities,
          travelDistrict: _travelDistrict,
          resumeName: _resumeName,
          resumeSize: _resumeSize,
          resumeUrl: _resumeUrl,
          photoFile: _photoFile,
          photoSize: _photoSize,
          photoUrl: _photoUrl,
          onQualificationChanged: (v) => setState(() => _qualification = v),
          onExperienceChanged: (v) => setState(() => _experienceLevel = v),
          onJobTypeChanged: (v) => setState(() => _jobType = v),
          onFieldLocationsChanged: (v) => setState(() => _fieldLocations = v!),
          onCommunitiesChanged: (v) => setState(() => _communities = v!),
          onTravelChanged: (v) => setState(() => _travelDistrict = v!),
          onPickResume: _pickResume,
          onOpenCamera: _openCamera,
          onSubmit: _submit,
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  STEP INDICATOR
// ─────────────────────────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labels = [
      l10n.basicDetails,
      l10n.locationDetails,
      l10n.educationExperience,
    ];
    return Container(
      color: _kCard,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: List.generate(labels.length, (i) {
          final active = i == currentStep;
          final done = i < currentStep;
          return Expanded(
            child: Row(
              children: [
                _Dot(index: i + 1, active: active, done: done),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                      color: active
                          ? _kPrimary
                          : done
                          ? _kAccent
                          : _kBorder,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (i < labels.length - 1)
                  Expanded(
                    child: Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      color: done ? _kAccent : _kBorder,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final int index;
  final bool active;
  final bool done;
  const _Dot({required this.index, required this.active, required this.done});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active
            ? _kPrimary
            : done
            ? _kAccent
            : Colors.transparent,
        border: Border.all(
          color: active || done ? Colors.transparent : _kBorder,
          width: 1.5,
        ),
      ),
      child: Center(
        child: done
            ? const Icon(Icons.check, size: 13, color: Colors.white)
            : Text(
                '$index',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : _kBorder,
                ),
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: _kLabel,
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool required;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffix;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? hint;
  final int? maxLines;

  const _FormField({
    required this.label,
    required this.controller,
    this.required = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.suffix,
    this.readOnly = false,
    this.onTap,
    this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _kLabel,
              ),
              children: required
                  ? const [
                      TextSpan(
                        text: '*',
                        style: TextStyle(color: Colors.red),
                      ),
                    ]
                  : [],
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            readOnly: readOnly,
            onTap: onTap,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 14, color: _kLabel),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: _kBorder, fontSize: 13),
              suffixIcon: suffix,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: _kBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: _kBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: _kPrimary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Colors.red),
              ),
              filled: true,
              fillColor: _kCard,
            ),
            validator: required
                ? (v) => (v == null || v.trim().isEmpty)
                      ? AppLocalizations.of(context)!.requiredField
                      : null
                : null,
          ),
        ],
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final bool required;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _kLabel,
              ),
              children: required
                  ? const [
                      TextSpan(
                        text: '*',
                        style: TextStyle(color: Colors.red),
                      ),
                    ]
                  : [],
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: value,
            hint: Text(
              AppLocalizations.of(context)!.selectHint,
              style: const TextStyle(color: _kBorder, fontSize: 13),
            ),
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: _kSubLabel,
            ),
            style: const TextStyle(fontSize: 14, color: _kLabel),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: _kBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: _kBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: _kPrimary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Colors.red),
              ),
              filled: true,
              fillColor: _kCard,
            ),
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
            validator: required
                ? (v) => (v == null || v.isEmpty)
                      ? AppLocalizations.of(context)!.requiredField
                      : null
                : null,
          ),
        ],
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const _ContinueButton({required this.onPressed, this.label = 'Continue'});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _kPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  STEP 1 – Basic Details
// ─────────────────────────────────────────────────────────────────────────────
class _BasicDetailsStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;
  final TextEditingController dobCtrl;
  final TextEditingController mobileCtrl;
  final TextEditingController emailCtrl;
  final VoidCallback onPickDate;
  final VoidCallback onContinue;

  const _BasicDetailsStep({
    required this.formKey,
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.dobCtrl,
    required this.mobileCtrl,
    required this.emailCtrl,
    required this.onPickDate,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(l10n.basicDetails),
            _FormField(
              label: l10n.firstName,
              controller: firstNameCtrl,
              required: true,
            ),
            _FormField(
              label: l10n.lastName,
              controller: lastNameCtrl,
              required: true,
            ),
            _FormField(
              label: l10n.dateOfBirth,
              controller: dobCtrl,
              required: true,
              readOnly: true,
              hint: 'dd/mm/yyyy',
              onTap: onPickDate,
              suffix: const Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: _kSubLabel,
              ),
            ),
            _FormField(
              label: l10n.mobileNumber,
              controller: mobileCtrl,
              required: true,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            _FormField(
              label: l10n.emailAddress,
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            Center(
              child: _ContinueButton(
                label: l10n.continueBtn,
                onPressed: onContinue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  STEP 2 – Location Details
// ─────────────────────────────────────────────────────────────────────────────
class _LocationStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final String state;
  final TextEditingController districtCtrl;
  final TextEditingController talukaCtrl;
  final TextEditingController villageCtrl;
  final TextEditingController addressCtrl;
  final bool isLocating;
  final VoidCallback onDetectLocation;
  final VoidCallback onContinue;

  const _LocationStep({
    required this.formKey,
    required this.state,
    required this.districtCtrl,
    required this.talukaCtrl,
    required this.villageCtrl,
    required this.addressCtrl,
    required this.isLocating,
    required this.onDetectLocation,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SectionTitle(l10n.locationDetails),
                isLocating
                    ? const Padding(
                        padding: EdgeInsets.only(right: 16.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : TextButton.icon(
                        onPressed: onDetectLocation,
                        icon: const Icon(Icons.my_location, size: 16),
                        label: const Text("Auto Detect", style: TextStyle(fontSize: 13)),
                      ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.stateLbl,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _kLabel,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _kBorder),
                    ),
                    child: Text(
                      state,
                      style: const TextStyle(fontSize: 14, color: _kSubLabel),
                    ),
                  ),
                ],
              ),
            ),
            _FormField(
              label: l10n.district,
              controller: districtCtrl,
              required: true,
            ),
            _FormField(
              label: l10n.talukaOrTq,
              controller: talukaCtrl,
              required: true,
            ),
            _FormField(
              label: l10n.village,
              controller: villageCtrl,
              required: true,
            ),
            _FormField(
              label: l10n.address,
              controller: addressCtrl,
              required: true,
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            Center(
              child: _ContinueButton(
                label: l10n.continueBtn,
                onPressed: onContinue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  STEP 3 – Education & Experience
// ─────────────────────────────────────────────────────────────────────────────
class _EducationStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final List<String> qualifications;
  final List<String> experienceLevels;
  final List<String> jobTypes;

  final String? selectedQualification;
  final String? selectedExperience;
  final String? selectedJobType;

  final bool fieldLocations;
  final bool communities;
  final bool travelDistrict;

  final String? resumeName;
  final String? resumeSize; // NEW
  final String? resumeUrl;
  final File? photoFile;
  final String? photoSize; // NEW
  final String? photoUrl;

  final ValueChanged<String?> onQualificationChanged;
  final ValueChanged<String?> onExperienceChanged;
  final ValueChanged<String?> onJobTypeChanged;
  final ValueChanged<bool?> onFieldLocationsChanged;
  final ValueChanged<bool?> onCommunitiesChanged;
  final ValueChanged<bool?> onTravelChanged;

  final VoidCallback onPickResume;
  final VoidCallback onOpenCamera;
  final VoidCallback onSubmit;

  const _EducationStep({
    required this.formKey,
    required this.qualifications,
    required this.experienceLevels,
    required this.jobTypes,
    required this.selectedQualification,
    required this.selectedExperience,
    required this.selectedJobType,
    required this.fieldLocations,
    required this.communities,
    required this.travelDistrict,
    required this.resumeName,
    this.resumeSize,
    this.resumeUrl,
    required this.photoFile,
    this.photoSize,
    this.photoUrl,
    required this.onQualificationChanged,
    required this.onExperienceChanged,
    required this.onJobTypeChanged,
    required this.onFieldLocationsChanged,
    required this.onCommunitiesChanged,
    required this.onTravelChanged,
    required this.onPickResume,
    required this.onOpenCamera,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(l10n.educationExperience),

            _DropdownField(
              label: l10n.highestQualification,
              value: selectedQualification,
              items: qualifications,
              onChanged: onQualificationChanged,
              required: true,
            ),
            _DropdownField(
              label: l10n.experienceLevel,
              value: selectedExperience,
              items: experienceLevels,
              onChanged: onExperienceChanged,
              required: true,
            ),
            _DropdownField(
              label: l10n.jobType,
              value: selectedJobType,
              items: jobTypes,
              onChanged: onJobTypeChanged,
              required: true,
            ),

            // ── Availability checkboxes ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.availabilityWillingness,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _kLabel,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _CheckRow(
                    label: l10n.willingFieldLocations,
                    value: fieldLocations,
                    onChanged: onFieldLocationsChanged,
                  ),
                  _CheckRow(
                    label: l10n.comfortableWithCommunities,
                    value: communities,
                    onChanged: onCommunitiesChanged,
                  ),
                  _CheckRow(
                    label: l10n.willingTravelDistrict,
                    value: travelDistrict,
                    onChanged: onTravelChanged,
                  ),
                ],
              ),
            ),

            // ── Resume upload ───────────────────────────────────────────────
            Text(
              l10n.uploadResume,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _kLabel,
              ),
            ),
            const SizedBox(height: 8),
            _UploadRow(
              buttonLabel: l10n.uploadResume,
              statusText: resumeName != null
                  ? '$resumeName${resumeSize != null ? ' ($resumeSize)' : ''}'
                  : (resumeUrl != null
                        ? '✅ Saved Resume Selected'
                        : l10n.noFileChosen),
              onTap: onPickResume,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 14),
              child: Text(
                l10n.pdfOnlyMax5Mb,
                style: const TextStyle(fontSize: 11, color: _kSubLabel),
              ),
            ),

            // ── Photo upload ────────────────────────────────────────────────
            Text(
              l10n.uploadPhoto,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _kLabel,
              ),
            ),
            const SizedBox(height: 8),
            _UploadRow(
              buttonLabel: l10n.openCameraBtn,
              statusText: photoFile != null
                  ? '${l10n.photoCaptured} ✓${photoSize != null ? ' ($photoSize)' : ''}'
                  : (photoUrl != null
                        ? '✅ Saved Photo Selected'
                        : l10n.openCameraForLivePhoto),
              onTap: onOpenCamera,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 0),
              child: Text(
                l10n.livePhotoOnlyMax2Mb,
                style: const TextStyle(fontSize: 11, color: _kSubLabel),
              ),
            ),

            const SizedBox(height: 28),
            Center(
              child: _ContinueButton(
                label:
                    formKey.currentState?.context.widget.toString().contains(
                          "Apply",
                        ) ==
                        true
                    ? l10n.submitApplication
                    : l10n.submitApplication, // Will change in parent
                onPressed: onSubmit,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _CheckRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: 36,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: _kPrimary,
            side: const BorderSide(color: _kBorder, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: _kLabel),
          ),
        ),
      ],
    );
  }
}

class _UploadRow extends StatelessWidget {
  final String buttonLabel;
  final String statusText;
  final VoidCallback onTap;

  const _UploadRow({
    required this.buttonLabel,
    required this.statusText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _kBorder),
        color: _kCard,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _kPrimary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5),
                  bottomLeft: Radius.circular(5),
                ),
              ),
              child: Text(
                buttonLabel,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                statusText,
                style: TextStyle(
                  fontSize: 12,
                  color: statusText.contains('✓') ? _kAccent : _kSubLabel,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
