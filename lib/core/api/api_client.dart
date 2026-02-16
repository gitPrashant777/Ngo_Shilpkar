import 'package:dio/dio.dart';
import '../utils/storage_service.dart';
import 'api_endpoints.dart';

class ApiClient {
  late Dio dio;
  final StorageService _storage = StorageService();

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        responseType: ResponseType.json,
      ),
    );

    // Request Interceptor for JWT
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            // Logic to logout user if token expires
          }
          return handler.next(e);
        },
      ),
    );
  }
}