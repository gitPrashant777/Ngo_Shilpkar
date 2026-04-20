import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/utils/storage_service.dart';
import '../../../../core/utils/token_holder.dart';
import '../models/job_model.dart';
import '../models/application_model.dart';
import '../models/user_job_application_model.dart';
import '../../presentation/screens/local_job_data.dart';

class JobRepository {
  final ApiClient _client = ApiClient();

  // =============================
  // GET ALL JOBS (WITH FILTERS)
  // =============================
  // =============================
  // GET ALL JOBS (WITH FILTERS)
  // =============================
  Future<PaginatedJobsModel> getJobs({
    String? city,
    String? category,
    int? page,
    int? limit,
    String? status, // Add status filter
  }) async {
    final StorageService storage = StorageService();
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

      // Cache the result ONLY if it's the first page/default filter to keep it simple
      // or cache the latest successful fetch regardless. 
      // For simplicity and "guest view", caching the latest public list is good.
      try {
        if (page == 1 || page == null) {
             await storage.saveCache(storage.jobCacheKey, jsonEncode(json));
        }
      } catch (e) {
        print("Failed to cache jobs: $e");
      }

      return PaginatedJobsModel.fromJson(json);
    } on DioException catch (e) {
      
      // Try to load from cache
      try {
        final cached = await storage.getCache(storage.jobCacheKey);
        if (cached != null && cached.isNotEmpty) {
           print("📦 JOBS LOADED FROM CACHE");
           final Map<String, dynamic> json = jsonDecode(cached);
           return PaginatedJobsModel.fromJson(json);
        }
      } catch (cacheError) {
        print("Failed to load job cache: $cacheError");
      }

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
  // GET SINGLE JOB
  // =============================
  Future<JobModel> getJobById(String jobId) async {
    try {
      final response = await _client.dio.get('/jobs/$jobId');
      final data = response.data['data'] ?? response.data;
      return JobModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ?? "Failed to fetch job details",
      );
    }
  }

  // =============================
  // UPLOAD FILE (Resume / Photo)
  // =============================
  /// Skips NGO auth when no admin token is present.
  /// If only an e-commerce customer token exists and we send it to the
  /// NGO /uploads endpoint, the server returns 401 "User not found".
  /// Guests (no admin token) are allowed to upload files anonymously.
  Future<Map<String, String>> uploadFile(String filePath, String module) async {
    try {
      final fileName = filePath.split(RegExp(r'[\\/]')).last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
        'module': module,
      });

      // If the user is a guest (no NGO admin token), skip auth so the
      // customer token is NOT forwarded to the NGO upload endpoint.
      final bool guestUpload = !tokenHolder.hasAdminToken;

      final response = await _client.dio.post(
        '/uploads',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          extra: guestUpload ? {'skipAuth': true} : {},
        ),
      );

      return {
        'url': response.data['url']?.toString() ?? '',
        'type': response.data['type']?.toString() ?? '',
      };
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?["message"] ?? "Failed to upload file",
      );
    }
  }

  // =============================
  // APPLY JOB
  // =============================
  /// Returns a map: { 'message': String, 'applicationId': String? }
  ///
  /// Auth strategy:
  ///   NGO Beneficiary  → adminToken (preferred by interceptor) + userId in body
  ///   Guest / Customer → customerToken (fallback in interceptor) + isGuest:true in body
  Future<Map<String, dynamic>> applyJob(
      String jobId, Map<String, dynamic> data) async {
    try {
      // Auth: interceptor sends adminToken for NGO users, customerToken for guests.
      // No special options needed — the correct token is attached automatically.
      final response = await _client.dio.post(
        '/applications/$jobId/apply',
        data: data,
      );

      final responseData = response.data as Map<String, dynamic>? ?? {};
      // Backend returns { _id, applicantType, status } or { message, ... }
      final applicationId = responseData['_id']?.toString() ??
          responseData['id']?.toString() ??
          responseData['applicationId']?.toString();

      // Persist the applicationId so the user can track their application
      if (applicationId != null && applicationId.isNotEmpty) {
        await LocalJobDataStorage.saveApplicationId(applicationId);
      }

      return {
        'message': responseData['message']?.toString() ??
            'Application submitted successfully',
        'applicationId': applicationId,
      };
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?["message"] ?? "Failed to apply for job",
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
      print("📤 PATCH /applications/$applicationId/status → {status: $status}");
      print("📤 Full URL: ${_client.dio.options.baseUrl}/applications/$applicationId/status");
      
      final response = await _client.dio.patch(
        '/applications/$applicationId/status',
        data: {"status": status},
      );

      print("✅ UPDATE STATUS RESPONSE [${response.statusCode}]: ${response.data}");
      return response.data["message"] ?? "Status updated";
    } on DioException catch (e) {
      print("❌ UPDATE STATUS FAILED: ${e.response?.statusCode}");
      print("❌ ERROR RESPONSE BODY: ${e.response?.data}");
      print("❌ ERROR HEADERS: ${e.response?.headers}");
      
      // Extract a meaningful message
      String errorMsg = "Failed to update status";
      if (e.response?.data is Map) {
        errorMsg = e.response?.data["message"] ?? 
                   e.response?.data["error"] ?? errorMsg;
      } else if (e.response?.data is String) {
        errorMsg = e.response!.data;
      }
      
      throw Exception(errorMsg);
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
