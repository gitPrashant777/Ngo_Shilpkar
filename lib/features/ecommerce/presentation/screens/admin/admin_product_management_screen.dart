import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../providers/product_provider.dart';
import 'add_edit_product_screen.dart';
import 'admin_category_management_screen.dart';
import 'admin_order_management_screen.dart';

class AdminProductManagementScreen extends StatefulWidget {
  const AdminProductManagementScreen({super.key});

  @override
  State<AdminProductManagementScreen> createState() =>
      _AdminProductManagementScreenState();
}

class _AdminProductManagementScreenState extends State<AdminProductManagementScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;
  final currencyFormatter = NumberFormat.currency(locale: 'HI', symbol: '₹');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts(refresh: true);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        context.read<ProductProvider>().fetchProducts();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _confirmDelete(String id, String name) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.deleteProduct),
        content: Text(l10n.deleteProductConfirm(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel, style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            onPressed: () async {
              Navigator.pop(context);
              _handleDelete(id);
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDelete(String id) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await context.read<ProductProvider>().deleteProduct(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.productRemoved), behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(l10n.productInventory, style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: AppColors.appBarBlue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Products'),
            Tab(text: 'Categories'),
            Tab(text: 'Orders'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          )
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProductsTab(l10n),
          const AdminCategoryManagementScreen(embedded: true),
          const AdminOrderManagementScreen(embedded: true),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
              ),
              backgroundColor: AppColors.secondaryGreen,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                l10n.newProduct,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }

  Widget _buildProductsTab(AppLocalizations l10n) {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.products.isEmpty) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (provider.error != null && provider.products.isEmpty) {
          return _buildErrorState(provider, l10n);
        }

        final products = provider.products;
        if (products.isEmpty) {
          return Center(child: Text(l10n.inventoryEmpty));
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchProducts(refresh: true),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            controller: _scrollController,
            itemCount: products.length + (provider.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == products.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator.adaptive()),
                );
              }

              final product = products[index];
              return _buildProductCard(product);
            },
          ),
        );
      },
    );
  }

  Widget _buildProductCard(dynamic product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                color: Colors.grey[100],
                child: product.images.isNotEmpty
                    ? Image.network(
                  product.images.first,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey),
                )
                    : const SizedBox(
                    width: 80, height: 80, child: Icon(Icons.inventory_2, color: Colors.grey)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildBadge(
                        product.categoryName ?? "General",
                        Colors.blue.withOpacity(0.1),
                        Colors.blue[700]!,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        currencyFormatter.format(product.price),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.green[700],
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent, size: 22),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddEditProductScreen(product: product)),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                  onPressed: () => _confirmDelete(product.id, product.name),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6)),
      child: Text(
        label,
        style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildErrorState(ProductProvider provider, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text("${provider.error}", style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => provider.fetchProducts(refresh: true),
            icon: const Icon(Icons.refresh),
            label: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}
