import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';

class NotificationRepository {
  final ApiClient _client = ApiClient();

  // 1. Register FCM Token
  Future<Map<String, dynamic>> registerFcmToken(String token) async {
    try {
      final response = await _client.dio.post(
        '/notification/register-fcm',
        data: {
          'token': token,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    } catch (e) {
      throw Exception('Failed to register FCM token: $e');
    }
  }

  // 2. Remove FCM Token (Logout)
  Future<Map<String, dynamic>> removeFcmToken(String token) async {
    try {
      final response = await _client.dio.delete(
        '/notification/remove-fcm',
        data: {
          'token': token,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    } catch (e) {
      throw Exception('Failed to remove FCM token: $e');
    }
  }

  // 3. Get Notifications (Paginated)
  Future<Map<String, dynamic>> getNotifications({int page = 1, int limit = 10}) async {
    try {
      final response = await _client.dio.get(
        '/notifications',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Backward compatibility
        final legacy = await _client.dio.get(
          '/notification',
          queryParameters: {
            'page': page,
            'limit': limit,
          },
        );
        return legacy.data;
      }
      throw Exception(_handleError(e));
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  // 4. Get Unread Count
  Future<Map<String, dynamic>> getUnreadCount() async {
    try {
      final response = await _client.dio.get('/notifications/unread-count');
      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        final legacy = await _client.dio.get('/notification/unread-count');
        return legacy.data;
      }
      throw Exception(_handleError(e));
    } catch (e) {
      throw Exception('Failed to fetch unread count: $e');
    }
  }

  // 5. Mark Single as Read
  Future<Map<String, dynamic>> markAsRead(String id) async {
    try {
      final response = await _client.dio.patch('/notification/$id/read');
      return response.data;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // 6. Mark All as Read
  Future<Map<String, dynamic>> markAllAsRead() async {
    try {
      final response = await _client.dio.patch('/notification/read-all');
      return response.data;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  String _handleError(DioException e) {
    if (e.response != null && e.response?.data != null) {
      final data = e.response?.data;
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        return data['message'].toString();
      }
    }
    if (e.response?.statusCode != null) {
      return 'Server error: ${e.response?.statusCode}';
    }
    return e.message ?? 'An error occurred';
  }
}
