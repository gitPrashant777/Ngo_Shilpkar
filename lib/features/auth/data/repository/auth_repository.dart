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

    final response = await _dio.post(
      "/auth/login",
      data: body,
    );

    print("========= LOGIN RESPONSE =========");
    print(response.data);

    return response.data;
  }
}
