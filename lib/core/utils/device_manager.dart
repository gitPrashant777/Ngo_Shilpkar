import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Generates and persists a unique device ID for anonymous tracking
/// (used for status view impressions without requiring a user account).
class DeviceManager {
  static late String deviceId;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('deviceId')) {
      await prefs.setString('deviceId', const Uuid().v4());
    }
    deviceId = prefs.getString('deviceId')!;
    _initialized = true;
  }
}
