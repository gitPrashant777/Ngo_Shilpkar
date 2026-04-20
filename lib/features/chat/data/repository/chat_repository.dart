import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/chat_request_model.dart';
import '../models/chat_session_model.dart';
import '../models/chat_message_model.dart';
import '../models/broadcast_model.dart';

/// Centralized repository handling all 21 endpoints defined in the Chat Module API Contract.
class ChatRepository {
  final ApiClient _client = ApiClient();

  // ==========================================================
  // 1. CHAT REQUESTS (User <-> Admin Flow)
  // ==========================================================

  /// 🟢 1️⃣ POST /request
  /// Creates a new support chat request. All authenticated users.
  Future<ChatRequestModel> createRequest(String topic, String role) async {
    try {
      final response = await _client.dio.post(
        '/chat/request',
        data: {'topic': topic, 'role': role},
      );
      return ChatRequestModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to create request');
    }
  }

  /// 🟢 2️⃣ GET /my-requests
  /// Get user's own chat requests.
  Future<PaginatedChatRequestsModel> getMyRequests({int page = 1, int limit = 10}) async {
    try {
      final response = await _client.dio.get(
        '/chat/my-requests',
        queryParameters: {'page': page, 'limit': limit},
      );
      final raw = response.data;
      return PaginatedChatRequestsModel.fromJson(raw is Map<String, dynamic> ? raw : {});
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch my requests');
    }
  }

  /// 🟢 3️⃣ GET /admin/requests
  /// Get chat requests (Admin Only). Filter by status.
  Future<PaginatedChatRequestsModel> getRequests({String status = 'PENDING', int page = 1}) async {
    try {
      final response = await _client.dio.get(
        '/chat/admin/requests',
        queryParameters: {'status': status, 'page': page},
      );
      final raw = response.data;
      return PaginatedChatRequestsModel.fromJson(raw is Map<String, dynamic> ? raw : {});
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch requests');
    }
  }

  /// 🟢 4️⃣ GET /requests/:id
  /// Get single chat request details.
  Future<ChatRequestModel> getRequest(String id) async {
    try {
      final response = await _client.dio.get('/chat/requests/$id');
      return ChatRequestModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch request details');
    }
  }

  /// 🟢 5️⃣ POST /accept/:requestId
  /// Accept a request (Admin Only) -> Returns a ChatSession.
  Future<ChatSessionModel> acceptRequest(String requestId) async {
    try {
      final response = await _client.dio.post('/chat/accept/$requestId');
      return ChatSessionModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to accept chat request');
    }
  }

  /// 🟢 6️⃣ POST /reject/:requestId
  /// Reject a request (Admin Only).
  Future<ChatRequestModel> rejectRequest(String requestId) async {
    try {
      final response = await _client.dio.post('/chat/reject/$requestId');
      return ChatRequestModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to reject chat request');
    }
  }

  /// 🟢 7️⃣ DELETE /requests/:id
  /// Delete a chat request.
  Future<void> deleteRequest(String id) async {
    try {
      await _client.dio.delete('/chat/requests/$id');
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to delete request');
    }
  }

  // ==========================================================
  // 2. CHAT SESSIONS & MESSAGES (Core Chat Room)
  // ==========================================================

  /// 🟢 8️⃣ GET /my-sessions
  /// List current user's active sessions.
  Future<PaginatedChatSessionsModel> getMySessions({int page = 1, int limit = 10}) async {
    try {
      final response = await _client.dio.get(
        '/chat/my-sessions',
        queryParameters: {'page': page, 'limit': limit},
      );
      final raw = response.data;
      return PaginatedChatSessionsModel.fromJson(raw is Map<String, dynamic> ? raw : {});
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch my sessions');
    }
  }

  /// 🟢 9️⃣ GET /sessions
  /// List sessions globally (Admin Only). Filter by status.
  Future<PaginatedChatSessionsModel> getSessions({String status = 'ACTIVE', int page = 1}) async {
    try {
      final response = await _client.dio.get(
        '/chat/sessions',
        queryParameters: {'status': status, 'page': page},
      );
      final raw = response.data;
      return PaginatedChatSessionsModel.fromJson(raw is Map<String, dynamic> ? raw : {});
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch sessions');
    }
  }

  /// 🟢 🔟 POST /end/:chatSessionId
  /// Normal closure of a chat session.
  Future<ChatSessionModel> endChat(String sessionId) async {
    try {
      final response = await _client.dio.post('/chat/end/$sessionId');
      return ChatSessionModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to end chat');
    }
  }

  /// 🟢 1️⃣1️⃣ PATCH /sessions/:id/force-close
  /// Force close a session (Admin Only usually).
  Future<ChatSessionModel> forceCloseSession(String sessionId) async {
    try {
      final response = await _client.dio.patch('/chat/sessions/$sessionId/force-close');
      return ChatSessionModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to force close chat');
    }
  }

  /// 🟢 1️⃣2️⃣ PATCH /sessions/:id/archive
  /// Archive a chat session.
  Future<void> archiveSession(String sessionId) async {
    try {
      await _client.dio.patch('/chat/sessions/$sessionId/archive');
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to archive session');
    }
  }

