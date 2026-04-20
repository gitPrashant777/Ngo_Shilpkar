import 'package:flutter/foundation.dart';
import '../../data/models/status_model.dart';
import '../../data/repository/status_repository.dart';

class StatusProvider extends ChangeNotifier {
  final StatusRepository _repository = StatusRepository();

  List<StatusModel> _statuses = [];
  bool _isLoading = false;
  String? _error;
  double _uploadProgress = 0;
  bool _isUploading = false;

  List<StatusModel> get statuses => _statuses;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get uploadProgress => _uploadProgress;
  bool get isUploading => _isUploading;

  List<StatusModel> get pinnedStatuses =>
      _statuses.where((s) => s.pinned).toList();

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  // 1️⃣ Fetch active statuses (public)
  Future<void> fetchStatuses({bool refresh = false}) async {
    if (_statuses.isNotEmpty && !refresh) return;
    _setLoading(true);
    _error = null;
    try {
      _statuses = await _repository.getActiveStatuses();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  // 2️⃣ Create status
  Future<bool> createStatuses({
    String? caption,
    required List<String> filePaths,
    List<String?>? mimeTypes,
  }) async {
    _setLoading(true);
    _error = null;
    _isUploading = true;
    _uploadProgress = 0;
    notifyListeners();
    try {
      final created = await _repository.createStatuses(
        caption: caption,
        filePaths: filePaths,
        mimeTypes: mimeTypes,
        onSendProgress: (sent, total) {
          if (total <= 0) return;
          _uploadProgress = sent / total;
          notifyListeners();
        },
      );
      if (created.isNotEmpty) {
        _statuses.insertAll(0, created);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isUploading = false;
      _uploadProgress = 0;
      _setLoading(false);
    }
  }

  // 3️⃣ Edit caption
  Future<bool> editCaption(String id, String caption) async {
    _setLoading(true);
    _error = null;
    try {
      final updated = await _repository.editCaption(id, caption);
      final idx = _statuses.indexWhere((s) => s.id == id);
      if (idx != -1) _statuses[idx] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 4️⃣ Toggle pin
  Future<bool> togglePin(String id) async {
    _error = null;
    try {
      await _repository.togglePin(id);
      // Refresh to get updated sort order
      await fetchStatuses(refresh: true);
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // 5️⃣ Delete
  Future<bool> deleteStatus(String id) async {
    _error = null;
    try {
      await _repository.deleteStatus(id);
      _statuses.removeWhere((s) => s.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // 6️⃣ Record a view impression (fire-and-forget, device-based)
  void recordView(String statusId) {
    _repository.recordView(statusId); // no await — non-blocking
  }

  // 7️⃣ Fetch live view count for a single status
  Future<int> getViewCount(String statusId) async {
    return _repository.getViewCount(statusId);
  }

  // 8️⃣ Fetch viewers list for a single status
  Future<List<Map<String, dynamic>>> getStatusViewsDetails(String statusId) async {
    return _repository.getStatusViewsDetails(statusId);
  }
}
