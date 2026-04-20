import 'package:flutter/foundation.dart';
import '../../../dashboard/data/repository/dashboard_repository.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardRepository _repo = DashboardRepository();

  // ── State ──────────────────────────────────────────────────────────────────
  bool isLoading = false;
  String? error;

  // Overview
  int totalUsers = 0;
  int totalPayments = 0;
  int totalSchemes = 0;
  int totalApplications = 0;

  // User Growth
  int employees = 0;
  int coordinators = 0;
  int beneficiaries = 0;

  // Revenue
  double totalRevenue = 0;

  // Derived
  int get totalStaff => employees + coordinators;

  /// Fetch all three dashboard endpoints (sequentially to preserve types)
  Future<void> fetchAll({bool refresh = false}) async {
    if (isLoading) return;
    if (!refresh && totalUsers > 0) return; // already loaded

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final overview = await _repo.getOverview();
      final growth = await _repo.getUserGrowth();
      final revenue = await _repo.getPaymentSummary();

      totalUsers = overview.totalUsers;
      totalPayments = overview.totalPayments;
      totalSchemes = overview.totalSchemes;
      totalApplications = overview.totalApplications;

      employees = growth.employees;
      coordinators = growth.coordinators;
      beneficiaries = growth.beneficiaries;

      totalRevenue = revenue;
    } catch (e) {
      error = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
