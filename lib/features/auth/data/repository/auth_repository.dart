import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../models/login_request.dart';

class AuthRepository {
  final ApiClient _client = ApiClient();

  Future<Map<String, dynamic>> login(LoginRequest request) async {
    final body = request.toJson();

    print("========= LOGIN REQUEST =========");
    print(body);

    try {
      // ApiClient base URL already includes /api, so we just use /auth/login
      // Wait, ApiClient baseUrl is .../api
      // Original AuthRepository used .../api as base and called /auth/login
      // So path should be /auth/login
      
      final response = await _client.dio.post(
        "/auth/login",
        data: body,
      );

      print("========= LOGIN SUCCESS =========");
      print("Status Code: ${response.statusCode}");
      print("Response Data: ${response.data}");

      return response.data;

    } on DioException catch (e) {
      // ApiClient interceptor already prints errors
      print("========= LOGIN ERROR (AuthRepository) =========");
      print("Error Message: ${e.message}");

      final data = e.response?.data;
      String message = "Login failed";
      if (data is Map && data["message"] != null) {
        message = data["message"].toString();
      }

      throw Exception(message);
    }
  }
}
