import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/config/razorpay_config.dart';
import '../../../../core/utils/storage_service.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/review_model.dart';

class EcommerceRepository {
  final Dio _dio = ApiClient().dio;

  // ============================================================
  // CUSTOMER AUTHENTICATION
  // ============================================================

  Future<Map<String, dynamic>> customerLogin(String email, String password) async {
    try {
      final response = await _dio.post('/customers/login', data: {
        'email': email,
        'password': password,
      });
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Login failed");
    }
  }

  Future<Map<String, dynamic>> customerRegister(String name, String email, String password, String mobile) async {
    try {
      final response = await _dio.post('/customers/register', data: {
        'fullName': name,
        'email': email,
        'password': password,
        'mobile': mobile,
      });
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Registration failed");
    }
  }

  Future<Map<String, dynamic>> customerGoogleLogin(String idToken) async {
    try {
      final response = await _dio.post(
        '/customers/google-login',
        data: {'idToken': idToken},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Google login failed");
    }
  }

  Future<Map<String, dynamic>> getCustomerProfile() async {
    try {
      final response = await _dio.get('/customers/me');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Failed to fetch profile");
    }
  }

  /// Fetches the customer profile using a token passed directly in memory.
  /// Use this immediately after login to avoid the FlutterSecureStorage
  /// write→read race condition on Android where a freshly-saved token
  /// may not be immediately visible to a new read from a separate instance.
  Future<Map<String, dynamic>> getCustomerProfileWithToken(String token) async {
    try {
      final response = await _dio.get(
        '/customers/me',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? "Failed to fetch profile");
    }
  }


  // ============================================================
  // CATEGORIES
  // ============================================================

  static const String _categoryCacheKey = 'category_cache';

  Future<List<CategoryModel>> getCategories() async {
    final StorageService storage = StorageService();
    try {
      final response = await _dio.get('/categories');

      final List data = response.data['data'] ?? [];
      
      return data.map((e) => CategoryModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Failed to fetch categories");
    }
  }
// ---------------------------------------------------------------------------
// ADMIN - GET ALL ORDERS
// ---------------------------------------------------------------------------

  Future<List<OrderModel>> getAllOrders({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/orders',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200 &&
          response.data['success'] == true) {
        final raw = response.data['data'];
        List dataList;
        if (raw is Map) {
          dataList = raw['data'] ?? [];
        } else if (raw is List) {
          dataList = raw;
        } else {
          dataList = [];
        }

        return dataList
            .map((json) => OrderModel.fromJson(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      final message =
          e.response?.data?["message"] ?? "Failed to fetch orders";
      throw Exception(message);
    }
  }

  Future<void> createCategory(String name) async {
    try {
      await _dio.post('/categories', data: {"name": name});
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Failed to create category");
    }
  }

  Future<void> updateCategory(String id, String name) async {
    try {
      await _dio.patch('/categories/$id', data: {"name": name});
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Failed to update category");
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _dio.delete('/categories/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Failed to delete category");
    }
  }

  // ============================================================
  // PRODUCTS
  // ============================================================

  Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int limit = 10,
    String? search,
    String? categoryId,
  }) async {
    final StorageService storage = StorageService();
    try {
      print('🌐 [ECOMMERCE REPO] Calling /products GET API');
      print('   -> page: $page, limit: $limit, search: $search, categoryId: $categoryId');

      final response = await _dio.get(
        '/products',
        queryParameters: {
          "page": page,
          "limit": limit,
          if (search != null) "search": search,
          if (categoryId != null) "categoryId": categoryId,
        },
      );

      print('🌐 [ECOMMERCE REPO] /products API Response StatusCode: ${response.statusCode}');

      final List data = response.data['data'] ?? [];
      final result = {
        "products": data.map((e) => ProductModel.fromJson(e)).toList(),
        "total": response.data['total'] ?? 0,
      };
      
      print('🌐 [ECOMMERCE REPO] Extracted ${result["products"].length} products. Total from API: ${result["total"]}');

      return result;
    } on DioException catch (e) {
      print('❌ [ECOMMERCE REPO ERROR] Exception fetching products: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? "Failed to fetch products");
    }
  }

  Future<ProductModel> getProductById(String id) async {
    try {
      final response = await _dio.get('/products/$id');
      final data = response.data['data'];
      return ProductModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Failed to fetch product details");
    }
  }

  Future<List<ProductModel>> getFeaturedProducts() async {
    final StorageService storage = StorageService();
    try {
      final response = await _dio.get('/products/featured');

      final List data = response.data['data'] ?? [];
      
      return data.map((e) => ProductModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Failed to fetch featured products");
    }
  }

  Future<void> createProduct(Map<String, dynamic> productData) async {
    try {
      await _dio.post('/products', data: productData);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Failed to create product");
    }
  }

  Future<void> updateProduct(String id, Map<String, dynamic> updates) async {
    try {
      await _dio.patch('/products/$id', data: updates);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Failed to update product");
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _dio.delete('/products/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Failed to delete product");
    }
  }

  // ============================================================
  // ORDERS
  // ============================================================

  /// 1️⃣ CREATE ORDER (Returns Razorpay data)
  Future<Map<String, dynamic>> createOrder(
      Map<String, dynamic> orderData) async {
    try {
      final response = await _dio.post('/orders', data: orderData);
      final data = response.data['data'] as Map<String, dynamic>;
      // Cache the Razorpay key globally so other modules can use it
      RazorpayConfig.extractAndUpdateKey(data);
      print('🔑 [ECOMMERCE] Razorpay key from server: ${data["key"]}');
      return data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Failed to create order");
    }
  }

  /// 2️⃣ GET MY ORDERS
  Future<List<OrderModel>> getMyOrders() async {
    try {
      final response = await _dio.get('/orders/my');

      // Backend returns { success, data: { page, limit, total, data: [...orders] } }
      // OR { success, data: [...orders] } — handle both
      final raw = response.data['data'];
      List dataList;
      if (raw is Map) {
        dataList = raw['data'] ?? [];
      } else if (raw is List) {
        dataList = raw;
      } else {
        dataList = [];
      }
      return dataList.map((e) => OrderModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Failed to fetch my orders");
    }
  }

  /// 3️⃣ CANCEL ORDER (BEFORE PAYMENT CAPTURE)
  Future<void> cancelOrder(String orderId) async {
    try {
      await _dio.patch('/orders/$orderId/cancel');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Order cannot be cancelled");
    }
  }

  /// 4️⃣ ADMIN UPDATE ORDER STATUS – returns response data (deliveredAt, refundExpiryAt, etc.)
  Future<Map<String, dynamic>> updateOrderStatus(
      String orderId, String status) async {
    try {
      final response = await _dio.patch(
        '/orders/$orderId/status',
        data: {"status": status},
      );
      return (response.data['data'] as Map<String, dynamic>?) ?? {};
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Failed to update order status");
    }
  }

  // ============================================================
  // RETURN REQUESTS
  // ============================================================

  /// CREATE RETURN REQUEST – returns the created request data
  Future<Map<String, dynamic>> createReturnRequest(
      String orderId,
      String type,
      String reason) async {
    try {
      final response = await _dio.post(
        '/return-requests/$orderId',
        data: {
          "type": type,
          "reason": reason,
        },
      );
      return (response.data['data'] as Map<String, dynamic>?) ?? {};
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Failed to create return request");
    }
  }

  /// ADMIN LIST RETURNS
  Future<Map<String, dynamic>> getReturnRequests({
    int page = 1,
    int limit = 10,
    String? status,
    String? type,
  }) async {
    try {
      final response = await _dio.get(
        '/return-requests',
        queryParameters: {
          "page": page,
          "limit": limit,
          if (status != null) "status": status,
          if (type != null) "type": type,
        },
      );

      // Backend returns { success, page, limit, total, totalPages, data: [...] }
      // Normalize to always have a 'data' key that is a List
      final responseData = response.data as Map<String, dynamic>;
      final rawData = responseData['data'];
      List dataList;
      if (rawData is List) {
        dataList = rawData;
      } else if (rawData is Map) {
        dataList = rawData['data'] ?? [];
      } else {
        dataList = [];
      }
      return {
        ...responseData,
        'data': dataList,
      };
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Failed to fetch return requests");
    }
  }

  /// ADMIN APPROVE RETURN
  Future<void> approveReturn(String id) async {
    try {
      await _dio.patch('/return-requests/$id/approve');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Failed to approve return");
    }
  }

  /// ADMIN REJECT RETURN
  Future<void> rejectReturn(String id, String remark) async {
    try {
      await _dio.patch(
        '/return-requests/$id/reject',
        data: {"adminRemark": remark},
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Failed to reject return");
    }
  }

  /// ADMIN RETRY REFUND
  Future<void> retryRefund(String id) async {
    try {
      await _dio.patch('/return-requests/$id/retry');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Failed to retry refund");
    }
  }

  // ============================================================
  // PAYMENT REFUNDS (Refund Queries)
  // ============================================================

  Future<Map<String, dynamic>> getPaymentRefunds({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/payment-refunds',
        queryParameters: {
          "page": page,
          "limit": limit,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Failed to fetch refund requests");
    }
  }

  Future<Map<String, dynamic>?> getPaymentRefundById(String id) async {
    try {
      final response = await _dio.get('/payment-refunds/$id');
      final data = response.data['data'];
      if (data is Map<String, dynamic>) return data;
      return null;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Failed to fetch refund request");
    }
  }

  Future<void> approvePaymentRefund(String id, {String? adminNotes}) async {
    try {
      await _dio.patch(
        '/payment-refunds/$id/approve',
        data: {
          if (adminNotes != null && adminNotes.isNotEmpty)
            "adminNotes": adminNotes,
        },
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Failed to approve refund");
    }
  }

  Future<void> rejectPaymentRefund(String id, String adminNotes) async {
    try {
      await _dio.patch(
        '/payment-refunds/$id/reject',
        data: {"adminNotes": adminNotes},
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Failed to reject refund");
    }
  }

  Future<void> retryPaymentRefund(String id) async {
    try {
      await _dio.patch('/payment-refunds/$id/retry');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Failed to retry refund");
    }
  }

  // ============================================================
  // REVIEWS
  // ============================================================

  Future<List<ReviewModel>> getReviews(String productId) async {
    try {
      final response = await _dio.get('/reviews/$productId');

      final List data = response.data['data'] ?? [];
      return data.map((e) => ReviewModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Failed to fetch reviews");
    }
  }

  Future<void> createReview(Map<String, dynamic> reviewData) async {
    try {
      await _dio.post('/reviews', data: reviewData);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Failed to create review");
    }
  }

  Future<void> deleteReview(String id) async {
    try {
      await _dio.delete('/reviews/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Failed to delete review");
    }
  }
  // ============================================================
  // UPLOADS
  // ============================================================

  Future<String> uploadImage(String filePath) async {
    try {
      String fileName = filePath.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(filePath, filename: fileName),
        "module": "products", // Optional: categorize uploads
      });

      final response = await _dio.post(
        '/uploads',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['url'];
      } else {
        throw Exception("Failed to upload image");
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Failed to upload image");
    }
  }
}
