import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../models/job_model.dart';
import '../models/application_model.dart';
import '../models/user_job_application_model.dart';

class JobRepository {
  final ApiClient _client = ApiClient();

  // =============================
  // GET ALL JOBS (WITH FILTERS)
  // =============================
  Future<List<JobModel>> getJobs({
    String? city,
    String? category,
    int? page,
    int? limit,
    String? status, // Add status filter
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (city != null && city.isNotEmpty) queryParams['city'] = city;
      if (category != null && category.isNotEmpty) queryParams['category'] = category;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      final response = await _client.dio.get("/jobs", queryParameters: queryParams);

      print("📦 JOBS RESPONSE: ${response.data}");

      final Map<String, dynamic> json = response.data;

      // API returns paginated data directly without "success" field
      final List<dynamic> jobList = json["data"] ?? [];

      return jobList
          .map((e) => JobModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ??
            "Something went wrong while fetching jobs",
      );
    }
  }

  // =============================
  // CREATE JOB
  // =============================
  Future<void> createJob(Map<String, dynamic> data) async {
    try {
      final response =
      await _client.dio.post('/jobs', data: data);

      if (response.data["success"] != true && response.statusCode != 201) {
         // Some APIs might not return success: true but rely on 201
         // Check payload just in case
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ??
            "Failed to create job",
      );
    }
  }

  // =============================
  // UPDATE JOB STATUS (OPEN/CLOSED)
  // =============================
  Future<void> updateJobStatus(String jobId, String status) async {
    try {
      await _client.dio.patch(
        '/jobs/$jobId/status',
        data: {"status": status},
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ?? "Failed to update job status",
      );
    }
  }

  // =============================
  // APPLY JOB
  // =============================
  Future<String> applyJob(
      String jobId, Map<String, dynamic> data) async {
    try {
      final response =
      await _client.dio.post('/jobs/$jobId/apply', data: data);

      if (response.data["success"] != true) {
         // Check if message exists, otherwise throw generic
         if (response.data["message"] != null) {
            // It might be a success message, continue if 200/201
            if (response.statusCode != 200 && response.statusCode != 201) {
                throw Exception(response.data["message"]);
            }
         }
      }

      return response.data["message"] ?? "Application successful";
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ??
            "Failed to apply for job",
      );
    }
  }

  // =============================
  // GET APPLICATIONS (FOR ADMIN / SUPER ADMIN)
  // =============================
  Future<List<ApplicationModel>> getApplications(
      String jobId) async {
    try {
      final response =
      await _client.dio.get('/applications/job/$jobId');

      print("📦 APPLICATIONS RESPONSE: ${response.data}");

      if (response.data is List) {
        final List<dynamic> list = response.data;
        return list
            .map((e) => ApplicationModel.fromJson(e))
            .toList();
      } else if (response.data is Map && response.data["data"] is List) {
         // Handle potential pagination wrapper just in case
        return (response.data["data"] as List)
            .map((e) => ApplicationModel.fromJson(e))
            .toList();
      } else {
        return [];
      }

    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ??
            "Failed to fetch applications",
      );
    }
  }

  // =============================
  // UPDATE APPLICATION STATUS
  // =============================
  Future<String> updateApplicationStatus(
      String applicationId, String status) async {
    try {
      final response = await _client.dio.patch(
        '/applications/$applicationId/status',
        data: {"status": status},
      );

      return response.data["message"] ?? "Status updated";
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ??
            "Failed to update status",
      );
    }
  }

  // =============================
  // GET MY APPLICATIONS (BENEFICIARY)
  // =============================
  Future<List<UserJobApplicationModel>> getMyApplications() async {
    try {
      final response = await _client.dio.get('/applications/my');
      
      if (response.data is List) {
        return (response.data as List)
            .map((e) => UserJobApplicationModel.fromJson(e))
            .toList();
      } else if (response.data is Map && response.data["data"] is List) {
        return (response.data["data"] as List)
            .map((e) => UserJobApplicationModel.fromJson(e))
            .toList();
      } else {
        return [];
      }
    } on DioException catch (e) {
       // Graceful handling if endpoint returns 404
      if (e.response?.statusCode == 404) return [];
      
      throw Exception(
        e.response?.data["message"] ??
            "Failed to fetch my applications",
      );
    }
  }
}
