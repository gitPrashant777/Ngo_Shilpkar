import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalJobDataStorage {
  static const String _key = 'localJobData';
  static const String _applicationIdKey = 'lastApplicationId';

  // ── Profile / application form data ───────────────────────────────────────
  static Future<void> saveJobData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(data));
  }

  static Future<Map<String, dynamic>?> getJobData() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_key);
    if (str != null) return jsonDecode(str);
    return null;
  }

  static Future<void> clearJobData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  // ── Application ID (returned by backend after submit) ─────────────────────
  static Future<void> saveApplicationId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_applicationIdKey, id);
  }

  static Future<String?> getApplicationId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_applicationIdKey);
  }

  static Future<void> clearApplicationId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_applicationIdKey);
  }
}
