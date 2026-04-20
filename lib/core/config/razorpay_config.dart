/// Global Razorpay configuration.
/// The Razorpay Key ID is strictly hardcoded to ensure it always matches
/// the backend's .env file.
class RazorpayConfig {
  RazorpayConfig._();

  static const String _keyId = 'rzp_test_SHTwJN4z94DatM';

  /// The Razorpay Key ID to use for all Razorpay checkouts.
  static String get keyId => _keyId;

  /// Disabled updating key dynamically as we strictly enforce the correct key.
  static void updateKey(String? keyFromServer) {
    // Disabled intentionally to prevent backend misconfigurations
    // from overriding the correct key.
  }

  /// Extract the key from any payment data map and update global config.
  /// Now it just strictly returns the hardcoded key.
  static String extractAndUpdateKey(Map<String, dynamic> data) {
    return _keyId;
  }
}
