import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../../../../../core/constants/app_colors.dart';
import 'checkout_screen.dart';
import 'checkout_screen.dart';
import '../../providers/customer_auth_provider.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';
import 'customer_login_screen.dart';


class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: const Text("My Cart"),
        backgroundColor: AppColors.appBarBlue,
        foregroundColor: Colors.white,
      ),
      body: Consumer<OrderProvider>(
        builder: (context, provider, _) {
          if (provider.cartItems.isEmpty) {
            return const Center(child: Text("Your cart is empty"));
          }

          final cartItems = provider.cartItems.values.toList();

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            // IMAGE
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: item.product.images.isNotEmpty
                                  ? Image.network(
                                      item.product.images.first,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.image_not_supported),
                                    )
                                  :Container(
                                color: Colors.grey.shade200,
                                width: 60,
                                height: 60,
                                child: const Icon(Icons.shopping_bag),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // INFO
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    "₹${item.product.price} x ${item.quantity}",
                                    style: const TextStyle(
                                        color: Colors.green, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            // ACTIONS
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
                                  onPressed: () {
                                     provider.updateCartQuantity(item.product.id, item.quantity - 1);
                                  },
                                ),
                                Text("${item.quantity}"),
                                IconButton(
                                  icon: const Icon(Icons.add_circle, color: Colors.green),
                                  onPressed: () {
                                     provider.updateCartQuantity(item.product.id, item.quantity + 1);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // TOTAL SECTION
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -4))],
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Amount",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("₹${provider.cartTotal}",
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                           // Use in-memory auth — no race condition
                           final auth = context.read<CustomerAuthProvider>();
                           final mainAuth = context.read<AuthProvider>();
                           if (!auth.isAuthenticated && !mainAuth.isAuthenticated) {
                             final result = await Navigator.push<bool>(
                               context,
                               MaterialPageRoute(builder: (_) => const CustomerLoginScreen()),
                             );
                             if (result != true || !context.mounted) return;
                           }

                           if (!context.mounted) return;
                           Navigator.push(context, MaterialPageRoute(builder: (_) => CheckoutScreen(cartItems: cartItems)));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Proceed to Checkout",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
