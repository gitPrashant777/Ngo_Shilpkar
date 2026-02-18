import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../../../../core/utils/storage_service.dart';
import '../../data/models/login_request.dart';
import '../../data/repository/auth_repository.dart';
import '../../data/repository/user_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();
  final StorageService _storage = StorageService();

  bool _isLoading = false;
  String? _errorMessage;
  String? _role;   // 👈 ADD THIS

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get role => _role;   // 👈 ADD GETTER

  Future<bool> login(LoginRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _repository.login(request);

      if (data["token"] != null) {

        _role = data["role"];   // 👈 STORE ROLE

        await _storage.saveAuthData(
          token: data["token"],
          role: data["role"],
          identifier: data["username"],
        );

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = "Invalid credentials";
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        _errorMessage =
            e.response?.data["message"] ?? "Server error occurred";
      } else {
        _errorMessage =
        "Connection error. Please check your internet.";
      }
    } catch (_) {
      _errorMessage = "Invalid Credentials.";
    }

    _isLoading = false;
    notifyListeners();
    return false;
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
}
