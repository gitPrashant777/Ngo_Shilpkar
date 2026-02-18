import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';

class HomeRepository {
  final Dio _dio = ApiClient().dio;

  Future<Map<String, dynamic>> getHomepage() async {
    final response = await _dio.get("/homepage");
    return response.data;
  }
}
