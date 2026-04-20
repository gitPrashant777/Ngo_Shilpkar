import 'package:flutter/material.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/ecommerce_repository.dart';

class CategoryProvider extends ChangeNotifier {
  final EcommerceRepository _repository = EcommerceRepository();

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _categories = await _repository.getCategories();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createCategory(String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.createCategory(name);
      await fetchCategories(); // Refresh list
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCategory(String id, String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.updateCategory(id, name);
      await fetchCategories(); // Refresh list
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCategory(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.deleteCategory(id);
      await fetchCategories(); // Refresh list
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
