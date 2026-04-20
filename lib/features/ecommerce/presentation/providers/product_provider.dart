import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/ecommerce_repository.dart';

class ProductProvider extends ChangeNotifier {
  final EcommerceRepository _repository = EcommerceRepository();

  List<ProductModel> _products = [];
  List<ProductModel> _featuredProducts = [];
  bool _isLoading = false;
  String? _error;
  
  // Pagination & Filter State
  int _currentPage = 1;
  int _totalProducts = 0;
  String _searchQuery = '';
  String? _selectedCategoryId;
  bool _hasMore = true;

  List<ProductModel> get products => _products;
  List<ProductModel> get featuredProducts => _featuredProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  Future<void> fetchProducts({bool refresh = false}) async {
    print('📦 [PRODUCT PROVIDER] fetchProducts. Refresh: $refresh, categoryId: $_selectedCategoryId, page: $_currentPage');
    if (refresh) {
      _currentPage = 1;
      _products = [];
      _hasMore = true;
    }

    if (!_hasMore) {
      print('   -> No more products to fetch.');
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.getProducts(
        page: _currentPage,
        limit: 10,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        categoryId: _selectedCategoryId,
      );

      final newProducts = result['products'] as List<ProductModel>;
      final total = result['total'] as int;
      
      print('📦 [PRODUCT PROVIDER] Fetched ${newProducts.length} new products. Total in API: $total');

      if (refresh) {
        _products = newProducts;
      } else {
        _products.addAll(newProducts);
      }

      _totalProducts = total;
      _hasMore = _products.length < _totalProducts;
      if (_hasMore) _currentPage++;

    } catch (e) {
      print('❌ [PRODUCT PROVIDER ERROR] Error parsing products: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchProducts(refresh: true);
  }

  void setCategoryFilter(String? categoryId) {
    print('📦 [PRODUCT PROVIDER] setCategoryFilter -> $categoryId');
    _selectedCategoryId = categoryId;
    fetchProducts(refresh: true);
  }

  Future<void> fetchFeaturedProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      _featuredProducts = await _repository.getFeaturedProducts();
    } catch (e) {
      print("Error fetching featured products: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createProduct(Map<String, dynamic> productData) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.createProduct(productData);
      fetchProducts(refresh: true);
      fetchFeaturedProducts();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProduct(String id, Map<String, dynamic> updates) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.updateProduct(id, updates);
      fetchProducts(refresh: true);
      fetchFeaturedProducts();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.deleteProduct(id);
      fetchProducts(refresh: true);
      fetchFeaturedProducts();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<String> uploadImage(String filePath) async {
    _isLoading = true;
    notifyListeners();
    try {
      final url = await _repository.uploadImage(filePath);
      return url;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
