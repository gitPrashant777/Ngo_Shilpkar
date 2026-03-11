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
          // Allow specific requests to bypass auth entirely.
          // Used for guest job applications where sending a stale customer
          // token would cause the NGO backend to return "User not found".
          if (options.extra['skipAuth'] == true) {
            return handler.next(options);
          }

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

          final path = e.requestOptions.path;
          final isLoginPath = path.contains('login');
          // Only auto-clear the token if the 401 comes from a true session
          // check (profile/me, auth routes). Do NOT clear on business-logic
          // errors like 'User not found' from /apply or /uploads — those are
          // data errors, not authentication failures, and clearing the token
          // would leave the next retry with "No token provided".
          final isSessionCheck = path.contains('/profile/me') ||
              path.contains('/auth/') ||
              path.contains('/onboarding/status');

          if (e.response?.statusCode == 401 && !isLoginPath && isSessionCheck) {
            final tokenType = e.requestOptions.extra['tokenType'];
            if (tokenType == 'customer') {
              tokenHolder.clearCustomer();
              print("⚠️  Customer token cleared from memory (401 on session route)");
            } else if (tokenType == 'admin') {
              tokenHolder.clearAdmin();
              print("⚠️  Admin token cleared from memory (401 on session route)");
            }
          }

          return handler.next(e);
        },
      ),
    );
  }
}

