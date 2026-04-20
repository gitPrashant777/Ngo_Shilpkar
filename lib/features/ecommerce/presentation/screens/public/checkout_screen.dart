import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../../../core/config/razorpay_config.dart';
import '../../../../../core/services/razorpay_service.dart';
import '../../providers/customer_auth_provider.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/product_model.dart';
import '../../providers/order_provider.dart';
import 'customer_login_screen.dart';
import '../../../../../core/services/location_service.dart';

class CheckoutScreen extends StatefulWidget {
  final ProductModel? product;
  final int? quantity;
  final List<CartItem>? cartItems;

  const CheckoutScreen({
    super.key,
    this.product,
    this.quantity,
    this.cartItems,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late RazorpayService _razorpayService;
  final _formKey = GlobalKey<FormState>();
  
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  bool _isProcessing = false;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _razorpayService = RazorpayService(
      onSuccess: _handlePaymentSuccess,
      onError: _handlePaymentError,
      onExternalWallet: _handleExternalWallet,
    );
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _detectLocation() async {
    setState(() => _isLocating = true);
    try {
      final locData = await LocationService().detectAndResolveLocation();
      setState(() {
        _stateController.text = locData['state'] ?? _stateController.text;
        _cityController.text = locData['district'] ?? _cityController.text;
        _pincodeController.text = locData['postalCode']?.toString() ?? _pincodeController.text;
        
        List<String> streetParts = [];
        if (locData['village'] != null) streetParts.add(locData['village']);
        if (locData['taluka'] != null) streetParts.add(locData['taluka']);
        if (streetParts.isNotEmpty && _streetController.text.isEmpty) {
          _streetController.text = streetParts.join(", ");
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Address fetched automatically!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to detect location: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (!mounted) return;
    
    // As per requirement: "After successful payment Frontend does NOT call backend. Webhook handles everything."
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment Successful! Order Confirmed."), backgroundColor: Colors.green),
    );
    
    // Just refresh the orders list in background so MyOrders has it
    Provider.of<OrderProvider>(context, listen: false).fetchMyOrders();
    
    Navigator.pop(context); // Go back usually to Cart or Product
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: ${response.message}")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("External Wallet: ${response.walletName}")),
    );
  }

  // ignore: unused_element
  Future<void> _startCheckout() async {
    if (!_formKey.currentState!.validate()) return;

    // Read providers synchronously before any await (satisfies lint rule)
    final auth = context.read<CustomerAuthProvider>();
    final customer = auth.currentCustomer;
    final orderProvider = context.read<OrderProvider>();

    // ── Auth guard
    if (!auth.isAuthenticated) {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const CustomerLoginScreen()),
      );
      if (result != true || !mounted) return;
    }

    final address = OrderAddress(
      street: _streetController.text,
      city: _cityController.text,
      state: _stateController.text,
      pincode: _pincodeController.text,
    );

    setState(() => _isProcessing = true);

    try {
      Map<String, dynamic> razorpayData;
      String description = "";

      if (widget.cartItems != null && widget.cartItems!.isNotEmpty) {
        final firstItem = widget.cartItems!.first;
        razorpayData = await orderProvider.createSingleOrder(
          firstItem.product,
          firstItem.quantity,
          address,
        );
        description = "Cart Checkout (${widget.cartItems!.length} items)";
      } else {
        razorpayData = await orderProvider.createSingleOrder(
          widget.product!,
          widget.quantity!,
          address,
        );
        description = widget.product!.name;
      }

      // Customer contact info for Razorpay (already read before await)
      final userMobile = customer?.mobile ?? '';
      final userEmail = customer?.email ?? '';

      // Backend returns amount in RUPEES — Razorpay needs PAISE
      final double amountInPaise =
          ((razorpayData['amount'] as num).toDouble()) * 100;

      final String rzpKey = RazorpayConfig.extractAndUpdateKey(razorpayData);

      _razorpayService.openCheckout(
        key: rzpKey,
        amount: amountInPaise,
        orderId: razorpayData['razorpayOrderId'],
        name: 'Shilpkar Store',
        description: description,
        userMobile: userMobile,
        userEmail: userEmail,
      );
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _bypassPayment() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<CustomerAuthProvider>();
    final orderProvider = context.read<OrderProvider>();

    if (!auth.isAuthenticated) {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const CustomerLoginScreen()),
      );
      if (result != true || !mounted) return;
    }

    final address = OrderAddress(
      street: _streetController.text,
      city: _cityController.text,
      state: _stateController.text,
      pincode: _pincodeController.text,
    );

    setState(() => _isProcessing = true);

    try {
      if (widget.cartItems != null && widget.cartItems!.isNotEmpty) {
        final firstItem = widget.cartItems!.first;
        await orderProvider.createSingleOrder(
          firstItem.product,
          firstItem.quantity,
          address,
        );
      } else {
        await orderProvider.createSingleOrder(
          widget.product!,
          widget.quantity!,
          address,
        );
      }

      setState(() => _isProcessing = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Demo Pass: Order Created without actual Payment!"),
            backgroundColor: Colors.green,
          ),
        );

        // Clear cart if applicable
        if (widget.cartItems != null) {
          orderProvider.clearCart();
        }
        
        // Refresh orders 
        orderProvider.fetchMyOrders();
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double total = 0;
    if (widget.cartItems != null) {
      for (var item in widget.cartItems!) {
        total += item.totalPrice;
      }
    } else if (widget.product != null && widget.quantity != null) {
      total = widget.product!.price * widget.quantity!;
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      if (widget.cartItems != null)
                        ...widget.cartItems!.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text("x${item.quantity}"),
                            ],
                          ),
                        ))
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(widget.product?.name ?? "", style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text("x${widget.quantity}"),
                          ],
                        ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total Amount", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text("₹$total", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Shipping Address", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  _isLocating
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : TextButton.icon(
                          onPressed: _detectLocation,
                          icon: const Icon(Icons.my_location, size: 16),
                          label: const Text("Auto Detect", style: TextStyle(fontSize: 13)),
                        ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _streetController,
                decoration: const InputDecoration(labelText: "Street Address", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: "City", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stateController,
                      decoration: const InputDecoration(labelText: "State", border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _pincodeController,
                      decoration: const InputDecoration(labelText: "Pincode", border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // --- ORIGINAL PAYMENT BUTTON (DISABLED FOR DEMO) ---
              // SizedBox(
              //   width: double.infinity,
              //   height: 50,
              //   child: ElevatedButton(
              //     onPressed: _isProcessing ? null : _startCheckout,
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: const Color(0xFF4373AD),
              //       foregroundColor: Colors.white,
              //     ),
              //     child: _isProcessing 
              //         ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              //         : const Text("PAY NOW", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              //   ),
              // ),
              // const SizedBox(height: 12),
              // ---------------------------------------------------
              
              // --- BYPASS PAYMENT BUTTON (DEMO) ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _bypassPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4373AD), // Primary color
                    foregroundColor: Colors.white,
                  ),
                  child: _isProcessing 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("DEMO: COMPLETE ORDER", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
