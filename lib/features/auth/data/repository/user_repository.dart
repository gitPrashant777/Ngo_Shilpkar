import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/beneficiary_model.dart';

class UserRepository {
  final ApiClient _client = ApiClient();

  // ============================
  // CREATE ADMIN
  // ============================

  Future<Map<String, dynamic>> createAdmin({
    required String firstName,
    required String lastName,
    required String dob,
    required String mobile,
    required String email,
  }) async {

    final payload = {
      "mobile": mobile,
      "email": email,
      "role": "ADMIN",
      "admin": {
        "firstName": firstName,
        "lastName": lastName,
        "dob": dob,
      }
    };

    try {
      final response = await _client.dio.post(
        ApiEndpoints.createUser,
        data: payload,
        options: Options(
          validateStatus: (status) => true, // 🔥 IMPORTANT
        ),
      );

      final data = response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data["message"] ?? "Something went wrong");
      }

    } on DioException catch (e) {
      print("=========== CREATE ADMIN ERROR ===========");
      print("Status: ${e.response?.statusCode}");
      print("Response: ${e.response?.data}");
      print("==========================================");

      // Extract backend message safely
      final backendMessage =
          e.response?.data?["message"] ?? "Something went wrong";

      throw Exception(backendMessage);
    }

  }

  // ============================
  // FORGOT PASSWORD
  // ============================

  // lib/features/auth/data/repository/user_repository.dart

  Future<void> forgotPassword(String email) async {
    try {
      final response = await _client.dio.post(
        "/auth/superadmin-forgot-password", // Correct endpoint from API Contract
        data: {"email": email}, // Payload required
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }
    } on DioException catch (e) {
      // Check if the server returned HTML (404) to avoid the "Type String is not a subtype of int" error
      if (e.response?.data is String && e.response?.data.contains("<html>")) {
        throw Exception("Server endpoint not found. Please verify the URL path.");
      }

      final errorMessage = (e.response?.data is Map)
          ? e.response?.data["message"]
          : "Failed to send OTP. Please try again.";
      throw Exception(errorMessage);
    }
  }
  // ============================
  // CREATE EMPLOYEE
  // ============================

  Future<Map<String, dynamic>> createEmployee(
      Map<String, dynamic> formData) async {

    final payload = {
      "mobile": formData["mobile"],
      "email": formData["email"],
      "role": formData["role"],
      "employee": {
        "firstName": formData["firstName"],
        "lastName": formData["lastName"],
        "employeeType": formData["role"],
        "state": formData["state"] ?? "Maharashtra",
        "district": formData["district"],
        "taluka": formData["taluka"],
        "village": formData["village"],
      }
    };
    print("=========== CREATE EMPLOYEE REQUEST ===========");
    print("URL: ${ApiEndpoints.createUser}");
    print("Headers: ${_client.dio.options.headers}");
    print("Payload: $payload");

    try {
      final response = await _client.dio.post(
        ApiEndpoints.createUser,
        data: payload,
      );

      print("=========== CREATE EMPLOYEE SUCCESS ===========");
      print("Status: ${response.statusCode}");
      print("Response: ${response.data}");
      print("===============================================");

      return response.data;

    } on DioException catch (e) {
      print("=========== CREATE EMPLOYEE ERROR ===========");
      print("Status: ${e.response?.statusCode}");
      print("Response: ${e.response?.data}");
      print("Message: ${e.message}");
      print("=============================================");

      rethrow;
    }
  }


  // ============================
  // GET BENEFICIARIES
  // ============================
  Future<List<BeneficiaryModel>> getBeneficiaries() async {
    try {
      final response = await _client.dio.get(
        "/super-admin/users",
        queryParameters: {"role": "BENEFICIARY"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => BeneficiaryModel.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load beneficiaries");
      }
    } on DioException catch (e) {
       print("Error fetching beneficiaries: ${e.message}");
       // Return empty list or throw based on preference. 
       // For now, rethrowing to handle in UI.
       throw Exception(e.response?.data["message"] ?? "Failed to fetch beneficiaries");
    }
  }
}
