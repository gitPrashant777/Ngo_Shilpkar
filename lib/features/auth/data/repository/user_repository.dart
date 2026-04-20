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
        if (formData["address"] != null) "address": formData["address"],
        if (formData["latitude"] != null) "latitude": formData["latitude"],
        if (formData["longitude"] != null) "longitude": formData["longitude"],
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
  // CREATE BENEFICIARY
  // ============================

  Future<Map<String, dynamic>> createBeneficiary(
      Map<String, dynamic> formData) async {

    final payload = {
      "mobile": formData["mobile"],
      "email": formData["email"],
      "role": "BENEFICIARY",
      "beneficiary": {
        "firstName": formData["firstName"],
        "lastName": formData["lastName"],
        "state": formData["state"] ?? "Maharashtra",
        "district": formData["district"],
        "taluka": formData["taluka"],
        "village": formData["village"],
        "category": formData["category"],
        if (formData["address"] != null) "address": formData["address"],
        if (formData["latitude"] != null) "latitude": formData["latitude"],
        if (formData["longitude"] != null) "longitude": formData["longitude"],
        // Beneficiary specific:
        "bankDetails": {
             "accountNumber": formData["accountNumber"],
             "accountHolderName": formData["accountHolderName"],
             "ifsc": formData["ifsc"],
             "accountType": formData["accountType"],
        }
      }
    };
    print("=========== CREATE BENEFICIARY REQUEST ===========");
    print("Payload: $payload");

    try {
      final response = await _client.dio.post(
        ApiEndpoints.createUser,
        data: payload,
      );

      return response.data;

    } on DioException catch (e) {
      print("=========== CREATE BENEFICIARY ERROR ===========");
      print("Status: ${e.response?.statusCode}");
      print("Response: ${e.response?.data}");
      rethrow;
    }
  }

  // ============================
  // GET USER PROFILE
  // ============================
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _client.dio.get(
        "/profile/me", // Using relative path as per ApiEndpoints or direct string
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception("Failed to load profile");
      }
    } on DioException catch (e) {
       print("Error fetching profile: ${e.message}");
       throw Exception(e.response?.data["message"] ?? "Failed to fetch profile");
    }
  }

  // ============================
  // UPDATE PROFILE
  // ============================
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _client.dio.patch(
        "/profile/me",
        data: data,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception("Failed to update profile");
      }
    } on DioException catch (e) {
       print("Error updating profile: ${e.message}");
       throw Exception(e.response?.data["message"] ?? "Failed to update profile");
    }
  }

  // ============================
  // UPDATE AVATAR
  // ============================
  Future<Map<String, dynamic>> updateAvatar(String filePath) async {
    try {
      String fileName = filePath.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await _client.dio.patch(
        "/profile/me/avatar",
        data: formData,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception("Failed to update avatar");
      }
    } on DioException catch (e) {
       print("Error updating avatar: ${e.message}");
       throw Exception(e.response?.data["message"] ?? "Failed to update avatar");
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

  // ============================
  // GET BENEFICIARY BY ID
  // ============================
  Future<BeneficiaryModel> getBeneficiaryById(String id) async {
    try {
      final response = await _client.dio.get("/super-admin/users/$id");
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return BeneficiaryModel.fromJson(data);
      } else {
        throw Exception("Failed to load beneficiary details");
      }
    } on DioException catch (e) {
       print("Error fetching beneficiary: ${e.message}");
       throw Exception(e.response?.data["message"] ?? "Failed to fetch beneficiary");
    }
  }

  // ============================
  // COMMUNITY DIRECTORY
  // ============================
  Future<Map<String, dynamic>> getCommunityUsers({
      int page = 1,
      int limit = 20,
      String? role,
      String? search,
      String? state,
      String? district,
      String? taluka,
      String? category,
      bool? verified,
    }) async {
    try {
      final response = await _client.dio.get(
        ApiEndpoints.usersCommunity,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (role != null && role.isNotEmpty) 'role': role,
          if (search != null && search.isNotEmpty) 'search': search,
          if (state != null && state.isNotEmpty) 'state': state,
            if (district != null && district.isNotEmpty) 'district': district,
            if (taluka != null && taluka.isNotEmpty) 'taluka': taluka,
            if (category != null && category.isNotEmpty) 'category': category,
            if (verified != null) 'verified': verified,
          },
        );

      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to fetch community members',
      );
    }
  }

  Future<Map<String, dynamic>> getBeneficiariesPage({
    int page = 1,
    int limit = 20,
    String? search,
    String? category,
  }) async {
    try {
      final response = await _client.dio.get(
        ApiEndpoints.usersBeneficiaries,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search != null && search.isNotEmpty) 'search': search,
          if (category != null && category.isNotEmpty) 'category': category,
        },
      );

      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to fetch beneficiaries',
      );
    }
  }

  Future<Map<String, dynamic>> getCommunityProfile(String userId) async {
    try {
      final response = await _client.dio.get(
        ApiEndpoints.userCommunityProfile(userId),
      );

      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to fetch profile',
      );
    }
  }

  Future<Map<String, dynamic>> startCommunityChat(
    String userId, {
    String? topic,
    String? requesterId,
  }) async {
    try {
      final payload = <String, dynamic>{
        'responder': userId,
        if (topic != null && topic.isNotEmpty) 'topic': topic,
        if (requesterId != null && requesterId.isNotEmpty)
          'requester': requesterId,
      };

      final response = await _client.dio.post(
        ApiEndpoints.userStartChat(userId),
        data: payload,
        queryParameters: payload,
      );

      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to start chat',
      );
    }
  }

  // ============================
  // DELETION WORKFLOW
  // ============================
  Future<Map<String, dynamic>> getDeletionRequests() async {
    try {
      final response = await _client.dio.get(
        ApiEndpoints.userDeletionRequests,
      );
      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to fetch deletion requests',
      );
    }
  }

  Future<Map<String, dynamic>> getDeactivatedHistory() async {
    try {
      final response = await _client.dio.get(
        ApiEndpoints.userDeactivatedHistory,
      );
      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to fetch deactivated users',
      );
    }
  }

  Future<Map<String, dynamic>> approveDeletion(String userId) async {
    try {
      final response = await _client.dio.patch(
        ApiEndpoints.userApproveDeletion(userId),
      );
      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
    } on DioException catch (e) {
      if (e.response?.data is Map<String, dynamic>) {
        return e.response?.data as Map<String, dynamic>;
      }
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to approve deletion',
      );
    }
  }

  Future<Map<String, dynamic>> verifyUser(String userId) async {
    try {
      final response = await _client.dio.patch(
        ApiEndpoints.userVerify(userId),
      );
      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to verify account',
      );
    }
  }

  // ============================
  // USER CATEGORIES
  // ============================
  Future<List<Map<String, dynamic>>> getUserCategories() async {
    try {
      final response = await _client.dio.get(
        ApiEndpoints.userCategories,
      );
      final raw = response.data;
      if (raw is Map<String, dynamic> && raw['data'] is List) {
        return (raw['data'] as List)
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      if (raw is List) {
        return raw
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      return <Map<String, dynamic>>[];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to fetch categories',
      );
    }
  }

  Future<Map<String, dynamic>> createUserCategory({
    required String name,
    String? description,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.userCategories,
        data: {
          'name': name,
          if (description != null && description.isNotEmpty)
            'description': description,
        },
      );
      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to create category',
      );
    }
  }

  // ============================
  // OFFLINE BENEFICIARIES & CASH
  // ============================
  Future<Map<String, dynamic>> createOfflineBeneficiary({
    required String name,
    String? mobile,
    String? email,
    required String category,
    required String dob,
    String? gender,
    String? aadharNumber,
    String? aadharPhotoUrl,
    String? panNumber,
    String? panPhotoUrl,
    required String state,
    required String district,
    required String village,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.beneficiariesOffline,
        data: {
          'name': name,
          'category': category,
          'dob': dob,
          if (mobile != null && mobile.trim().isNotEmpty) 'mobile': mobile,
          if (email != null && email.trim().isNotEmpty) 'email': email,
          if (gender != null && gender.trim().isNotEmpty) 'gender': gender,
          if (aadharNumber != null && aadharNumber.trim().isNotEmpty)
            'aadharNumber': aadharNumber,
          if (aadharPhotoUrl != null && aadharPhotoUrl.trim().isNotEmpty)
            'aadharPhotoUrl': aadharPhotoUrl,
          if (panNumber != null && panNumber.trim().isNotEmpty)
            'panNumber': panNumber,
          if (panPhotoUrl != null && panPhotoUrl.trim().isNotEmpty)
            'panPhotoUrl': panPhotoUrl,
          'location': {
            'state': state,
            'district': district,
            'village': village,
          },
        },
      );
      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to create offline beneficiary',
      );
    }
  }

  // ============================
  // ONLINE BENEFICIARY ONBOARDING
  // ============================
  Future<Map<String, dynamic>> initiateOnlineBeneficiary({
    required String name,
    required String mobile,
    required String email,
    required String dob,
    required String gender,
    required String category,
    required String password,
    required String state,
    required String district,
    String? taluka,
    String? aadharNumber,
    String? aadharPhotoUrl,
    String? panNumber,
    String? panPhotoUrl,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.beneficiariesOnlineInitiate,
        data: {
          'name': name,
          'mobile': mobile,
          'email': email,
          'dob': dob,
          'gender': gender,
          'category': category,
          'password': password,
          'location': {
            'state': state,
            'district': district,
            if (taluka != null && taluka.trim().isNotEmpty) 'taluka': taluka,
          },
          if (aadharNumber != null && aadharNumber.trim().isNotEmpty)
            'aadharNumber': aadharNumber,
          if (aadharPhotoUrl != null && aadharPhotoUrl.trim().isNotEmpty)
            'aadharPhotoUrl': aadharPhotoUrl,
          if (panNumber != null && panNumber.trim().isNotEmpty)
            'panNumber': panNumber,
          if (panPhotoUrl != null && panPhotoUrl.trim().isNotEmpty)
            'panPhotoUrl': panPhotoUrl,
        },
      );
      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to initiate online beneficiary',
      );
    }
  }

  Future<Map<String, dynamic>> verifyOnlineBeneficiary({
    required String mobile,
    required String otp,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.beneficiariesOnlineVerify,
        data: {
          'mobile': mobile,
          'otp': otp,
        },
      );
      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to verify beneficiary',
      );
    }
  }

  Future<Map<String, dynamic>> resendOnlineBeneficiaryOtp({
    required String mobile,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.beneficiariesOnlineResendOtp,
        data: {
          'mobile': mobile,
        },
      );
      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to resend OTP',
      );
    }
  }

  Future<Map<String, dynamic>> requestCashSettlement({
    required String beneficiaryId,
    required num amount,
    required String module,
    required String moduleRefId,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.beneficiariesCashRequest,
        data: {
          'beneficiaryId': beneficiaryId,
          'amount': amount,
          'module': module,
          'moduleRefId': moduleRefId,
        },
      );
      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to request cash settlement',
      );
    }
  }

  Future<Map<String, dynamic>> getCashRequests({String status = 'PENDING'}) async {
    try {
      final response = await _client.dio.get(
        ApiEndpoints.beneficiariesCashRequests,
        queryParameters: {'status': status},
      );
      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to fetch cash requests',
      );
    }
  }

  Future<Map<String, dynamic>> approveCashRequest(String id) async {
    try {
      final response = await _client.dio.patch(
        ApiEndpoints.beneficiariesCashApprove(id),
      );
      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to approve cash request',
      );
    }
  }
}
