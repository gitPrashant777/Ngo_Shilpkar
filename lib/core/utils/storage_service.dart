import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final _storage = const FlutterSecureStorage();

  static const String _tokenKey = 'jwt_token';
  static const String _roleKey = 'user_role';
  static const String _identifierKey = 'user_identifier';

  Future<void> saveAuthData({
    required String token,
    required String role,
    required String identifier,
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _roleKey, value: role);
    await _storage.write(key: _identifierKey, value: identifier);
  }

  Future<String?> getToken() async =>
      await _storage.read(key: _tokenKey);

  Future<String?> getRole() async =>
      await _storage.read(key: _roleKey);

  Future<void> clearAll() async =>
      await _storage.deleteAll();
}
