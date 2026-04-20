import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayService {
  late Razorpay _razorpay;

  final Function(PaymentSuccessResponse) onSuccess;
  final Function(PaymentFailureResponse) onError;
  final Function(ExternalWalletResponse) onExternalWallet;

  RazorpayService({
    required this.onSuccess,
    required this.onError,
    required this.onExternalWallet,
  }) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);
  }

  void openCheckout({
    required String key,
    required double amount, // in paisa
    required String orderId,
    required String name,
    required String description,
    String? userMobile,
    String? userEmail,
  }) {
    var options = {
      'key': key,
      'amount': amount.toInt(), // ensure it's an integer
      'currency': 'INR', // Added currency
      'name': name,
      'order_id': orderId,
      'description': description,
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': false,
    };

    final Map<String, String> prefill = {};
    if (userMobile != null && userMobile.isNotEmpty) prefill['contact'] = userMobile;
    if (userEmail != null && userEmail.isNotEmpty) prefill['email'] = userEmail;
    
    if (prefill.isNotEmpty) {
      options['prefill'] = prefill;
    }

    try {
      print("🚀 RAZORPAY OPTIONS: $options");
      _razorpay.open(options);
    } catch (e) {
      print("Error opening Razorpay: $e");
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}
