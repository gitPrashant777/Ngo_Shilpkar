import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../../core/api/api_client.dart';
import '../models/attendance_model.dart';

class AttendanceRepository {
  final ApiClient _client = ApiClient();

  // ─── Fetch location (lat/lng + reverse geocode) ──────────────────────────
  Future<Map<String, dynamic>> _getLocationPayload() async {
    // 1. Check service enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable GPS.');
    }

    // 2. Check / request permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('location_permission_denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('location_permission_denied');
    }

    // 3. Get coordinates
    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // 4. Reverse geocode
    String district = '';
    String village = '';
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        district = place.administrativeArea ?? place.subAdministrativeArea ?? '';
        village = place.locality ?? place.subLocality ?? place.thoroughfare ?? '';
      }
    } catch (_) {
      // Geocoding failed – coordinates still valid, send empty strings
    }

    return {
      'location': {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'district': district,
        'village': village,
      }
    };
  }

  // ─── GET today's attendance ───────────────────────────────────────────────
  Future<AttendanceModel?> getTodayAttendance() async {
    try {
      final response = await _client.dio.get('/attendance', queryParameters: {
        'page': 1,
        'limit': 5,
      });

      final List<dynamic> list =
          response.data['data'] ?? response.data ?? [];

      if (list.isEmpty) return null;

      final today = DateTime.now();
      for (final item in list) {
        final model = AttendanceModel.fromJson(item);
        if (model.date.isNotEmpty) {
          try {
            final recordDate = DateTime.parse(model.date);
            if (recordDate.year == today.year &&
                recordDate.month == today.month &&
                recordDate.day == today.day) {
              return model;
            }
          } catch (_) {}
        }
        // If status is ACTIVE it must be today's active record
        if (model.status == 'ACTIVE') return model;
      }
      return null;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to fetch attendance');
    }
  }

  // ─── GET paginated attendance list ────────────────────────────────────────
  Future<Map<String, dynamic>> getAttendanceList({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _client.dio.get('/attendance', queryParameters: {
        'page': page,
        'limit': limit,
      });

      final json = response.data as Map<String, dynamic>;
      final List<dynamic> rawList = json['data'] ?? [];
      final List<AttendanceModel> records =
          rawList.map((e) => AttendanceModel.fromJson(e)).toList();

      return {
        'records': records,
        'total': json['total'] ?? 0,
        'totalPages': json['totalPages'] ?? 1,
        'page': json['page'] ?? page,
      };
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Failed to fetch attendance list');
    }
  }

  // ─── PUNCH IN ─────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> punchIn() async {
    final payload = await _getLocationPayload();
    try {
      final response =
          await _client.dio.post('/attendance/punch-in', data: payload);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Punch In Failed');
    }
  }

  // ─── PUNCH OUT ────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> punchOut() async {
    final payload = await _getLocationPayload();
    try {
      final response =
          await _client.dio.post('/attendance/punch-out', data: payload);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Punch Out Failed');
    }
  }

  // ─── SUPER_ADMIN OVERRIDE ─────────────────────────────────────────────────
  Future<void> overrideAttendance(
      String attendanceId, Map<String, dynamic> data) async {
    try {
      await _client.dio
          .patch('/attendance/override/$attendanceId', data: data);
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Override Failed');
    }
  }
}
