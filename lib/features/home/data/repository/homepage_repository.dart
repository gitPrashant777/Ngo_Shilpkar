import 'dart:convert';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/utils/storage_service.dart';
import '../models/homepage_model.dart';

class HomepageRepository {
  final ApiClient _client = ApiClient();

  /// Safely parse response.data which might be String or Map
  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is String) {
      try {
        return jsonDecode(data) as Map<String, dynamic>;
      } catch (_) {
        return {};
      }
    }
    return {};
  }

  // =============================
  // GET HOMEPAGE (Public)
  // =============================
  Future<HomepageModel> getHomepage() async {
    try {
      // Per flow: GET /api/homepage (base /api from ApiClient)
      final response = await _client.dio.get('/homepage');
      debugPrint('📦 GET /homepage → ${response.data}');
      final map = _asMap(response.data);
      
      // Spec says response might have { coverImages, ... } directly 
      // or wrapped in { data: { ... } }
      final innerData = map['data'];
      return HomepageModel.fromJson(innerData != null ? _asMap(innerData) : map);
    } on DioException catch (e) {
      debugPrint('❌ GET /homepage FAILED: ${e.message}');
      final errMap = _asMap(e.response?.data);
      throw Exception(errMap['message'] ?? 'Failed to fetch homepage');
    }
  }

  // =============================
  // UPLOAD COVER IMAGE (SUPER_ADMIN)
  // =============================
  Future<HomepageModel> uploadCoverImage(
    String filePath, {
    ProgressCallback? onProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });

      final response = await _client.dio.post(
        '/homepage/cover', // Following spec POST /cover under homepage context
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
        onSendProgress: onProgress,
      );

      debugPrint('📦 POST /homepage/cover → ${response.data}');
      final map = _asMap(response.data);
      final innerData = map['data'];
      return HomepageModel.fromJson(innerData != null ? _asMap(innerData) : map);
    } on DioException catch (e) {
      debugPrint('❌ IMAGE UPLOAD FAILED: ${e.response?.data}');
      final errMap = _asMap(e.response?.data);
      throw Exception(errMap['message'] ?? 'Failed to upload cover image');
    }
  }

  // =============================
  // DELETE COVER IMAGE (SUPER_ADMIN)
  // =============================
  Future<HomepageModel> deleteCoverImage(String key) async {
    try {
      debugPrint('🗑️ ATTEMPTING DELETE IMAGE KEY: "$key"');
      final response = await _client.dio.delete(
        '/homepage/cover',
        data: {'key': key},
      );

      debugPrint('📦 DELETE /homepage/cover → ${response.data}');
      final map = _asMap(response.data);
      final innerData = map['data'];
      return HomepageModel.fromJson(innerData != null ? _asMap(innerData) : map);
    } on DioException catch (e) {
      debugPrint('❌ IMAGE DELETE FAILED: ${e.response?.data}');
      final errMap = _asMap(e.response?.data);
      throw Exception(errMap['message'] ?? 'Failed to delete cover image');
    }
  }

  // =============================
  // UPLOAD COVER VIDEO (SUPER_ADMIN)
  // =============================
  Future<HomepageModel> uploadCoverVideo(
    String filePath, {
    ProgressCallback? onProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });

      final response = await _client.dio.post(
        '/homepage/cover-video',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
        onSendProgress: onProgress,
      );

      debugPrint('📦 POST /homepage/cover-video → ${response.data}');
      final map = _asMap(response.data);
      final innerData = map['data'];
      return HomepageModel.fromJson(innerData != null ? _asMap(innerData) : map);
    } on DioException catch (e) {
      debugPrint('❌ VIDEO UPLOAD FAILED: ${e.response?.data}');
      final errMap = _asMap(e.response?.data);
      throw Exception(errMap['message'] ?? 'Failed to upload cover video');
    }
  }

  // =============================
  // DELETE COVER VIDEO (SUPER_ADMIN)
  // =============================
  Future<HomepageModel> deleteCoverVideo(String key) async {
    try {
      debugPrint('🗑️ ATTEMPTING DELETE VIDEO KEY: "$key"');
      final response = await _client.dio.delete(
        '/homepage/cover-video',
        data: {'key': key},
      );

      debugPrint('📦 DELETE /homepage/cover-video → ${response.data}');
      final map = _asMap(response.data);
      final innerData = map['data'];
      return HomepageModel.fromJson(innerData != null ? _asMap(innerData) : map);
    } on DioException catch (e) {
      debugPrint('❌ VIDEO DELETE FAILED: ${e.response?.data}');
      final errMap = _asMap(e.response?.data);
      throw Exception(errMap['message'] ?? 'Failed to delete cover video');
    }
  }

  // =============================
  // UPDATE WELCOME SECTION (SUPER_ADMIN)
  // =============================
  Future<HomepageModel> updateWelcomeSection({
    String? title,
    String? subtitle,
    bool? isVisible,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (title != null) body['title'] = title;
      if (subtitle != null) body['subtitle'] = subtitle;
      if (isVisible != null) body['isVisible'] = isVisible;

      final response = await _client.dio.patch(
        '/homepage/welcome',
        data: body,
      );

      debugPrint('📦 PATCH /homepage/welcome → ${response.data}');
      final map = _asMap(response.data);
      final innerData = map['data'];
      return HomepageModel.fromJson(innerData != null ? _asMap(innerData) : map);
    } on DioException catch (e) {
      debugPrint('❌ WELCOME UPDATE FAILED: ${e.response?.data}');
      final errMap = _asMap(e.response?.data);
      throw Exception(errMap['message'] ?? 'Failed to update welcome section');
    }
  }
}
