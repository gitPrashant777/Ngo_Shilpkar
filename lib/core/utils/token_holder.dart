/// Singleton in-memory token store.
///
/// This is the single source of truth for authentication tokens at runtime.
/// Unlike [StorageService] (which reads/writes to [FlutterSecureStorage]),
/// this class lives entirely in Dart heap memory and is available
/// instantly — no async I/O, no platform-channel round-trips, no race conditions.
///
/// Lifecycle:
///   • Set on successful login or on app-start session restore.
///   • Cleared on logout or on a 401 that cannot be recovered.
///   • [ApiClient] reads from here first, guaranteeing the token is always
///     sent when the user is authenticated.
class TokenHolder {
  // Private constructor ensures only one instance ever exists.
  TokenHolder._internal();
  static final TokenHolder _instance = TokenHolder._internal();

  /// The single global instance — access via [TokenHolder.instance] or
  /// the convenience alias [tokenHolder].
  static TokenHolder get instance => _instance;

  // ── Token fields ──────────────────────────────────────────────────────────

  /// JWT for the logged-in customer (ecommerce flow).
  String? customerToken;

  /// JWT for the logged-in admin / staff member (main app flow).
  String? adminToken;

  // ── Helpers ───────────────────────────────────────────────────────────────

  bool get hasCustomerToken =>
      customerToken != null && customerToken!.isNotEmpty;

  bool get hasAdminToken => adminToken != null && adminToken!.isNotEmpty;

  void clearCustomer() => customerToken = null;

  void clearAdmin() => adminToken = null;

  void clearAll() {
    customerToken = null;
    adminToken = null;
  }
}

/// Convenience top-level accessor — `tokenHolder.customerToken` reads cleanly.
TokenHolder get tokenHolder => TokenHolder.instance;
