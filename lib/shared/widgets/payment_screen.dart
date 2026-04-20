import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  final String title;
  final VoidCallback onPaymentSuccess;

  const PaymentScreen({
    super.key,
    required this.amount,
    required this.title,
    required this.onPaymentSuccess,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isProcessing = false;

  void _processPayment() async {
    setState(() => _isProcessing = true);
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isProcessing = false);
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Column(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 60),
              SizedBox(height: 10),
              Text("Payment Successful"),
            ],
          ),
          content: Text("You have successfully paid ₹${widget.amount}"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close Payment Screen
                widget.onPaymentSuccess();
              },
              child: const Text("OK"),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment Gateway")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.payment, size: 80, color: Color(0xFF4373AD)),
            const SizedBox(height: 20),
            Text(widget.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Amount to Pay: ₹${widget.amount}", style: const TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4373AD),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isProcessing 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Pay Now", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
