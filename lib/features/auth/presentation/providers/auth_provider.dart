import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/utils/storage_service.dart';
import '../../data/models/login_request.dart';
import '../../data/repository/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();
  final StorageService _storage = StorageService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login(LoginRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _repository.login(request);

      if (data["token"] != null) {
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
      _errorMessage = "Unexpected error occurred.";
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}
