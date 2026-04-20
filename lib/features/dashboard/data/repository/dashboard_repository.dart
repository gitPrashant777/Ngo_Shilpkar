import 'package:dio/dio.dart';
import 'package:shilpkar/core/api/api_client.dart';
import 'package:shilpkar/core/api/api_endpoints.dart';

/// Response models for dashboard analytics
class DashboardOverview {
  final int totalUsers;
  final int totalPayments;
  final int totalSchemes;
  final int totalApplications;

  DashboardOverview({
    required this.totalUsers,
    required this.totalPayments,
    required this.totalSchemes,
    required this.totalApplications,
  });

  factory DashboardOverview.fromJson(Map<String, dynamic> j) => DashboardOverview(
        totalUsers: j['totalUsers'] ?? 0,
        totalPayments: j['totalPayments'] ?? 0,
        totalSchemes: j['totalSchemes'] ?? 0,
        totalApplications: j['totalApplications'] ?? 0,
      );
}

class DashboardUserGrowth {
  final int employees;
  final int coordinators;
  final int beneficiaries;

  DashboardUserGrowth({
    required this.employees,
    required this.coordinators,
    required this.beneficiaries,
  });

  factory DashboardUserGrowth.fromJson(Map<String, dynamic> j) =>
      DashboardUserGrowth(
        employees: j['employees'] ?? 0,
        coordinators: j['coordinators'] ?? 0,
        beneficiaries: j['beneficiaries'] ?? 0,
      );
}

class DashboardRepository {
  final ApiClient _client = ApiClient();

  /// GET /api/dashboard/overview
  Future<DashboardOverview> getOverview() async {
    try {
      final res = await _client.dio.get(ApiEndpoints.dashboardOverview);
      return DashboardOverview.fromJson(res.data['data'] ?? {});
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch overview');
    }
  }

  /// GET /api/dashboard/user-growth
  Future<DashboardUserGrowth> getUserGrowth() async {
    try {
      final res = await _client.dio.get(ApiEndpoints.dashboardUserGrowth);
      return DashboardUserGrowth.fromJson(res.data['data'] ?? {});
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch user growth');
    }
  }

  /// GET /api/dashboard/payment-summary
  Future<double> getPaymentSummary() async {
    try {
      final res = await _client.dio.get(ApiEndpoints.dashboardPaymentSummary);
      final data = res.data['data'] ?? {};
      return (data['totalRevenue'] ?? 0).toDouble();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch payment summary');
    }
  }
}
