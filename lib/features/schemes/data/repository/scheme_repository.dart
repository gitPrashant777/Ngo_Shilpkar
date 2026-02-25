// lib/features/schemes/data/repository/scheme_repository.dart

import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../models/scheme_model.dart';
import '../models/scheme_application_model.dart';

class SchemeRepository {
  final Dio _dio = ApiClient().dio;

  /// ============================================
  /// BENEFICIARY SECTION
  /// ============================================

  /// Get Published Schemes (Public)
  Future<List<SchemeModel>> getPublishedSchemes({int? page, int? limit}) async {
    try {
      final response = await _dio.get(
        "/schemes",
        queryParameters: {
          if (page != null) "page": page,
          if (limit != null) "limit": limit,
        },
      );
      final raw = response.data;

      // API may return { "data": [...] } or { "schemes": [...] } or a raw list
      List<dynamic> list;
      if (raw is List) {
        list = raw;
      } else if (raw is Map) {
        list = (raw['data'] ?? raw['schemes'] ?? raw['results'] ?? []) as List;
      } else {
        list = [];
      }

      return list.map((e) => SchemeModel.fromJson(e)).toList();
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Failed to fetch schemes';
      throw Exception(msg);
    } catch (e) {
      throw Exception('Failed to fetch schemes: $e');
    }
  }

  Future<String> applyForScheme(String schemeId) async {
    try {
      final response = await _dio.post("/schemes/$schemeId/apply");
      final data = response.data["data"] ?? response.data;
      return data["_id"] ?? "";
    } on DioException catch (e) {
      final message = e.response?.data?["message"] ?? "";

      if (message.contains("duplicate key")) {
        throw Exception("You have already applied for this scheme.");
      }

      throw Exception(message.isNotEmpty
          ? message
          : "Failed to apply for scheme");
    }
  }


