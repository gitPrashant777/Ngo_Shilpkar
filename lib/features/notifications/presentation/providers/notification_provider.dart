import 'package:flutter/material.dart';
import '../../../../core/utils/storage_service.dart';
import '../../../../core/utils/emergency_alarm.dart';
import '../../data/models/notification_model.dart';
import '../../data/repository/notification_repository.dart';


class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository = NotificationRepository();
  final StorageService _storage = StorageService();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _unreadCount = 0;
  final Set<String> _playedEmergencyIds = {};
  
  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _unreadCount;
  bool get hasMore => _hasMore;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Fetch Notifications
  Future<void> fetchNotifications({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _notifications.clear();
      _hasMore = true;
    }

    if (!_hasMore || _isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    // We only notify if it's a refresh to avoid jumping UI for pagination, 
    // but typically safe to notify
    if (refresh) notifyListeners();

    try {
      final data = await _repository.getNotifications(page: _currentPage, limit: 15);

      final List<dynamic> list =
          (data['docs'] as List<dynamic>?) ??
          (data['data'] as List<dynamic>?) ??
          [];
      final newNotifications = list.map((e) => NotificationModel.fromJson(e)).toList();

      _notifications.addAll(newNotifications);
      _triggerEmergencyAlerts(newNotifications);

      _totalPages =
          (data['totalPages'] as int?) ??
          (data['pages'] as int?) ??
          1;
      _hasMore = _currentPage < _totalPages && list.length == 15;
      _currentPage++;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get Unread Count
  Future<void> fetchUnreadCount() async {
    try {
      final data = await _repository.getUnreadCount();
      _unreadCount =
          data['count'] ??
          data['unread'] ??
          (data['data'] is Map ? data['data']['unread'] : 0) ??
          0;
      notifyListeners();
    } catch (e) {
      debugPrint("Failed to fetch unread count: $e");
    }
  }

  // Mark Single as Read
  Future<void> markAsRead(String id) async {
    int index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      // Optimistic update
      final oldNotification = _notifications[index];
      _notifications[index] = NotificationModel(
        id: oldNotification.id, 
        title: oldNotification.title, 
        body: oldNotification.body, 
        type: oldNotification.type, 
        referenceId: oldNotification.referenceId,
        referenceModel: oldNotification.referenceModel,
        category: oldNotification.category,
        isEmergency: oldNotification.isEmergency,
        isRead: true, 
        createdAt: oldNotification.createdAt
      );
      if (_unreadCount > 0) _unreadCount--;
      notifyListeners();

      try {
        await _repository.markAsRead(id);
      } catch (e) {
        // Revert on failure
        _notifications[index] = oldNotification;
        _unreadCount++;
        notifyListeners();
        debugPrint("Failed to mark notification as read: $e");
      }
    }
  }

  // Mark All as Read
  Future<void> markAllAsRead() async {
    // Optimistic update
    final unreadItems = _notifications.where((n) => !n.isRead).toList();
    for (int i = 0; i < _notifications.length; i++) {
        _notifications[i] = NotificationModel(
        id: _notifications[i].id, 
        title: _notifications[i].title, 
        body: _notifications[i].body, 
        type: _notifications[i].type, 
        referenceId: _notifications[i].referenceId,
        referenceModel: _notifications[i].referenceModel,
        category: _notifications[i].category,
        isEmergency: _notifications[i].isEmergency,
        isRead: true, 
        createdAt: _notifications[i].createdAt
      );
    }
    
    int oldUnreadCount = _unreadCount;
    _unreadCount = 0;
    notifyListeners();

    try {
      await _repository.markAllAsRead();
    } catch (e) {
      // Difficult to perfectly revert all without a deep clone beforehand if list is huge, 
      // but simplistic revert is to fetch again or just restore count. Best is re-fetch:
      _unreadCount = oldUnreadCount;
      fetchNotifications(refresh: true);
      debugPrint("Failed to mark all as read: $e");
    }
  }

  // FCM Token Operations
  Future<void> registerFcmToken(String token) async {
    try {
      await _repository.registerFcmToken(token);
      debugPrint("FCM token registered successfully on backend.");
    } catch (e) {
      debugPrint("Failed to register FCM token: $e");
    }
  }

  Future<void> removeFcmToken(String token) async {
    try {
      await _repository.removeFcmToken(token);
      debugPrint("FCM token removed successfully on backend.");
    } catch (e) {
      debugPrint("Failed to remove FCM token: $e");
    }
  }

  void _triggerEmergencyAlerts(List<NotificationModel> notifications) {
    for (final n in notifications) {
      if (n.isEmergency && !n.isRead && !_playedEmergencyIds.contains(n.id)) {
        _playedEmergencyIds.add(n.id);
        EmergencyAlarm.playOnce();
        break;
      }
    }
  }
}
