import 'package:flutter/material.dart';

import '../../data/models/job_model.dart';
import '../../data/models/application_model.dart';
import '../../data/models/user_job_application_model.dart';
import '../../data/repository/job_repository.dart';


class JobProvider extends ChangeNotifier {
  final JobRepository _repository = JobRepository();

  // ─────────────────── JOB LIST PAGINATION ───────────────────
  List<JobModel> jobs = [];
  int jobPage = 1;
  int jobTotalPages = 1;
  int jobTotal = 0;
  bool isLoading = false;

  String? _currentCity;
  String? _currentCategory;
  String? _currentStatus;

  /// Call with refresh=true to reset filters/page and reload.
  Future<void> fetchJobs({
    String? city,
    String? category,
    String? status,
    bool refresh = false,
  }) async {
    if (refresh) {
      jobPage = 1;
      jobs.clear();
      _currentCity = city;
      _currentCategory = category;
      _currentStatus = status;
      isLoading = true;
      notifyListeners();
    } else {
      city ??= _currentCity;
      category ??= _currentCategory;
      status ??= _currentStatus;
      isLoading = true;
      notifyListeners();
    }

    try {
      final res = await _repository.getJobs(
        city: city,
        category: category,
        status: status,
        page: jobPage,
        limit: 10,
      );
      
      jobs = res.data;
      jobPage = res.page;
      jobTotalPages = res.totalPages;
      jobTotal = res.total;
    } catch (e) {
      debugPrint("Error fetching jobs: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void goToJobPage(int page) {
    if (page < 1 || page > jobTotalPages || page == jobPage) return;
    jobPage = page;
    fetchJobs();
  }


  Future<void> createJob(Map<String, dynamic> data) async {
    await _repository.createJob(data);
    await fetchJobs(refresh: true);
  }

  Future<void> updateJobStatus(String jobId, String status) async {
    await _repository.updateJobStatus(jobId, status);
    await fetchJobs(refresh: true);
  }

  Future<Map<String, String>> uploadFile(String filePath, String module) async {
    return await _repository.uploadFile(filePath, module);
  }

  Future<Map<String, dynamic>> applyJob(String jobId, Map<String, dynamic> data) async {
    return await _repository.applyJob(jobId, data);
  }

  // ─────────────────── APPLICATIONS ───────────────────
  List<ApplicationModel> applications = [];

  Future<void> fetchApplications(String jobId) async {
    isLoading = true;
    notifyListeners();
    try {
      applications = await _repository.getApplications(jobId);
    } catch (e) {
      debugPrint("Error fetching applications: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<UserJobApplicationModel> myApplications = [];

  Future<void> fetchMyApplications() async {
    isLoading = true;
    notifyListeners();

    try {
      myApplications = await _repository.getMyApplications();
    } catch (e) {
      debugPrint("Error fetching applications: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateApplicationStatus(String id, String status) async {
    await _repository.updateApplicationStatus(id, status);
    final index = applications.indexWhere((e) => e.id == id);
    if (index != -1) {
      await fetchApplications(applications[index].jobId);
    }
  }
}
