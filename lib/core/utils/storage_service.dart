import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final _storage = const FlutterSecureStorage();

  static const String _tokenKey = 'jwt_token';
  static const String _roleKey = 'user_role';
  static const String _usernameKey = 'username';

  Future<void> saveAuthData({
    required String token,
    required String role,
    required String identifier, // email or username
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _roleKey, value: role);
    await _storage.write(key: _usernameKey, value: identifier);
  }

  Future<String?> getToken() async => await _storage.read(key: _tokenKey);
  Future<String?> getRole() async => await _storage.read(key: _roleKey);

  Future<void> clearAll() async => await _storage.deleteAll();
}