import 'package:flutter/material.dart';
import '../../../chat/data/models/broadcast_model.dart';
import '../../../chat/data/repository/chat_repository.dart';

class BroadcastProvider with ChangeNotifier {
  final ChatRepository _repository = ChatRepository();

  List<BroadcastModel> _broadcasts = [];
  List<BroadcastModel> _publicBroadcasts = [];
  bool _isLoading = false;
  String? _error;

  List<BroadcastModel> get broadcasts => _broadcasts;
  List<BroadcastModel> get publicBroadcasts => _publicBroadcasts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // For Admin / Super Admin
  Future<void> fetchAllBroadcasts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _broadcasts = await _repository.getBroadcasts();
      // Sort newest first
      _broadcasts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // For Beneficiary / Field / Coordinator
  Future<void> fetchPublicBroadcasts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _publicBroadcasts = await _repository.getPublicBroadcasts();
      // Sort newest first
      _publicBroadcasts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // For Admin / Super Admin
  Future<void> createBroadcast({
    required String message,
    String? category,
    List<String>? targetRoles,
    List<String>? targetCategories,
    bool isEmergency = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.createBroadcast(
        message: message,
        category: category,
        targetRoles: targetRoles,
        targetCategories: targetCategories,
        isEmergency: isEmergency,
      );
      // Refresh the list after sending
      await fetchAllBroadcasts();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateBroadcast(String id, String newMessage) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateBroadcast(id, newMessage);
      await fetchAllBroadcasts();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteBroadcast(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteBroadcast(id);
      await fetchAllBroadcasts();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> uploadEmergencySiren(String filePath) async {
    try {
      final url = await _repository.uploadEmergencySiren(filePath);
      return url;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
