import 'package:dio/dio.dart';
import 'package:shilpkar/core/utils/token_holder.dart';
import 'api_endpoints.dart';


class ApiClient {
  late final Dio dio;

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
        onRequest: (options, handler) {
          // Read tokens from in-memory TokenHolder — zero async I/O, no race condition
          final adminToken = tokenHolder.adminToken;
          final customerToken = tokenHolder.customerToken;

          print("🔐 ADMIN TOKEN (memory):    ${adminToken != null ? '[SET]' : 'null'}");
          print("🔐 CUSTOMER TOKEN (memory): ${customerToken != null ? '[SET]' : 'null'}");

          // Admin token takes priority (admin may also shop)
          if (adminToken != null && adminToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $adminToken';
            options.extra['tokenType'] = 'admin';
          } else if (customerToken != null && customerToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $customerToken';
            options.extra['tokenType'] = 'customer';
          }

          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          print("❌ ERROR STATUS: ${e.response?.statusCode}");
          print("❌ ERROR DATA:   ${e.response?.data}");

          if (e.response?.statusCode == 401 &&
              !e.requestOptions.path.contains('login')) {
            final tokenType = e.requestOptions.extra['tokenType'];
            if (tokenType == 'customer') {
              tokenHolder.clearCustomer();
              print("⚠️  Customer token cleared from memory (401)");
            } else if (tokenType == 'admin') {
              tokenHolder.clearAdmin();
              print("⚠️  Admin token cleared from memory (401)");
            }
          }

          return handler.next(e);
        },
      ),
    );
  }
}

