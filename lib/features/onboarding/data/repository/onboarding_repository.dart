import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../models/onboarding_model.dart';

class OnboardingRepository {
  final ApiClient _client = ApiClient();

  Exception _handleError(DioException e, String fallback) {
    final data = e.response?.data;
    String? message;
    
    if (data is Map) {
      message = data['message'] ?? data['error'];
    }
    
    return Exception(message ?? fallback);
  }

  Map<String, dynamic> _safeMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is List && data.isNotEmpty) {
      final first = data.first;
      if (first is Map) return Map<String, dynamic>.from(first);
    }
    return {};
  }

  List _safeList(dynamic data) {
    if (data is List) return data;
    if (data is Map && data.containsKey('data')) {
      final node = data['data'];
      if (node is List) return node;
    }
    return [];
  }

  // ================= BENEFICIARY =================

  Future<OnboardingStatusModel> getStatus() async {
    try {
      final response = await _client.dio.get('/onboarding/status');
      return OnboardingStatusModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to get onboarding status');
    }
  }

  Future<Map<String, dynamic>> initiatePayment() async {
    try {
      // POST with empty body as per API contract.
      // Backend returns: { _id, amount (rupees), razorpayOrderId, module }
      final response = await _client.dio.post('/onboarding/initiate', data: {});
      return response.data['data'] ?? response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to initiate payment');
    }
  }

  Future<void> applyWaiver(String reason, String documentUrl) async {
    try {
      await _client.dio.post(
        '/onboarding/apply-waiver',
        data: {
          'reason': reason,
          'documentUrl': documentUrl,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to apply waiver');
    }
  }

  Future<String> uploadDocument(String filePath) async {
    try {
      final fileName = filePath.split('/').last;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
        'module': 'onboarding',
      });

      final response = await _client.dio.post(
        '/uploads',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      return response.data['data']['url'];
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to upload document');
    }
  }

  // ================= ADMIN =================

  Future<OnboardingConfigModel> createConfig(double amount) async {
    try {
      final response = await _client.dio.post(
        '/onboarding/config',
        data: {'amount': amount},
      );
      return OnboardingConfigModel.fromJson(_safeMap(response.data));
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to create contribution config');
    }
  }

  Future<OnboardingConfigModel?> getLatestContribution() async {
    try {
      final response = await _client.dio.get('/onboarding/config');
      final dynamic rawBody = response.data;
      
      if (rawBody == null) return null;

      // Handle both { success: true, data: { ... } } and direct Map { ... }
      Map<String, dynamic> jsonMap;
      if (rawBody is Map) {
        jsonMap = Map<String, dynamic>.from(rawBody);
      } else {
        return null; // Unexpected format
      }

      // Check for explicit { data: null }
      if (jsonMap.containsKey('data') && jsonMap['data'] == null) {
        return null;
      }

      final model = OnboardingConfigModel.fromJson(jsonMap);
      return model;
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch contribution config');
    }
  }

  Future<void> reviewWaiver(
      String beneficiaryId,
      String status,
      ) async {
    try {
      await _client.dio.post(
        '/onboarding/review-waiver/$beneficiaryId',
        data: {'status': status},
      );
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to review waiver');
    }
  }

  Future<OnboardingStats> getStats() async {
    try {
      final response = await _client.dio.get('/onboarding/stats');
      return OnboardingStats.fromJson(_safeMap(response.data));
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch onboarding stats');
    }
  }

  Future<PaginatedWaiversModel> getWaiverRequests({
    int page = 1,
    int limit = 20,
    String? status, // e.g. WAIVER_PENDING, WAIVER_APPROVED
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await _client.dio.get(
        '/onboarding/waiver-requests',
        queryParameters: queryParams,
      );
      
      return PaginatedWaiversModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to load waiver requests');
    }
  }
}
