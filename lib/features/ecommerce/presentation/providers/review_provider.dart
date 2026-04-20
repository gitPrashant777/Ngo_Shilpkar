import 'package:flutter/material.dart';
import '../../data/models/review_model.dart';
import '../../data/repositories/ecommerce_repository.dart';

class ReviewProvider extends ChangeNotifier {
  final EcommerceRepository _repository = EcommerceRepository();

  List<ReviewModel> _reviews = [];
  bool _isLoading = false;
  String? _error;

  List<ReviewModel> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchReviews(String productId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _reviews = await _repository.getReviews(productId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createReview(Map<String, dynamic> reviewData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.createReview(reviewData);
      // Refresh reviews if productId is in reviewData
      if (reviewData.containsKey('productId')) {
        await fetchReviews(reviewData['productId']);
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteReview(String id, String productId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.deleteReview(id);
      await fetchReviews(productId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
