// lib/features/schemes/data/repository/scheme_repository.dart

import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/utils/storage_service.dart';
import '../models/scheme_model.dart';
import '../models/scheme_application_model.dart';

class SchemeRepository {
  final Dio _dio = ApiClient().dio;

  /// ============================================
  /// BENEFICIARY SECTION
  /// ============================================

  /// Get Published Schemes (Public)
  Future<List<SchemeModel>> getPublishedSchemes() async {
    final StorageService storage = StorageService();
    try {
      final response = await _dio.get("/schemes");
      final data = response.data;

      // Cache logic
      try {
        await storage.saveCache(storage.schemeCacheKey, jsonEncode(data));
      } catch (e) {
        print("Failed to cache schemes: $e");
      }

      return (data as List)
          .map((e) => SchemeModel.fromJson(e))
          .toList();
    } catch (e) {
      // Try cache
      try {
        final cached = await storage.getCache(storage.schemeCacheKey);
        if (cached != null) {
          final data = jsonDecode(cached);
          if (data is List) {
             return data.map((e) => SchemeModel.fromJson(e)).toList();
          }
        }
      } catch (cacheError) {
        print("Failed to load scheme cache: $cacheError");
      }
      rethrow;
    }
  }

  Future<void> applyForScheme(String schemeId) async {
    try {
      await _dio.post("/schemes/$schemeId/apply");
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
      final response = await _dio.get("/applications/my");
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
  Future<List<SchemeModel>> getAdminSchemes({
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

    final data = response.data["data"] ?? response.data;

    return (data as List)
        .map((e) => SchemeModel.fromJson(e))
        .toList();
  }

  /// ✅ WITHDRAW APPLICATION (MISSING BEFORE)
  Future<void> withdrawApplication(String applicationId) async {
    await _dio.delete(
      "/schemes/applications/$applicationId",
    );
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
  Future<List<SchemeApplicationModel>> getApplications(
      String schemeId) async {
    final response =
    await _dio.get("/schemes/$schemeId/applications");

    final data = response.data["data"] ?? response.data;

    return (data as List)
        .map((e) => SchemeApplicationModel.fromJson(e))
        .toList();
  }

  /// Approve / Reject Application
  Future<void> updateApplicationStatus(
      String applicationId,
      String status,
      String remarks,
      ) async {
    await _dio.patch(
      "/schemes/applications/$applicationId",
      data: {
        "status": status,
        "remarks": remarks,
      },
    );
  }

  /// Activate Application (Move to ACTIVE)
  Future<void> activateApplication(String applicationId) async {
    await _dio.patch("/schemes/applications/$applicationId/activate");
  }

  /// Mark Application as Completed
  Future<void> completeApplication(String applicationId) async {
    await _dio.patch("/schemes/applications/$applicationId/complete");
  }

  /// ============================================
  /// PAYMENT & PAYOUT SECTION
  /// ============================================

  /// Get Payment History for a Beneficiary Application
  Future<List<dynamic>> getApplicationPayments(String applicationId) async {
    final response = await _dio.get("/schemes/applications/$applicationId/payments");
    return response.data["data"] ?? [];
  }

  /// Mark Payment as Successful (Manual/Webhook)
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
  Future<void> createManualPayout(String applicationId, double amount, String type) async {
    await _dio.post(
      "/schemes/applications/$applicationId/manual-payout",
      data: {
        "amount": amount,
        "type": type, // 'MONTHLY' or 'COMPLETION'
      },
    );
  }

  /// ============================================
  /// DASHBOARD STATS SECTION
  /// ============================================

  /// Get Scheme Summary Stats
  Future<Map<String, dynamic>> getSchemeSummary(String schemeId) async {
    final response = await _dio.get("/schemes/dashboard/$schemeId/summary");
    return response.data["data"] ?? {};
  }

  /// Get Unpaid Applications
  Future<List<SchemeApplicationModel>> getUnpaidApplications(String schemeId) async {
    final response = await _dio.get("/schemes/dashboard/$schemeId/unpaid");
    final data = response.data["data"] ?? [];
    return (data as List).map((e) => SchemeApplicationModel.fromJson(e)).toList();
  }
}
