import 'package:flutter/material.dart';
import '../../data/models/homepage_model.dart';
import '../../data/repository/homepage_repository.dart';

class HomepageProvider extends ChangeNotifier {
  final HomepageRepository _repository = HomepageRepository();

  HomepageModel? homepage;
  bool isLoading = false;
  String? error;

  // ── Fetch homepage (public) ─────────────────────────────────
  Future<void> fetchHomepage() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      homepage = await _repository.getHomepage();
    } catch (e) {
      error = e.toString().replaceAll('Exception: ', '');
      debugPrint('Error fetching homepage: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Cover Image Management (SUPER_ADMIN) ────────────────────
  Future<void> uploadCoverImage(
    String filePath, {
    void Function(int, int)? onProgress,
  }) async {
    try {
      homepage = await _repository.uploadCoverImage(
        filePath,
        onProgress: onProgress,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error uploading cover image: $e');
      rethrow;
    }
  }

  Future<void> deleteCoverImage(String key) async {
    try {
      homepage = await _repository.deleteCoverImage(key);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting cover image: $e');
      rethrow;
    }
  }

  // ── Cover Video Management (SUPER_ADMIN) ────────────────────
  Future<void> uploadCoverVideo(
    String filePath, {
    void Function(int, int)? onProgress,
  }) async {
    try {
      homepage = await _repository.uploadCoverVideo(
        filePath,
        onProgress: onProgress,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error uploading cover video: $e');
      rethrow;
    }
  }

  Future<void> deleteCoverVideo(String key) async {
    try {
      homepage = await _repository.deleteCoverVideo(key);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting cover video: $e');
      rethrow;
    }
  }

  // ── Update welcome section (SUPER_ADMIN) ────────────────────
  Future<void> updateWelcomeSection({
    String? title,
    String? subtitle,
    bool? isVisible,
  }) async {
    try {
      homepage = await _repository.updateWelcomeSection(
        title: title,
        subtitle: subtitle,
        isVisible: isVisible,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating welcome section: $e');
      rethrow;
    }
  }

  // ── Helpers ─────────────────────────────────────────────────
  List<MediaModel> get coverImages => homepage?.coverImages ?? [];
  List<MediaModel> get coverVideos => homepage?.coverVideos ?? [];

  List<String> get coverImageUrls =>
      homepage?.coverImages.map((e) => e.url).toList() ?? [];

  List<String> get coverVideoUrls =>
      homepage?.coverVideos.map((e) => e.url).toList() ?? [];

  String get welcomeTitle =>
      homepage?.welcomeTitle ?? 'Welcome to Shilpkar Foundation';

  String get welcomeSubtitle =>
      homepage?.welcomeSubtitle ??
      'Empowering communities with purpose driven actions';

  bool get welcomeVisible => homepage?.welcomeVisible ?? true;
}
