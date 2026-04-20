import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../providers/customer_auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/review_provider.dart';
import 'customer_login_screen.dart';
import 'user_orders_screen.dart';
import 'order_detail_screen.dart';
import '../../widgets/ecommerce_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Customer Profile screen â€” matching screenshot 2 layout:
///   Profile card â†’ Your Orders (horizontal scroll, selected = blue border)
///   â†’ Buy Again (horizontal scroll) â†’ Your Reviews (grid)
class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  String? _selectedOrderId; // blue border on selected order card

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<CustomerAuthProvider>();
      if (auth.isAuthenticated) {
        context.read<OrderProvider>().fetchMyOrders();
      }
    });
  }

  // â”€â”€â”€ HEADER / APP BAR â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  PreferredSizeWidget _appBar(BuildContext context, CustomerAuthProvider auth) {
    return AppBar(
      backgroundColor: AppColors.appBarBlue,
      foregroundColor: Colors.white,
      scrolledUnderElevation: 0,
      title: const Text('Shilpkar Foundation',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      actions: [
        if (auth.isAuthenticated)
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Logged out'),
                      backgroundColor: Colors.green),
                );
              }
            },
          ),
      ],
    );
  }

  // â”€â”€â”€ GUEST VIEW â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _guestView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.appBarBlue.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.account_circle_outlined,
                  size: 72, color: AppColors.appBarBlue),
            ),
            const SizedBox(height: 24),
            Text(AppLocalizations.of(context)!.notLoggedIn,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.loginToViewProfile,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.login_rounded),
                label: Text(AppLocalizations.of(context)!.loginRegister),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.appBarBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CustomerLoginScreen()),
                  );
                  if (result == true && context.mounted) {
                    context.read<OrderProvider>().fetchMyOrders();
                    setState(() {});
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // â”€â”€â”€ AUTHENTICATED VIEW â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _authenticatedView(
      BuildContext context, CustomerAuthProvider auth, OrderProvider op) {
    final customer = auth.currentCustomer;
    final orders = op.myOrders;


    return CustomScrollView(
      slivers: [
        // â”€â”€ Profile Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [ECommerceColors.gradientStart, ECommerceColors.gradientMid],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),

              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: ECommerceColors.gradientStart.withValues(alpha: 0.28),

                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  child: const Icon(Icons.person_rounded,
                      color: Colors.white, size: 32),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer?.fullName ?? 'Customer',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17),
                      ),
                      if (customer?.email != null) ...[
                        const SizedBox(height: 3),
                        Row(children: [
                          const Icon(Icons.email_outlined,
                              size: 11, color: Colors.white70),
                          const SizedBox(width: 4),
                          Flexible(
                              child: Text(customer!.email,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 12),
                                  overflow: TextOverflow.ellipsis)),
                        ]),
                      ],
                      if (customer?.mobile != null) ...[
                        const SizedBox(height: 2),
                        Row(children: [
                          const Icon(Icons.phone_outlined,
                              size: 11, color: Colors.white70),
                          const SizedBox(width: 4),
                          Text(customer!.mobile!,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                        ]),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // â”€â”€â”€ YOUR ORDERS â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        if (orders.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: ShopSectionHeader(
              title: 'Your Orders',
              actionLabel: 'See All',
              onAction: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserOrdersScreen()),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: orders.take(6).length,
                itemBuilder: (context, i) {
                  final o = orders[i];
                  final isSelected = _selectedOrderId == o.id;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedOrderId = o.id);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => OrderDetailScreen(order: o)),
                      );
                    },
                    child: Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.shopSelectedBorder
                              : AppColors.shopDivider,
                          width: isSelected ? 2.5 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.shopOrderBuyAgainBg,
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(11)),
                              ),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(11)),
                                child: o.productImage != null && o.productImage!.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: o.productImage!,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => const Center(child: Icon(Icons.shopping_bag_outlined, color: Colors.grey, size: 32)),
                                          errorWidget: (context, url, err) => const Center(child: Icon(Icons.shopping_bag_outlined, color: Colors.grey, size: 32)),
                                        )
                                      : o.productId.isNotEmpty
                                          ? AsyncProductImage(productId: o.productId, fit: BoxFit.cover)
                                          : const Center(
                                              child: Icon(Icons.shopping_bag_outlined,
                                                  color: Colors.grey, size: 32)),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                o.productName != null
                                    ? Text(
                                        o.productName!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.shopSectionTitle),
                                      )
                                    : AsyncProductName(
                                        productId: o.productId,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.shopSectionTitle),
                                      ),
                                const SizedBox(height: 2),
                                OrderStatusBadge(status: o.status),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],

        // â”€â”€â”€ YOUR REVIEWS â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        SliverToBoxAdapter(
          child: ShopSectionHeader(title: 'Your Reviews'),
        ),

        SliverToBoxAdapter(
          child: Consumer<ReviewProvider>(
            builder: (context, rp, _) {
              if (rp.reviews.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('No reviews yet.',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 13)),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {},
                        child: const Text('Add a review',
                            style: TextStyle(
                                color: AppColors.shopBlueCta,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                      ),
                    ],
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: rp.reviews.length,
                      itemBuilder: (context, i) {
                        final rev = rp.reviews[i];
                        return ReviewMiniCard(
                          productId: rev.productId,
                          rating: rev.rating,
                          comment: rev.comment,
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: GestureDetector(
                      onTap: () {},
                      child: const Text('Add a review',
                          style: TextStyle(
                              color: AppColors.shopBlueCta,
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        // Bottom padding for nav bar
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  // â”€â”€â”€ BUILD â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  @override
  Widget build(BuildContext context) {
    return Consumer2<CustomerAuthProvider, OrderProvider>(
      builder: (context, auth, op, _) {
        return Scaffold(
          backgroundColor: AppColors.shopBodyGrey,
          appBar: _appBar(context, auth),
          body: RefreshIndicator(
            onRefresh: () => op.fetchMyOrders(),
            child: auth.isAuthenticated
                ? _authenticatedView(context, auth, op)
                : _guestView(context),
          ),
        );
      },
    );
  }
}

