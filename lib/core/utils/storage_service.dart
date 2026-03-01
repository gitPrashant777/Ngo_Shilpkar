import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final _storage = const FlutterSecureStorage();

  static const String _tokenKey = 'jwt_token';
  static const String _roleKey = 'user_role';
  static const String _identifierKey = 'user_identifier';
  static const String _userIdKey = 'user_id';

  // Cache Keys
  static const String _homepageCacheKey = 'homepage_cache';
  static const String _jobCacheKey = 'job_cache';
  static const String _schemeCacheKey = 'scheme_cache';
  static const String _productCacheKey = 'product_cache';

  Future<void> saveAuthData({
    required String token,
    required String role,
    required String identifier,
    required String userId,
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _roleKey, value: role);
    await _storage.write(key: _identifierKey, value: identifier);
    await _storage.write(key: _userIdKey, value: userId);
  }

  Future<String?> getToken() async => await _storage.read(key: _tokenKey);
  Future<String?> getRole() async => await _storage.read(key: _roleKey);
  Future<String?> getUserId() async => await _storage.read(key: _userIdKey);

  // Generic Cache Methods
  Future<void> saveCache(String key, String data) async => await _storage.write(key: key, value: data);
  Future<String?> getCache(String key) async => await _storage.read(key: key);

  // Computed properties for specific keys to avoid typos elsewhere
  String get homepageCacheKey => _homepageCacheKey;
  String get jobCacheKey => _jobCacheKey;
  String get schemeCacheKey => _schemeCacheKey;
  String get productCacheKey => _productCacheKey;

  // ─── Customer Token for Ecommerce ─────────────────────────────────────────
  // Static in-memory cache: shared across all StorageService instances.
  // Eliminates the FlutterSecureStorage write→read race condition on Android
  // (EncryptedSharedPreferences doesn't guarantee instant cross-instance read
  // visibility after a write).
  static const String _customerTokenKey = 'customer_token';
  static String? _customerTokenCache; // in-memory cache

  Future<void> saveCustomerToken(String token) async {
    _customerTokenCache = token; // cache first — available immediately
    await _storage.write(key: _customerTokenKey, value: token);
  }

  Future<String?> getCustomerToken() async {
    // Return in-memory cache if available (avoids storage race on Android)
    if (_customerTokenCache != null) return _customerTokenCache;
    // Cold start: read from persisted storage and populate cache
    final stored = await _storage.read(key: _customerTokenKey);
    _customerTokenCache = stored;
    return stored;
  }

  Future<void> clearCustomerToken() async {
    _customerTokenCache = null; // clear cache immediately
    await _storage.delete(key: _customerTokenKey);
  }

  Future<void> clearAll() async {
    _customerTokenCache = null; // clear in-memory cache
    // Only clear auth data, preserve cache for guest usage
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _roleKey);
    await _storage.delete(key: _identifierKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _customerTokenKey);
  }
}
