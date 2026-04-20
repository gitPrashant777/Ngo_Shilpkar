import 'package:flutter/material.dart';
import '../../../../core/utils/storage_service.dart';
import 'package:shilpkar/core/utils/token_holder.dart';

import '../../data/models/customer_model.dart';
import '../../data/repositories/ecommerce_repository.dart';
import '../../../../main.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../../features/jobs/presentation/screens/local_job_data.dart';
import 'package:google_sign_in/google_sign_in.dart';


class CustomerAuthProvider extends ChangeNotifier {
  final EcommerceRepository _repository = EcommerceRepository();
  final StorageService _storageService = StorageService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  CustomerModel? _currentCustomer;
  bool _isLoading = false;
  String? _error;

  CustomerModel? get currentCustomer => _currentCustomer;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isAuthenticated => _currentCustomer != null;

  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _error = 'Google sign-in cancelled';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      final auth = await googleUser.authentication;
      final idToken = auth.idToken;
      if (idToken == null || idToken.isEmpty) {
        _error = 'Google token not available';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final response = await _repository.customerGoogleLogin(idToken);
      if (response['success'] == true) {
        final token = response['token'] as String?;
        if (token != null) {
          tokenHolder.customerToken = token;
          await _storageService.saveCustomerToken(token);
        }

        final customerData = response['customer'] as Map<String, dynamic>?;
        if (customerData != null) {
          _currentCustomer = CustomerModel.fromJson(customerData);
        }

        if (token != null) {
          try {
            final profileResponse =
                await _repository.getCustomerProfileWithToken(token);
            if (profileResponse['success'] == true &&
                profileResponse['data'] != null) {
              _currentCustomer = CustomerModel.fromJson(
                  profileResponse['data'] as Map<String, dynamic>);
            }
          } catch (profileError) {
            debugPrint('Profile refresh after Google login failed: $profileError');
          }
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Google login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.customerLogin(email, password);
      
      if (response['success'] == true) {
        final token = response['token'] as String?;

        // ── Step 1: Save token to persistent storage + in-memory holder
        if (token != null) {
          tokenHolder.customerToken = token; // ← in-memory, instant (ApiClient reads this)
          await _storageService.saveCustomerToken(token); // ← persisted for cold start
        }

        // ── Step 2: Build customer from the login response (partial: id, email, mobile)
        final customerData = response['customer'] as Map<String, dynamic>?;
        if (customerData != null) {
          _currentCustomer = CustomerModel.fromJson(customerData);
        }

        // ── Step 3: Fetch full profile using the token IN MEMORY (not re-read from
        //    storage) to avoid the FlutterSecureStorage write→read race on Android.
        if (token != null) {
          try {
            final profileResponse =
                await _repository.getCustomerProfileWithToken(token);
            if (profileResponse['success'] == true &&
                profileResponse['data'] != null) {
              _currentCustomer = CustomerModel.fromJson(
                  profileResponse['data'] as Map<String, dynamic>);
            }
          } catch (profileError) {
            // Non-fatal — session still works with the partial data from step 2
            debugPrint('Profile refresh after login failed: $profileError');
          }
        }

        // FCM registration removed: backend /notification/register-fcm
        // expects an Admin/Employee User. Sending a Customer token results
        // in a 401, which clears the customer token and breaks the session.

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(
      String name, String email, String password, String mobile) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response =
          await _repository.customerRegister(name, email, password, mobile);

      if (response['success'] == true) {
        // Registration successful — auto-login to obtain token and full session
        return await login(email, password);
      } else {
        _error = response['message'] ?? 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    // FCM removal removed for same reason as registration.

    try {
      await _googleSignIn.signOut();
    } catch (_) {}

    await _storageService.clearCustomerToken();
    tokenHolder.clearCustomer(); // clear in-memory token immediately
    _currentCustomer = null;
    await LocalJobDataStorage.clearJobData(); // Clear local profile application data
    notifyListeners();
  }

  /// Called on app start to restore a persisted customer session.
  /// By app-start time the storage write from the previous session has long
  /// been flushed, so there is no race condition here.
  Future<void> checkAuthStatus() async {
    final token = await _storageService.getCustomerToken();
    if (token != null && token.isNotEmpty) {
      tokenHolder.customerToken = token; // restore in-memory token so ApiClient can use it
      try {
        final response = await _repository.getCustomerProfileWithToken(token);
        if (response['success'] == true) {
          final customerData = response['data'];
          if (customerData != null) {
            _currentCustomer = CustomerModel.fromJson(
                customerData as Map<String, dynamic>);
            notifyListeners();
          }
        }
      } catch (e) {
        // Token is invalid or expired — clear session
        await logout();
      }
    }
  }
}
