import 'package:dio/dio.dart';
import '../models/login_request.dart';

class AuthRepository {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://ngo-project-r7cc.onrender.com/api",
      headers: {
        "Content-Type": "application/json",
      },
    ),
  );

  Future<Map<String, dynamic>> login(LoginRequest request) async {
    final body = request.toJson();

    print("========= LOGIN REQUEST =========");
    print(body);

    try {
      final response = await _dio.post(
        "/auth/login",
        data: body,
      );

      print("========= LOGIN SUCCESS =========");
      print("Status Code: ${response.statusCode}");
      print("Response Data: ${response.data}");

      return response.data;

    } on DioException catch (e) {
      print("========= LOGIN ERROR =========");
      print("Status Code: ${e.response?.statusCode}");
      print("Response Data: ${e.response?.data}");
      print("Error Message: ${e.message}");

      throw Exception(e.response?.data["message"] ?? "Login failed");
    }
  }
}
