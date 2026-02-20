import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../../../../core/utils/storage_service.dart';
import '../../data/models/login_request.dart';
import '../../data/repository/auth_repository.dart';
import '../../data/repository/user_repository.dart';
import '../../data/models/user_profile_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();
  final StorageService _storage = StorageService();

  AuthProvider() {
    _checkAuth();
  }

  bool _isLoading = false;
  String? _errorMessage;
  String? _role;
  String? _userId;

  Future<void> _checkAuth() async {
    final token = await _storage.getToken();
    final role = await _storage.getRole();
    final userId = await _storage.getUserId();
    if (token != null && role != null) {
      _role = role;
      _userId = userId;
      notifyListeners();
      // Optional: Fetch profile immediately if needed
      // fetchUserProfile(); 
    }
  }


  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get role => _role;
  String? get userId => _userId;
  bool get isAuthenticated => _role != null && _role!.isNotEmpty;

  // Logout
  Future<void> logout() async {
    debugPrint("AuthProvider: Logging out...");
    _role = null;
    _userProfile = null;
    _userId = null;
    try {
      await _storage.clearAll(); 
    } catch (e) {
      debugPrint("AuthProvider: Error clearing storage: $e");
    }
    notifyListeners();
    debugPrint("AuthProvider: Logout complete, listeners notified.");
  }

  Future<bool> login(LoginRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _repository.login(request);

      if (data["token"] != null) {

        _role = data["role"]?.toString();

        if (data["user"] != null) {
          await _storage.saveAuthData(
            token: data["token"],
            role: _role ?? "",
            identifier: data["username"] ?? "",
            userId: data["user"]["_id"] ?? data["user"]["id"] ?? "",
          );
          _userId = data["user"]["_id"] ?? data["user"]["id"];
        } else {
           await _storage.saveAuthData(
            token: data["token"],
            role: _role ?? "",
            identifier: data["username"] ?? "",
            userId: data["userId"] ?? "",
          );
          _userId = data["userId"];
        }

        return true;
      } else {
        _errorMessage = "Invalid credentials";
        return false;
      }

    } on DioException catch (e) {

      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;

      debugPrint("🔴 DIO LOGIN ERROR");
      debugPrint("Status Code: $statusCode");
      debugPrint("Response: $responseData");

      if (responseData != null && responseData["message"] != null) {
        _errorMessage = responseData["message"].toString();
      } else {
        _errorMessage =
        "HTTP ${statusCode ?? ""} - ${e.message}";
      }

      return false;

    } catch (e, stackTrace) {

      // 👇 THIS IS WHAT YOU WANTED
      debugPrint("🔴 UNEXPECTED ERROR");
      debugPrint("Error: $e");
      debugPrint("StackTrace: $stackTrace");

      _errorMessage = e.toString(); // exact error message

      return false;

    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }



  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Lazy fix: Instantiate UserRepository directly since we added the method there
      // Ideally should be in AuthRepository or injected.
      final UserRepository userRepo = UserRepository(); 
      await userRepo.forgotPassword(email);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Profile ───────────────────────────────────────────────────────────────
  UserProfileModel? _userProfile;
  UserProfileModel? get userProfile => _userProfile;

  Future<void> fetchUserProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      final UserRepository userRepo = UserRepository();
      final data = await userRepo.getUserProfile();
      _userProfile = UserProfileModel.fromJson(data);
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      final UserRepository userRepo = UserRepository();
      final response = await userRepo.updateProfile(data);
      // Update local profile data
      if (response['data'] != null) {
         // Re-fetch or update local model from response
         // Assuming response['data'] is the full profile object or we re-fetch
         await fetchUserProfile(); 
      }
      return true;
    } catch (e) {
      debugPrint("Error updating profile: $e");
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateAvatar(String filePath) async {
    _isLoading = true;
    notifyListeners();
    try {
      final UserRepository userRepo = UserRepository();
      await userRepo.updateAvatar(filePath);
      await fetchUserProfile(); // Refresh profile to get new avatar URL
      return true;
    } catch (e) {
      debugPrint("Error updating avatar: $e");
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
