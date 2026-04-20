import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/chat_request_model.dart';
import '../../data/models/chat_session_model.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/repository/chat_repository.dart';
import '../../data/services/socket_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository _repository = ChatRepository();
  final SocketService _socketService = SocketService();
  bool _isAdminContext = false;
  Timer? _sessionRefreshDebounce;

  final List<ChatRequestModel> _requests = [];
  List<ChatSessionModel> _sessions = [];
  final List<ChatMessageModel> _messages = [];

  ChatSessionModel? _currentSession;
  int _unreadCount = 0;

  bool _isLoading = false;
  String? _errorMessage;

  // Pagination states
  int _messagesPage = 1;
  bool _hasMoreMessages = true;

  int requestsPage = 1;
  int requestsTotalPages = 1;
  int requestsTotal = 0;

  int sessionsPage = 1;
  int sessionsTotalPages = 1;
  int sessionsTotal = 0;

  List<ChatRequestModel> get requests => _requests;
  List<ChatSessionModel> get sessions => _sessions;
  List<ChatMessageModel> get messages => _messages;
  ChatSessionModel? get currentSession => _currentSession;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMoreMessages => _hasMoreMessages;
  bool get isAdminContext => _isAdminContext;

  void setIsAdminContext(bool value) {
    _isAdminContext = value;
  }

  // ==========================================================
  // INITIALIZATION AND SOCKET
  // ==========================================================

  Future<void> initSocket(String baseUrl) async {
    await _socketService.initSocket(baseUrl);

    _socketService.onNewMessage((data) {
      final message = ChatMessageModel.fromJson(data);
      if (_currentSession != null &&
          message.chatSessionId == _currentSession!.id) {
        final exists = _messages.any((m) => m.id == message.id);
        if (!exists) {
          _messages.insert(
            0,
            message,
          ); // Default insert to top if displaying inverted
          notifyListeners();
          // Automatically mark as read if we are actively viewing this session
          markMessagesRead(_currentSession!.id);
        }
      } else {
        // Background message for another session
        _unreadCount++;
        notifyListeners();
        _scheduleSessionRefresh();
      }
    });

    _socketService.onBroadcast((data) {
      _broadcastStreamController.add(data['message']);
    });
  }

  final _broadcastStreamController = StreamController<String>.broadcast();
  Stream<String> get broadcastStream => _broadcastStreamController.stream;

  Future<void> fetchUnreadCount() async {
    try {
      _unreadCount = await _repository.getUnreadCount();
      notifyListeners();
    } catch (_) {}
  }

  // ==========================================================
  // 1. REQUESTS
  // ==========================================================

  Future<void> createRequest(String topic, String role) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final newReq = await _repository.createRequest(topic, role);
      _requests.insert(0, newReq);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fetchMyRequests({bool refresh = false}) async {
    if (refresh) {
      requestsPage = 1;
      _requests.clear();
      _isLoading = true;
      notifyListeners();
    } else {
      _isLoading = true;
      notifyListeners();
    }

    _errorMessage = null;
    try {
      final res = await _repository.getMyRequests(page: requestsPage);

      _requests.clear();
      _requests.addAll(res.data);
      requestsPage = res.page;
      requestsTotalPages = res.totalPages;
      requestsTotal = res.total;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void goToRequestsPage(
    int page, {
    bool isAdmin = false,
    String status = 'PENDING',
  }) {
    if (page < 1 || page > requestsTotalPages || page == requestsPage) return;
    requestsPage = page;
    if (isAdmin) {
      fetchAdminRequests(status: status);
    } else {
      fetchMyRequests();
    }
  }

  Future<void> fetchAdminRequests({
    String status = 'PENDING',
    bool refresh = false,
  }) async {
    if (refresh) {
      requestsPage = 1;
      _requests.clear();
      _isLoading = true;
      notifyListeners();
    } else {
      _isLoading = true;
      notifyListeners();
    }

    _errorMessage = null;
    try {
      final res = await _repository.getRequests(
        status: status,
        page: requestsPage,
      );

      _requests.clear();
      _requests.addAll(res.data);
      requestsPage = res.page;
      requestsTotalPages = res.totalPages;
      requestsTotal = res.total;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> rejectRequest(String requestId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.rejectRequest(requestId);
      _requests.removeWhere((r) => r.id == requestId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> acceptRequest(String requestId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _currentSession = await _repository.acceptRequest(requestId);
      _socketService.joinSession(_currentSession!.id);

      _requests.removeWhere((r) => r.id == requestId);
      _sessions.insert(0, _currentSession!);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteRequest(String requestId) async {
    try {
      await _repository.deleteRequest(requestId);
      _requests.removeWhere((r) => r.id == requestId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // ==========================================================
  // 2. SESSIONS
  // ==========================================================

  Future<void> fetchMyChats({bool refresh = false}) async {
    if (refresh) {
      sessionsPage = 1;
      _sessions.clear();
      _isLoading = true;
      notifyListeners();
    } else {
      _isLoading = true;
      notifyListeners();
    }

    _errorMessage = null;
    try {
      final res = await _repository.getMySessions(page: sessionsPage);

      _sessions.clear();
      _sessions.addAll(res.data);
      _unreadCount =
          _sessions.fold<int>(0, (sum, s) => sum + s.unreadCount);
      sessionsPage = res.page;
      sessionsTotalPages = res.totalPages;
      sessionsTotal = res.total;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void goToSessionsPage(
    int page, {
    bool isAdmin = false,
    String status = 'ACTIVE',
  }) {
    if (page < 1 || page > sessionsTotalPages || page == sessionsPage) return;
    sessionsPage = page;
    if (isAdmin) {
      fetchAdminSessions(status: status);
    } else {
      fetchMyChats();
    }
  }

  Future<void> fetchAdminSessions({
    String status = 'ACTIVE',
    bool refresh = false,
  }) async {
    if (refresh) {
      sessionsPage = 1;
      _sessions.clear();
      _isLoading = true;
      notifyListeners();
    } else {
      _isLoading = true;
      notifyListeners();
    }

    _errorMessage = null;
    try {
      final res = await _repository.getSessions(
        status: status,
        page: sessionsPage,
      );

      _sessions.clear();
      _sessions.addAll(res.data);
      _unreadCount =
          _sessions.fold<int>(0, (sum, s) => sum + s.unreadCount);
      sessionsPage = res.page;
      sessionsTotalPages = res.totalPages;
      sessionsTotal = res.total;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setCurrentSession(ChatSessionModel session) async {
    _currentSession = session;
    _messages.clear();
    _messagesPage = 1;
    _hasMoreMessages = true;
    notifyListeners();

    _socketService.joinSession(session.id);
    await fetchMessages(session.id, refresh: true);
    await markMessagesRead(session.id);
  }

  Future<void> endChat(String sessionId) async {
    try {
      await _repository.endChat(sessionId);
      if (_currentSession?.id == sessionId) {
        _currentSession = null;
      }
      _sessions.removeWhere((s) => s.id == sessionId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> forceCloseSession(String sessionId) async {
    try {
      await _repository.forceCloseSession(sessionId);
      _sessions.removeWhere((s) => s.id == sessionId);
      if (_currentSession?.id == sessionId) _currentSession = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> archiveSession(String sessionId) async {
    try {
      await _repository.archiveSession(sessionId);
      _sessions.removeWhere((s) => s.id == sessionId);
      if (_currentSession?.id == sessionId) _currentSession = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // ==========================================================
  // 3. MESSAGES
  // ==========================================================

  Future<void> fetchMessages(String sessionId, {bool refresh = false}) async {
    if (refresh) {
      _messagesPage = 1;
      _hasMoreMessages = true;
      _messages.clear();
    }
    if (!_hasMoreMessages) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final newMessages = await _repository.getMessages(
        sessionId,
        page: _messagesPage,
        limit: 20,
      );
      if (newMessages.length < 20) _hasMoreMessages = false;

      // Append older messages to bottom of reversed list view
      _messages.addAll(newMessages);
      _messagesPage++;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markMessagesRead(String sessionId) async {
    try {
      await _repository.markMessagesAsRead(sessionId);
      fetchUnreadCount();
    } catch (_) {}
  }

  void _scheduleSessionRefresh() {
    _sessionRefreshDebounce?.cancel();
    _sessionRefreshDebounce = Timer(const Duration(milliseconds: 600), () {
      if (_isAdminContext) {
        fetchAdminSessions(refresh: true);
      } else {
        fetchMyChats(refresh: true);
      }
    });
  }

  Future<void> sendMessage(
    String text,
    String sessionId, {
    String? filePath,
  }) async {
    // Optimistic UI could be implemented, but REST guarantees success prior to append.
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final message = await _repository.sendMessage(
        sessionId: sessionId,
        text: text,
        filePath: filePath,
      );

      final exists = _messages.any((m) => m.id == message.id);
      if (!exists) {
        _messages.insert(0, message);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _sessionRefreshDebounce?.cancel();
    _socketService.disconnect();
    _broadcastStreamController.close();
    super.dispose();
  }
}
