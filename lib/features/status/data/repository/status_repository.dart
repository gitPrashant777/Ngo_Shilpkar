import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/utils/device_manager.dart';
import '../models/status_model.dart';

class StatusRepository {
  final ApiClient _client = ApiClient();

  // 1️⃣ GET active statuses (public – no auth)
  Future<List<StatusModel>> getActiveStatuses() async {
    try {
      final response = await _client.dio.get('/status');
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((e) => StatusModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to fetch statuses');
    }
  }

  // 2️⃣ CREATE status (Super Admin, multipart)
  Future<List<StatusModel>> createStatuses({
    String? caption,
    required List<String> filePaths,
    List<String?>? mimeTypes,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    try {
      final Map<String, dynamic> formMap = {};
      if (caption != null && caption.isNotEmpty) {
        formMap['caption'] = caption;
      }
      if (filePaths.isNotEmpty) {
        final files = <MultipartFile>[];
        for (var i = 0; i < filePaths.length; i++) {
          final mimeType = mimeTypes != null && i < mimeTypes.length
              ? mimeTypes[i]
              : null;
          files.add(
            await MultipartFile.fromFile(
              filePaths[i],
              contentType:
                  mimeType != null ? DioMediaType.parse(mimeType) : null,
            ),
          );
        }
        formMap['files'] = files;
      }
      final response = await _client.dio.post(
        '/status',
        data: FormData.fromMap(formMap),
        options: Options(contentType: 'multipart/form-data'),
        onSendProgress: onSendProgress,
      );
      final data = response.data['data'];
      if (data is List) {
        return data.map((e) => StatusModel.fromJson(e)).toList();
      }
      if (data is Map<String, dynamic>) {
        return [StatusModel.fromJson(data)];
      }
      return [];
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to create status');
    }
  }

  // 3️⃣ EDIT caption (Super Admin)
  Future<StatusModel> editCaption(String id, String caption) async {
    try {
      final response = await _client.dio.patch(
        '/status/$id',
        data: {'caption': caption},
      );
      return StatusModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to update caption');
    }
  }

  // 4️⃣ TOGGLE PIN
  Future<Map<String, dynamic>> togglePin(String id) async {
    try {
      final response = await _client.dio.patch('/status/pin/$id');
      return response.data['data'];
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to toggle pin');
    }
  }

  // 5️⃣ DELETE (soft delete)
  Future<void> deleteStatus(String id) async {
    try {
      await _client.dio.delete('/status/$id');
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to delete status');
    }
  }

  // 6️⃣ RECORD VIEW — POST /api/status/view/:id
  // Device-based anonymous impression tracking.
  // Works for guests (optionalProtect) — logs userId if JWT token is present.
  Future<void> recordView(String statusId) async {
    try {
      await DeviceManager.initialize();
      await _client.dio.post(
        ApiEndpoints.statusView(statusId),
        data: {'deviceId': DeviceManager.deviceId},
      );
    } catch (_) {
      // Fire-and-forget — silently ignore so the story viewer is unaffected
    }
  }

  // 7️⃣ GET VIEW COUNT — GET /api/status/:id/views
  Future<int> getViewCount(String statusId) async {
    try {
      final res = await _client.dio.get(ApiEndpoints.statusViews(statusId));
      return (res.data['totalViews'] ?? 0) as int;
    } on DioException catch (_) {
      return 0;
    }
  }

  // 8️⃣ GET VIEW DETAILS — GET /api/status/:id/views
  Future<List<Map<String, dynamic>>> getStatusViewsDetails(String statusId) async {
    try {
      final res = await _client.dio.get(ApiEndpoints.statusViews(statusId));
      
      final data = res.data['data'];
      
      // If data is a list directly
      if (data is List) return data.cast<Map<String, dynamic>>();
      
      // If data is a map containing views array
      if (data is Map && data['views'] is List) {
        return (data['views'] as List).cast<Map<String, dynamic>>();
      }
      
      // Backward compatibility hook
      final views = res.data['views'];
      if (views is List) return views.cast<Map<String, dynamic>>();
      
      return [];
    } catch (e) {
      print("ERROR fetching views: $e");
      return [];
    }
  }
}