  Future<List<SchemeApplicationModel>> getMyApplications() async {
    try {
      final response = await _dio.get("/schemes/applications/my");
      final data = response.data["data"] ?? response.data;
      if (data is List) {
        return data.map((e) => SchemeApplicationModel.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw Exception(e.response?.data?["message"] ?? "Failed to fetch applications");
    }
  }

  /// Get Admin Schemes (With Filters)
  Future<PaginatedSchemesModel> getAdminSchemes({
    String? status,
    int? page,
    int? limit,
  }) async {
    final response = await _dio.get(
      "/schemes/admin",
      queryParameters: {
        if (status != null) "status": status,
        if (page != null) "page": page,
        if (limit != null) "limit": limit,
      },
    );

    return PaginatedSchemesModel.fromJson(response.data);
  }

  /// Get Single Scheme
  Future<SchemeModel> getSingleScheme(String schemeId) async {
    final response = await _dio.get("/schemes/admin/$schemeId");
    final data = response.data["data"] ?? response.data;
    return SchemeModel.fromJson(data);
  }

  /// Soft Delete Scheme
  Future<void> deleteScheme(String schemeId) async {
    await _dio.delete("/schemes/$schemeId");
  }

  /// WITHDRAW APPLICATION
  /// DELETE /schemes/:schemeId/applications/:applicationId
  Future<void> withdrawApplication(String applicationId, {String? schemeId}) async {
    if (applicationId.isEmpty) {
      throw Exception('Invalid application ID — cannot withdraw');
    }
    try {
      await _dio.delete('/schemes/applications/$applicationId');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to withdraw application');
    }
  }

  /// ============================================
  /// ADMIN SECTION


  Future<String> createScheme(Map<String, dynamic> body) async {
    try {
      final response = await _dio.post("/schemes", data: body);

      // Backend returns created scheme object
      return response.data["_id"];

    } on DioException catch (e) {
      final message =
          e.response?.data?["message"] ?? "Failed to create scheme";
      throw Exception(message);
    }
  }

  /// Update Scheme Details
  Future<void> updateScheme(
      String id, Map<String, dynamic> body) async {
    await _dio.patch("/schemes/$id", data: body);
  }

  /// Publish / Archive Scheme
  Future<void> updateSchemeStatus(
      String id, String status) async {
    try {
      await _dio.patch(
        "/schemes/$id/status",
        data: {"status": status},
      );
    } on DioException catch (e) {
      final message =
          e.response?.data?["message"] ?? "Failed to update status";
      throw Exception(message);
    }
  }


  /// Get Applications For Scheme (Admin)
  Future<PaginatedApplicationsModel> getApplications(
      String schemeId, {int? page, int? limit, String? status}) async {
    final response = await _dio.get(
      "/schemes/$schemeId/applications",
      queryParameters: {
        if (page != null) "page": page,
        if (limit != null) "limit": limit,
        if (status != null && status.isNotEmpty) "status": status,
      }
    );

    return PaginatedApplicationsModel.fromJson(response.data);
  }

  /// Get Single Application
  /// GET /applications/:applicationId
  Future<SchemeApplicationModel> getSingleApplication(String applicationId) async {
    final response = await _dio.get("/schemes/applications/$applicationId");
    final data = response.data["data"] ?? response.data;
    return SchemeApplicationModel.fromJson(data);
  }

  /// Request Waiver
  /// POST /applications/:applicationId/waiver
  Future<void> requestWaiver(String applicationId, String documentUrl, String remark) async {
    await _dio.post(
      "/schemes/applications/$applicationId/waiver",
      data: {
        "documentUrl": documentUrl,
        "remark": remark,
      },
    );
  }

  /// Approve / Reject Application
  /// PATCH /applications/:applicationId/review
  Future<void> updateApplicationStatus(
      String applicationId,
      String status,
      String remarks,
      ) async {
    await _dio.patch(
      "/schemes/applications/$applicationId/review",
      data: {
        "status": status,
        "remarks": remarks,
      },
    );
  }

  /// Activate Application (Move to ACTIVE)
  /// PATCH /applications/:applicationId/activate
  Future<void> activateApplication(String applicationId) async {
    await _dio.patch("/schemes/applications/$applicationId/activate");
  }

  /// Mark Application as Completed
  /// PATCH /applications/:applicationId/complete
  Future<void> completeApplication(String applicationId) async {
    await _dio.patch("/schemes/applications/$applicationId/complete");
  }

  /// ============================================
  /// PAYMENT & PAYOUT SECTION
  /// ============================================

  /// Get Payment History for a Beneficiary Application
  /// GET /applications/:applicationId/payments
  Future<List<dynamic>> getApplicationPayments(String applicationId) async {
    final response = await _dio.get("/schemes/applications/$applicationId/payments");
    return response.data["data"] ?? [];
  }

  /// Mark Payment as Successful (Manual/Webhook)
  /// POST /applications/:applicationId/payment-success
  Future<void> markPaymentSuccess(String applicationId, String transactionId) async {
    await _dio.post(
      "/schemes/applications/$applicationId/payment-success",
      data: {"transactionId": transactionId},
    );
  }

  /// Get Payouts for a Scheme
  Future<List<dynamic>> getSchemePayouts(String schemeId) async {
    final response = await _dio.get("/schemes/$schemeId/payouts");
    return response.data["data"] ?? [];
  }

  /// Get Payouts for a Specific Month
  Future<List<dynamic>> getMonthlyPayouts(String schemeId, int month) async {
    final response = await _dio.get("/schemes/$schemeId/payouts/month/$month");
    return response.data["data"] ?? [];
  }

  /// Create Manual Payout
  /// POST /applications/:applicationId/manual-payout
  Future<void> createManualPayout(String applicationId, double amount, int monthNumber) async {
    await _dio.post(
      "/schemes/applications/$applicationId/manual-payout",
      data: {
        "amount": amount,
        "monthNumber": monthNumber,
      },
    );
  }

  /// Initiate Payment for a Scheme (calls apply endpoint with schemeId)
  /// POST /schemes/:schemeId/apply
  /// Returns razorpay order data when scheme is PAID type
  Future<Map<String, dynamic>> initiateSchemePayment(String schemeId) async {
    print("=================================================");
    print("🚀 API CALL: POST /schemes/$schemeId/apply");
    print("=================================================");
    try {
      final response = await _dio.post("/schemes/$schemeId/apply");
      print("✅ API RESPONSE SUCCESS: ${response.data}");
      final data = response.data["data"] ?? response.data;
      return data is Map<String, dynamic> ? data : Map<String, dynamic>.from(data as Map);
    } on DioException catch (e) {
      print("🚨 API EXCEPTION [initiateSchemePayment]: ${e.response?.data}");
      print("🚨 STATUS CODE: ${e.response?.statusCode}");
      final message = e.response?.data?["message"] ?? "Failed to initiate payment";
      throw Exception(message);
    }
  }

  /// ============================================
  /// DASHBOARD STATS SECTION
  /// ============================================

  /// Get Scheme Summary Stats
  /// GET /dashboard/:schemeId/summary
  Future<Map<String, dynamic>> getSchemeSummary(String schemeId) async {
    final response = await _dio.get("/schemes/dashboard/$schemeId/summary");
    return response.data["data"] ?? {};
  }

  /// Get Unpaid Applications
  /// GET /dashboard/:schemeId/unpaid
  Future<List<SchemeApplicationModel>> getUnpaidApplications(String schemeId, {int month = 1}) async {
    final response = await _dio.get("/schemes/dashboard/$schemeId/unpaid/$month");
    final data = response.data["data"] ?? [];
    return (data as List).map((e) => SchemeApplicationModel.fromJson(e)).toList();
  }

  /// Get Monthly Payout Report
  /// GET /dashboard/:schemeId/monthly-report
  Future<List<dynamic>> getMonthlyReport(String schemeId) async {
    final response = await _dio.get("/schemes/dashboard/$schemeId/monthly-report");
    return response.data["data"] ?? [];
  }
}
