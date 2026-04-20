import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/constants/app_colors.dart';
import '../../providers/category_provider.dart';
import '../../providers/customer_auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import 'cart_screen.dart';
import 'customer_login_screen.dart';
import 'customer_profile_screen.dart';
import 'product_detail_screen.dart';
import 'user_orders_screen.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts(refresh: true);
      context.read<ProductProvider>().fetchFeaturedProducts();
      context.read<CategoryProvider>().fetchCategories();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<ProductProvider>().fetchProducts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onCategorySelected(String? categoryId, String? name) {
    print('🛒 [ECOMMERCE UI] Category Clicked: id=$categoryId, name=$name');
    setState(() {
      _selectedCategoryId = categoryId;
      _selectedCategoryName = name;
    });
    context.read<ProductProvider>().setCategoryFilter(categoryId);
  }

  void _onSearchChanged(String query) {
    context.read<ProductProvider>().setSearchQuery(query);
  }

  // ─────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: ECommerceColors.scaffold,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // ── Header (no SliverPersistentHeader to avoid render overflow) ──
            SliverToBoxAdapter(child: _buildHeader(topPad)),

            // ── Shortcut row ─────────────────────────────────────
            SliverToBoxAdapter(child: _buildShortcutRow()),

            // ── Category chips ──────────────────────────────────
            SliverToBoxAdapter(child: _buildCategorySection()),

            // ── Featured banner section ─────────────────────────
            SliverToBoxAdapter(child: _buildFeaturedSection()),

            // ── Section title ────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedCategoryName != null
                          ? _selectedCategoryName!
                          : 'All Products',
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: ECommerceColors.sectionTitle,
                      ),
                    ),
                    Consumer<ProductProvider>(
                      builder: (_, p, __) => Text(
                        '${p.products.length} items',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: ECommerceColors.seeAll,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Product grid ────────────────────────────────────
            _buildProductSliver(),

            const SliverPadding(padding: EdgeInsets.only(bottom: 30)),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // HEADER  — simple SliverToBoxAdapter, no SliverPersistentHeader
  // ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(double topPad) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ECommerceColors.gradientStart, // #486E9B
            ECommerceColors.gradientEnd,   // #F8F9FB
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Expanded(
                child: Text(
                  'Shilpkar Foundation',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              // Cart badge
              Consumer<OrderProvider>(
                builder: (_, op, __) => Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _SmallIconBtn(
                      icon: Icons.shopping_bag_outlined,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const CartScreen())),
                    ),
                    if (op.cartCount > 0)
                      Positioned(
                        top: -3,
                        right: -3,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                              color: ECommerceColors.featuredTag,
                              shape: BoxShape.circle),
                          child: Center(
                            child: Text('${op.cartCount}',
                                style: GoogleFonts.poppins(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Consumer<CustomerAuthProvider>(
                builder: (_, auth, __) => _SmallIconBtn(
                  icon: auth.isAuthenticated || context.read<AuthProvider>().isAuthenticated
                      ? Icons.person_rounded
                      : Icons.person_outline_rounded,
                  onTap: () {
                    if (auth.isAuthenticated || context.read<AuthProvider>().isAuthenticated) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerProfileScreen()));
                    } else {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerLoginScreen()));
                    }
                  }
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search bar — pill with external search icon button
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: ECommerceColors.sectionTitle),
                    decoration: InputDecoration(
                      hintText: 'Search Products',
                      hintStyle: GoogleFonts.poppins(
                          fontSize: 14, color: Colors.grey[400]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 14),
                      suffixIcon: ValueListenableBuilder(
                        valueListenable: _searchController,
                        builder: (_, v, __) => v.text.isEmpty
                            ? const SizedBox()
                            : IconButton(
                                icon: const Icon(Icons.close,
                                    size: 18, color: Colors.grey),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                },
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35), width: 1.5),
                ),
                child: const Icon(Icons.search_rounded,
                    color: Colors.white, size: 22),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // SHORTCUT ROW  (Orders · Deals · Categories)
  // ─────────────────────────────────────────────────────────────────
  Widget _buildShortcutRow() {
    final shortcuts = [
      _Shortcut('Orders', Icons.receipt_long_outlined, () {
        final auth = context.read<CustomerAuthProvider>();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) {
              final mainAuth = context.read<AuthProvider>();
              return auth.isAuthenticated || mainAuth.isAuthenticated
                  ? const UserOrdersScreen()
                  : const CustomerLoginScreen();
            },
          ),
        );
      }),
      _Shortcut('Deals', Icons.local_offer_outlined, () {}),
      _Shortcut('Categories', Icons.category_outlined, () {
        // Scroll down slightly to show categories
        _scrollController.animateTo(
          300,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: shortcuts.map((s) {
          return Expanded(
            child: GestureDetector(
              onTap: s.onTap,
              child: Column(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: ECommerceColors.gradientStart
                              .withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Icon(s.icon,
                        color: ECommerceColors.gradientStart, size: 28),
                  ),
                  const SizedBox(height: 6),
                  Text(s.label,
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: ECommerceColors.sectionTitle)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // CATEGORY CHIPS
  // ─────────────────────────────────────────────────────────────────
  Widget _buildCategorySection() {
    return Consumer<CategoryProvider>(
      builder: (_, provider, __) {
        final categories = provider.categories;
        if (categories.isEmpty) return const SizedBox(height: 8);

        return Padding(
          padding: const EdgeInsets.only(top: 18, bottom: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('Categories',
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: ECommerceColors.sectionTitle)),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 38,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    if (i == 0) return _buildChip('All', null);
                    final cat = categories[i - 1];
                    return _buildChip(cat.name, cat.id);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChip(String label, String? id) {
    final selected = _selectedCategoryId == id;
    return GestureDetector(
      onTap: () => _onCategorySelected(id, id == null ? null : label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? ECommerceColors.chipSelected
              : ECommerceColors.chipUnselected,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? ECommerceColors.chipSelected
                : ECommerceColors.chipBorder,
            width: 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color:
                        ECommerceColors.chipSelected.withValues(alpha: 0.30),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: selected
                ? ECommerceColors.chipTextSel
                : ECommerceColors.chipTextUnsel,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // FEATURED SECTION
  // ─────────────────────────────────────────────────────────────────
  Widget _buildFeaturedSection() {
    // Only show featured when NOT filtering by category
    if (_selectedCategoryId != null) return const SizedBox();

    return Consumer<ProductProvider>(
      builder: (_, provider, __) {
        final featured = provider.featuredProducts;
        if (featured.isEmpty) return const SizedBox();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
              child: Text(
                'Featured',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ECommerceColors.sectionTitle,
                ),
              ),
            ),
            SizedBox(
              height: 210,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.88),
                itemCount: featured.length,
                itemBuilder: (_, i) {
                  final product = featured[i];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              ProductDetailScreen(product: product)),
                    ),
                    child: _FeaturedCard(product: product),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // PRODUCT GRID SLIVER
  // ─────────────────────────────────────────────────────────────────
  Widget _buildProductSliver() {
    return Consumer<ProductProvider>(
      builder: (_, provider, __) {
        if (provider.isLoading && provider.products.isEmpty) {
          return const SliverFillRemaining(
            child: Center(
                child: CircularProgressIndicator(
                    color: ECommerceColors.gradientStart)),
          );
        }

        if (provider.products.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 60,
                      color: Colors.grey.withValues(alpha: 0.4)),
                  const SizedBox(height: 12),
                  Text('No products found',
                      style: GoogleFonts.poppins(
                          color: Colors.grey, fontSize: 15)),
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (_, i) {
                if (i == provider.products.length) {
                  return provider.isLoading
                      ? const Center(
                          child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(
                              color: ECommerceColors.gradientStart),
                        ))
                      : const SizedBox();
                }
                final product = provider.products[i];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(product: product)),
                  ),
                  child: _ProductGridCard(product: product),
                );
              },
              childCount: provider.hasMore
                  ? provider.products.length + 1
                  : provider.products.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.70,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DATA HELPER
// ─────────────────────────────────────────────────────────────────────────────
class _Shortcut {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  _Shortcut(this.label, this.icon, this.onTap);
}

// ─────────────────────────────────────────────────────────────────────────────
// SMALL HEADER ICON BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class _SmallIconBtn extends StatelessWidget {
  const _SmallIconBtn({required this.icon, required this.onTap});
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
          color: Colors.white.withValues(alpha: 0.20),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FEATURED CARD
// ─────────────────────────────────────────────────────────────────────────────
class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.product});
  final dynamic product;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(6, 0, 6, 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: ECommerceColors.cardSurface,
        boxShadow: [
          BoxShadow(
              color: ECommerceColors.cardShadow,
              blurRadius: 14,
              offset: const Offset(0, 5))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned.fill(
              child: product.images.isNotEmpty
                  ? Image.network(product.images.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                          color: ECommerceColors.chipBorder,
                          child: const Icon(Icons.image_not_supported,
                              size: 48, color: Colors.grey)))
                  : Container(color: ECommerceColors.chipBorder),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.60)
                    ],
                    stops: const [0.45, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 14,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ECommerceColors.featuredTag,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('⭐ Featured',
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87)),
              ),
            ),
            Positioned(
              bottom: 14,
              left: 14,
              right: 14,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 8),
                  Text('₹${product.price}',
                      style: GoogleFonts.poppins(
                          color: ECommerceColors.featuredTag,
                          fontSize: 15,
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PRODUCT GRID CARD
// ─────────────────────────────────────────────────────────────────────────────
class _ProductGridCard extends StatelessWidget {
  const _ProductGridCard({required this.product});
  final dynamic product;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ECommerceColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: ECommerceColors.cardShadow,
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: product.images.isNotEmpty
                  ? Image.network(product.images.first,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => Container(
                          color: ECommerceColors.scaffold,
                          child: const Icon(Icons.image_not_supported,
                              color: Colors.grey)))
                  : Container(
                      color: ECommerceColors.scaffold,
                      child: const Icon(Icons.shopping_bag_outlined,
                          color: Colors.grey, size: 36)),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ECommerceColors.productName,
                          height: 1.3)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('₹${product.price}',
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: ECommerceColors.productPrice)),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                            color: ECommerceColors.addToCartBg,
                            borderRadius: BorderRadius.circular(9)),
                        child: const Icon(Icons.add,
                            color: ECommerceColors.addToCartText, size: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
