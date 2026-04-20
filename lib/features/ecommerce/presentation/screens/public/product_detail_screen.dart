import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/constants/app_colors.dart';
import '../../../data/models/product_model.dart';
import '../../providers/customer_auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/review_provider.dart';
import 'cart_screen.dart';
import 'checkout_screen.dart';
import 'customer_login_screen.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _currentImageIndex = 0;
  late Future<void> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to avoid calling notifyListeners during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reviewsFuture = Provider.of<ReviewProvider>(context, listen: false)
          .fetchReviews(widget.product.id);
      if (mounted) setState(() {});
    });
    // Initialize with a never-completing future to avoid LateInitializationError
    _reviewsFuture = Future.value();
  }

  Future<void> _proceedToCheckout(BuildContext context) async {
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(product: widget.product, quantity: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ECommerceColors.scaffold,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(context),
              SliverToBoxAdapter(child: _buildBody(context)),
            ],
          ),
          // ── Floating bottom bar ────────────────────────────────────────────
          _buildBottomBar(context),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // SLIVER APP BAR  (gradient background + floating product image)
  // ─────────────────────────────────────────────────────────────────
  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 340,
      pinned: true,
      elevation: 0,
      backgroundColor: ECommerceColors.gradientStart,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: _CircleBtn(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: _CircleBtn(
            icon: Icons.share_outlined,
            onTap: () {},
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: _buildHeroArea(),
      ),
    );
  }

  Widget _buildHeroArea() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ECommerceColors.gradientStart, // #486E9B  — top
            ECommerceColors.gradientEnd,   // #F8F9FB  — bottom
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 52, 16, 12),
          child: Column(
            children: [
              // ── Brand label ────────────────────────────────────────────────
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Shilpkar Foundation',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // ── Product image card ─────────────────────────────────────────
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: widget.product.images.isNotEmpty
                        ? Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              PageView.builder(
                                itemCount: widget.product.images.length,
                                onPageChanged: (i) =>
                                    setState(() => _currentImageIndex = i),
                                itemBuilder: (_, i) => Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Image.network(
                                    widget.product.images[i],
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Icon(
                                        Icons.broken_image,
                                        size: 80,
                                        color: Colors.grey),
                                  ),
                                ),
                              ),
                              if (widget.product.images.length > 1)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      widget.product.images.length,
                                      (i) => AnimatedContainer(
                                        duration: const Duration(milliseconds: 250),
                                        margin: const EdgeInsets.symmetric(horizontal: 4),
                                        width: _currentImageIndex == i ? 20 : 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(4),
                                          color: _currentImageIndex == i
                                              ? ECommerceColors.gradientStart
                                              : Colors.grey.withValues(alpha: 0.4),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          )
                        : const Center(
                            child: Icon(Icons.image_not_supported,
                                size: 80, color: Colors.grey)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // BODY  (white sheet below the image)
  // ─────────────────────────────────────────────────────────────────
  Widget _buildBody(BuildContext context) {
    final product = widget.product;
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Name + Stars ──────────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    product.name,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        5,
                        (i) => Icon(Icons.star_rounded,
                            color: ECommerceColors.starFilled, size: 18),
                      ),
                    ),
                    Text(
                      '8 Reviews',
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),

            // ── Price ─────────────────────────────────────────────────────────
            Text(
              '₹ ${product.price}',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 20),

            // ── Buy Now ───────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => _proceedToCheckout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ECommerceColors.buyNowBg,
                  foregroundColor: ECommerceColors.buyNowText,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  'Buy Now',
                  style: GoogleFonts.poppins(
                      fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ── Description ───────────────────────────────────────────────────
            Text(
              'Description',
              style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E)),
            ),
            const SizedBox(height: 8),
            Text(
              product.description ?? 'No description available.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.7,
              ),
            ),
            const SizedBox(height: 32),

            // ── Divider ───────────────────────────────────────────────────────
            Divider(color: Colors.grey[200]),
            const SizedBox(height: 16),

            // ── Reviews heading ───────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reviews',
                  style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A2E)),
                ),
                TextButton(
                  onPressed: () async {
                    final auth = context.read<CustomerAuthProvider>();
                    final mainAuth = context.read<AuthProvider>();
                    if (!auth.isAuthenticated && !mainAuth.isAuthenticated) {
                      if (!context.mounted) return;
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CustomerLoginScreen()),
                      );
                      if (result != true || !context.mounted) return;
                    }
                    if (!context.mounted) return;
                    _showAddReviewDialog(context);
                  },
                  child: Text(
                    'Write a review',
                    style: GoogleFonts.poppins(
                        color: ECommerceColors.gradientStart,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  ),
                ),
              ],
            ),

            // ── Reviews list (unchanged logic) ────────────────────────────────
            _buildReviewsList(context),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // BOTTOM BAR  (Add to Cart)
  // ─────────────────────────────────────────────────────────────────
  Widget _buildBottomBar(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Consumer<OrderProvider>(
          builder: (_, op, __) {
            final inCart = op.cartItems.containsKey(widget.product.id);
            return Row(
              children: [
                // Cart qty badge
                if (inCart)
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const CartScreen())),
                    child: Container(
                      width: 52,
                      height: 52,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: ECommerceColors.gradientStart, width: 1.5),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.shopping_bag_outlined,
                          color: ECommerceColors.gradientStart),
                    ),
                  ),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        if (inCart) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const CartScreen()));
                        } else {
                          op.addToCart(widget.product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added to cart!',
                                  style: GoogleFonts.poppins()),
                              backgroundColor: ECommerceColors.gradientStart,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: inCart
                            ? ECommerceColors.gradientStart
                            : ECommerceColors.gradientStart,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        inCart ? 'Go to Cart' : 'Add to Cart',
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // REVIEWS LIST  — same logic, cleaned up style only
  // ─────────────────────────────────────────────────────────────────
  Widget _buildReviewsList(BuildContext context) {
    return FutureBuilder(
      future: _reviewsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return Consumer<ReviewProvider>(
          builder: (context, provider, _) {
            if (provider.reviews.isEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'No reviews yet.',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.reviews.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final review = provider.reviews[index];
                
                String dateString = '';
                if (review.createdAt != null) {
                  try {
                    final dt = DateTime.parse(review.createdAt!);
                    dateString = "${dt.day}/${dt.month}/${dt.year}";
                  } catch (_) {}
                }

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: ECommerceColors.scaffold,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor:
                                ECommerceColors.gradientStart.withValues(alpha: 0.15),
                            child: const Icon(Icons.person,
                                size: 18, color: ECommerceColors.gradientStart),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      review.userName ?? 'Anonymous User',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    if (dateString.isNotEmpty)
                                      Text(
                                        dateString,
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: List.generate(
                                    5,
                                    (si) => Icon(
                                      si < review.rating
                                          ? Icons.star_rounded
                                          : Icons.star_outline_rounded,
                                      color: ECommerceColors.starFilled,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        review.comment,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // ADD REVIEW DIALOG  — unchanged logic
  // ─────────────────────────────────────────────────────────────────
  void _showAddReviewDialog(BuildContext context) {
    final commentController = TextEditingController();
    int rating = 5;
    final reviewProvider =
        Provider.of<ReviewProvider>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Write a Review',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) => IconButton(
                  icon: Icon(
                    i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: ECommerceColors.starFilled,
                    size: 32,
                  ),
                  onPressed: () => setDialogState(() => rating = i + 1),
                )),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  labelText: 'Comment',
                  hintText: 'Share your experience…',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel',
                  style: GoogleFonts.poppins(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (commentController.text.isEmpty) return;
                final reviewData = {
                  'productId': widget.product.id,
                  'rating': rating,
                  'stars': rating,
                  'comment': commentController.text,
                };
                Navigator.pop(dialogContext);
                try {
                  await reviewProvider.createReview(reviewData);
                  if (mounted) {
                    setState(() {
                      _reviewsFuture =
                          reviewProvider.fetchReviews(widget.product.id);
                    });
                  }
                  messenger.showSnackBar(const SnackBar(
                    content: Text('Review submitted!'),
                    backgroundColor: Colors.green,
                  ));
                } catch (e) {
                  messenger.showSnackBar(SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ECommerceColors.gradientStart,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Submit',
                  style: GoogleFonts.poppins(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SMALL HELPER
// ─────────────────────────────────────────────────────────────────────────────
class _CircleBtn extends StatelessWidget {
  const _CircleBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.90),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: ECommerceColors.gradientStart),
      ),
    );
  }
}
