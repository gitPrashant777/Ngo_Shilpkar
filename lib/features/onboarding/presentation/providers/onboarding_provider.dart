import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../data/models/onboarding_model.dart';
import '../../data/repository/onboarding_repository.dart';

// Only import onboarding_model.dart as it already contains OnboardingStatusModel
// along with OnboardingStats, OnboardingPaymentIntent, etc.
class OnboardingProvider with ChangeNotifier {
  final OnboardingRepository _repository = OnboardingRepository();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  OnboardingStatusModel? _status;
  bool _isLoading = false;
  String? _error;

  OnboardingStatusModel? get status => _status;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Expose repository for direct file upload needs if required in the UI
  OnboardingRepository get repository => _repository;

  // Beneficiary: Check Status
  Future<void> checkStatus() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _status = await _repository.getStatus();
      // Global Guard Check will be handled by UI using this _status
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Beneficiary: Initiate Payment
  Future<Map<String, dynamic>?> initiatePayment() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _repository.initiatePayment();
      return data;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Beneficiary: Apply for Waiver
  Future<bool> applyWaiver(String reason, String filePath) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String documentUrl = "";
      if (filePath.isNotEmpty) {
        // Assume repository handles passing the 'module': 'onboarding' required by API
        documentUrl = await _repository.uploadDocument(filePath);
      }

      await _repository.applyWaiver(reason, documentUrl);
      // Refresh status to get WAIVER_PENDING
      await checkStatus();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------- ADMIN METHODS ----------------

  OnboardingStats? _stats;
  OnboardingConfigModel? _latestContribution;
  
  // Waiver Requests Pagination State
  final List<WaiverRequestModel> _waiverRequests = [];
  int _waiverListPage = 1;
  bool _hasMoreWaivers = true;
  String? _currentWaiverStatusFilter = 'PENDING';

  OnboardingStats? get stats => _stats;
  OnboardingConfigModel? get latestContribution => _latestContribution;
  List<WaiverRequestModel> get waiverRequests => _waiverRequests;
  bool get hasMoreWaivers => _hasMoreWaivers;
  String? get currentWaiverStatusFilter => _currentWaiverStatusFilter;

  Future<void> fetchAdminData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getLatestContribution().catchError((e) {
          debugPrint("⚠️ OnboardingProvider: Failed to fetch latest contribution: $e");
          return null;
        }),
      ]);

      _latestContribution = results[0] as OnboardingConfigModel?;
    } catch (e) {
      _error = e.toString();
      debugPrint("❌ OnboardingProvider: Critical error in fetchAdminData: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> setContribution(double amount) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint("🚀 OnboardingProvider: Setting contribution to ₹$amount");
      final newConfig = await _repository.createConfig(amount);
      _latestContribution = newConfig; // Direct update on success
      
      // Notify UI immediately that the contribution is updated
      notifyListeners();
      
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint("❌ OnboardingProvider: Failed to set contribution: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchWaiverRequests({bool refresh = false, String? status}) async {
    if (status != null) {
      _currentWaiverStatusFilter = status;
    }

    if (refresh) {
      _waiverListPage = 1;
      _waiverRequests.clear();
      _hasMoreWaivers = true;
    } else if (!_hasMoreWaivers || _isLoading) {
      return; 
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final paginatedData = await _repository.getWaiverRequests(
        page: _waiverListPage,
        limit: 20,
        status: _currentWaiverStatusFilter,
      );

      _waiverRequests.addAll(paginatedData.data);
      if (paginatedData.data.length < 20 || _waiverListPage >= paginatedData.totalPages) {
        _hasMoreWaivers = false;
      } else {
        _waiverListPage++;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> reviewWaiver(String beneficiaryId, bool approve) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Passes "APPROVE" or "REJECT" per API specs
      await _repository.reviewWaiver(beneficiaryId, approve ? "APPROVE" : "REJECT");
      
      // Remove from the local pending list immediately for better UX
      _waiverRequests.removeWhere((w) => w.requesterId == beneficiaryId || w.id == beneficiaryId);
      
      await fetchAdminData(); // Refresh counts
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

