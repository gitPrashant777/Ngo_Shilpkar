import 'package:dio/dio.dart';
import '../utils/storage_service.dart';
import 'api_endpoints.dart';

class ApiClient {
  late final Dio dio;
  final StorageService _storage = StorageService();

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        responseType: ResponseType.json,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getToken();
          final customerToken = await _storage.getCustomerToken();

          print("🔐 TOKEN FROM STORAGE: $token");
          print("🔐 CUSTOMER TOKEN FROM STORAGE: $customerToken");

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          } else if (customerToken != null && customerToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $customerToken';
          }

          print("📡 FINAL HEADERS: ${options.headers}");

          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          print("❌ ERROR STATUS: ${e.response?.statusCode}");
          print("❌ ERROR DATA: ${e.response?.data}");

          if (e.response?.statusCode == 401 && !e.requestOptions.path.contains('login')) {
            await _storage.clearAll();
            print("⚠️ Tokens cleared (401)");
          }

          return handler.next(e);
        },
      ),
    );
  }
}
