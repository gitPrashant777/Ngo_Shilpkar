import 'package:flutter/material.dart';
import '../../data/models/order_model.dart';
import '../../data/models/product_model.dart';
import '../../data/models/return_request_model.dart';
import '../../data/repositories/ecommerce_repository.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalPrice => product.price * quantity;
}

class OrderProvider extends ChangeNotifier {
  final EcommerceRepository _repository = EcommerceRepository();

  // Cart State
  final Map<String, CartItem> _cartItems = {};
  Map<String, CartItem> get cartItems => _cartItems;
  
  double get cartTotal {
    double total = 0;
    _cartItems.forEach((key, item) {
      total += item.totalPrice;
    });
    return total;
  }

  int get cartCount => _cartItems.length;

  // Order State
  List<OrderModel> _myOrders = [];
  List<OrderModel> _allOrders = []; // Admin
  List<ReturnRequestModel> _returnRequests = []; // Admin
  bool _isLoading = false;
  String? _error;

  List<OrderModel> get myOrders => _myOrders;
  List<OrderModel> get allOrders => _allOrders;
  List<ReturnRequestModel> get returnRequests => _returnRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ---------------------------------------------------------------------------
  // CART METHODS
  // ---------------------------------------------------------------------------

  void addToCart(ProductModel product) {
    if (_cartItems.containsKey(product.id)) {
      _cartItems[product.id]!.quantity += 1;
    } else {
      _cartItems[product.id] = CartItem(product: product);
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cartItems.remove(productId);
    notifyListeners();
  }

  void updateCartQuantity(String productId, int quantity) {
    if (!_cartItems.containsKey(productId)) return;
    
    if (quantity <= 0) {
      removeFromCart(productId);
    } else {
      _cartItems[productId]!.quantity = quantity;
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // ORDER METHODS
  // ---------------------------------------------------------------------------

  Future<void> checkout(OrderAddress address) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Create an order for each item in the cart
      // API currently supports creating one order at a time
      // TODO: Wrap in a batch transaction if API supports it later
      
      for (var item in _cartItems.values) {
        final orderData = {
          'productId': item.product.id,
          'quantity': item.quantity,
          'address': address.toJson(),
        };
        await _repository.createOrder(orderData);
      }
      
      clearCart();
      await fetchMyOrders(); // Refresh orders list

    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> createSingleOrder(ProductModel product, int quantity, OrderAddress address) async {
      _isLoading = true;
      _error = null;
      notifyListeners();

      try {
        final orderData = {
          'productId': product.id,
          'quantity': quantity,
          'address': address.toJson(),
        };
        final result = await _repository.createOrder(orderData);
        await fetchMyOrders();
        return result;
      } catch (e) {
        _error = e.toString();
        rethrow;
      } finally {
        _isLoading = false;
        notifyListeners();
      }
  }

  Future<Map<String, dynamic>> createReturnRequest(String orderId, String type, String reason) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _repository.createReturnRequest(orderId, type, reason);
      await fetchMyOrders();
      return result;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchReturnRequests() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _repository.getPaymentRefunds();
      final List data = res['data'] ?? [];
      _returnRequests = data.map((e) => ReturnRequestModel.fromJson(e)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> approveReturn(String id, {String? adminNotes}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.approvePaymentRefund(id, adminNotes: adminNotes);
      await fetchReturnRequests();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _myOrders = await _repository.getMyOrders();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _allOrders = await _repository.getAllOrders();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> updateOrderStatus(String id, String status) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _repository.updateOrderStatus(id, status);
      await fetchAllOrders(); // Refresh admin list
      return result;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelOrder(String orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.cancelOrder(orderId);
      await fetchMyOrders();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> rejectReturn(String id, String remark) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.rejectPaymentRefund(id, remark);
      await fetchReturnRequests();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retryRefund(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.retryPaymentRefund(id);
      await fetchReturnRequests();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ReturnRequestModel?> getRefundRequestById(String id) async {
    try {
      final data = await _repository.getPaymentRefundById(id);
      if (data == null) return null;
      return ReturnRequestModel.fromJson(data);
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }
}