  /// 🟢 1️⃣3️⃣ POST /message
  /// Send a text/file message. File must be uploaded FIRST via POST /uploads
  Future<ChatMessageModel> sendMessage({
    required String sessionId,
    String? text,
    String? filePath,
  }) async {
    try {
      Response response;
      if (filePath != null && filePath.isNotEmpty) {
        final fileName = filePath.split(RegExp(r'[\\/]')).last;
        final formData = FormData.fromMap({
          'chatSessionId': sessionId,
          if (text != null && text.isNotEmpty) 'text': text,
          'file': await MultipartFile.fromFile(filePath, filename: fileName),
        });
        response = await _client.dio.post(
          '/chat/message',
          data: formData,
          options: Options(contentType: 'multipart/form-data'),
        );
      } else {
        response = await _client.dio.post(
          '/chat/message',
          data: {
            'chatSessionId': sessionId,
            if (text != null && text.isNotEmpty) 'text': text,
          },
        );
      }
      return ChatMessageModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to send message');
    }
  }

  /// 🟢 1️⃣4️⃣ GET /messages/:chatSessionId
  /// Read messages logic w/ pagination.
  Future<List<ChatMessageModel>> getMessages(String sessionId, {int page = 1, int limit = 20}) async {
    try {
      final response = await _client.dio.get(
        '/chat/messages/$sessionId',
        queryParameters: {'page': page, 'limit': limit},
      );
      final List data = response.data['data'] ?? [];
      return data.map((e) => ChatMessageModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to load messages');
    }
  }

  /// 🟢 1️⃣5️⃣ PATCH /messages/:chatSessionId/read
  /// Mark messages as read.
  Future<void> markMessagesAsRead(String sessionId) async {
    try {
      await _client.dio.patch('/chat/messages/$sessionId/read');
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to mark messages as read');
    }
  }

  /// 🟢 1️⃣6️⃣ GET /unread-count
  /// Get total unread message count.
  Future<int> getUnreadCount() async {
    try {
      final response = await _client.dio.get('/chat/unread-count');
      return response.data['data']['unread'] ?? 0;
    } on DioException catch (_) {
      return 0; // Default to 0 on failure so UI doesn't crash
    }
  }

  // ==========================================================
  // 3. BROADCASTS (Super Admin to All)
  // ==========================================================

  /// 🟢 1️⃣7️⃣ POST /broadcast
  Future<void> createBroadcast({
    required String message,
    String? category,
    List<String>? targetRoles,
    List<String>? targetCategories,
    bool isEmergency = false,
  }) async {
    try {
      await _client.dio.post(
        '/chat/broadcast',
        data: {
          'message': message,
          if (category != null && category.isNotEmpty) 'category': category,
          if (targetRoles != null && targetRoles.isNotEmpty) 'targetRoles': targetRoles,
          if (targetCategories != null && targetCategories.isNotEmpty) 'targetCategories': targetCategories,
          if (isEmergency) 'isEmergency': true,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to send broadcast');
    }
  }

  /// 🟢 1️⃣8️⃣ GET /broadcasts
  /// Admin view all broadcasts
  Future<List<BroadcastModel>> getBroadcasts() async {
    try {
      final response = await _client.dio.get('/chat/broadcasts');
      final List data = response.data['data'] ?? [];
      return data.map((e) => BroadcastModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch broadcasts');
    }
  }

  /// 🟢 1️⃣9️⃣ GET /broadcasts/public
  /// User view public broadcasts
  Future<List<BroadcastModel>> getPublicBroadcasts() async {
    try {
      final response = await _client.dio.get('/chat/broadcasts/public');
      final List data = response.data['data'] ?? [];
      return data.map((e) => BroadcastModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch public broadcasts');
    }
  }

  /// 🟢 2️⃣0️⃣ PATCH /broadcast/:id
  Future<void> updateBroadcast(String id, String newMessage) async {
    try {
      await _client.dio.patch(
        '/chat/broadcast/$id',
        data: {'message': newMessage},
      );
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to update broadcast');
    }
  }

  /// 🟢 2️⃣1️⃣ DELETE /broadcast/:id
  Future<void> deleteBroadcast(String id) async {
    try {
      await _client.dio.delete('/chat/broadcast/$id');
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to delete broadcast');
    }
  }

  // ==========================================================
  // 4. HELPERS
  // ==========================================================

  /// Upload emergency siren (Super Admin only).
  Future<String?> uploadEmergencySiren(String filePath) async {
    try {
      final fileName = filePath.split(RegExp(r'[\\/]')).last;
      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await _client.dio.post(
        ApiEndpoints.adminEmergencySiren,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final data = response.data is Map<String, dynamic>
          ? response.data['data']
          : null;
      if (data is Map<String, dynamic>) {
        final value = data['value'];
        if (value is Map<String, dynamic>) {
          return value['url']?.toString();
        }
      }
      return null;
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to upload emergency siren');
    }
  }

  /// File Upload handled by global /uploads endpoint
  Future<Map<String, String>> uploadFile(String filePath, String module) async {
    try {
      String fileName = filePath.split('/').last;
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
        'module': module,
      });

      final response = await _client.dio.post(
        '/uploads',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      
      return {
        'url': response.data['data']['url'] ?? response.data['url'],
        'type': response.data['data']['type'] ?? response.data['type'] ?? 'file',
      };
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to upload file');
    }
  }

  Exception _handleError(DioException e, String defaultMessage) {
    if (e.response != null && e.response?.data is Map) {
      final msg = e.response?.data['message'];
      if (msg != null && msg.toString().isNotEmpty) {
        return Exception(msg);
      }
    }
    return Exception(defaultMessage);
  }
}
