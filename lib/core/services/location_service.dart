import 'package:geolocator/geolocator.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();

  factory LocationService() {
    return _instance;
  }

  LocationService._internal();

  /// Gets current location and resolves it via API
  /// Returns a map with state, district, taluka, village, address, postalCode, latitude, longitude
  /// or throws an error.
  Future<Map<String, dynamic>> detectAndResolveLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable them in your device settings.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final apiClient = ApiClient();
    final response = await apiClient.dio.post(
      ApiEndpoints.baseUrl + '/location/resolve',
      data: {
        'latitude': position.latitude,
        'longitude': position.longitude,
      },
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      dynamic rawData = response.data['data'];
      Map<String, dynamic>? data;

      if (rawData is List && rawData.isNotEmpty) {
        data = rawData.first;
      } else if (rawData is Map<String, dynamic>) {
        data = rawData;
      }

      if (data != null) {
        // Add latitude and longitude to the result map
        data['latitude'] = position.latitude;
        data['longitude'] = position.longitude;

        // Generate autoAddress if not present
        String autoAddress = data['address'] ?? data['display_name'] ?? "";
        if (autoAddress.isEmpty) {
          List<String> parts = [];
          if (data['village'] != null) parts.add(data['village']);
          if (data['taluka'] != null) parts.add(data['taluka']);
          if (data['district'] != null) parts.add(data['district']);
          if (data['state'] != null) parts.add(data['state']);
          if (data['postalCode'] != null) parts.add(data['postalCode'].toString());
          autoAddress = parts.join(", ");
        }
        data['autoAddress'] = autoAddress;

        return data;
      } else {
        throw Exception('Invalid location data received');
      }
    } else {
      throw Exception(response.data['message'] ?? 'Failed to resolve location');
    }
  }
}
