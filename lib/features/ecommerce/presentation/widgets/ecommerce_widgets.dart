import 'package:flutter/material.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/ecommerce_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ⭐ STAR RATING ROW
// ─────────────────────────────────────────────────────────────────────────────
class StarRatingRow extends StatelessWidget {
  final int rating;
  final int maxRating;
  final double size;

  const StarRatingRow({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (i) {
        return Icon(
          i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
          color: AppColors.shopStarGold,
          size: size,
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 📦 PRODUCT MINI CARD (for Your Orders / Buy Again grids in screenshot 2)
// ─────────────────────────────────────────────────────────────────────────────
class ProductMiniCard extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final bool isSelected; // Blue border when selected (screenshot 2)
  final VoidCallback? onTap;

  const ProductMiniCard({
    super.key,
    this.imageUrl,
    this.name,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColors.shopOrderCardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.shopSelectedBorder : AppColors.shopDivider,
            width: isSelected ? 2.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
              child: AspectRatio(
                aspectRatio: 1.2,
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const _ImagePlaceholder(),
                      )
                    : const _ImagePlaceholder(),
              ),
            ),
            if (name != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Text(
                  name!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.shopSectionTitle,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.shopOrderBuyAgainBg,
      child: const Center(
        child: Icon(Icons.image_outlined, color: Colors.grey, size: 36),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 🏷️ ORDER STATUS BADGE
// ─────────────────────────────────────────────────────────────────────────────
class OrderStatusBadge extends StatelessWidget {
  final String status;

  const OrderStatusBadge({super.key, required this.status});

  Color _color() {
    switch (status.toUpperCase()) {
      case 'DELIVERED':
        return AppColors.shopDeliveredGreen;
      case 'CONFIRMED':
        return AppColors.shopBlueCta;
      case 'REFUNDED':
        return AppColors.shopRefundPurple;
      case 'CANCELLED':
        return AppColors.accentRed;
      case 'REFUND_REQUESTED':
        return AppColors.broadcastOrange;
      case 'REPLACED':
        return AppColors.secondaryGreen;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 📋 SECTION HEADER (with optional "See All" action)
// ─────────────────────────────────────────────────────────────────────────────
class ShopSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const ShopSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.shopSectionTitle,
            ),
          ),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.shopBlueCta,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 🔵 ECOM ACTION BUTTON (solid fill, used for Replace / Refund / Buy Now)
// ─────────────────────────────────────────────────────────────────────────────
class EcomActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color? color;
  final Color? foreground;
  final bool outlined;
  final IconData? icon;

  const EcomActionButton({
    super.key,
    required this.label,
    this.onTap,
    this.color,
    this.foreground,
    this.outlined = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color ?? AppColors.shopBlueCta;
    final fg = foreground ?? Colors.white;

    if (outlined) {
      return OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: bg,
          side: BorderSide(color: bg, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        icon: icon != null ? Icon(icon, size: 16) : const SizedBox.shrink(),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      );
    }

    return ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      icon: icon != null ? Icon(icon, size: 16) : const SizedBox.shrink(),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 📄  REVIEW MINI CARD (in "Your Reviews" grid, screenshot 2)
// ─────────────────────────────────────────────────────────────────────────────
class ReviewMiniCard extends StatelessWidget {
  final String? imageUrl;
  final String? productId; // Optional product ID for async image fallback
  final int rating;
  final String comment;
  final VoidCallback? onTap;

  const ReviewMiniCard({
    super.key,
    this.imageUrl,
    this.productId,
    required this.rating,
    required this.comment,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.shopOrderCardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.shopDivider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            StarRatingRow(rating: rating, size: 16),
            const SizedBox(height: 8),
            if (imageUrl != null && imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const _ImagePlaceholder(),
                  ),
                ),
              )
            else if (productId != null && productId!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: AsyncProductImage(productId: productId!),
                ),
              )
            else
              const _ImagePlaceholder(),
            const SizedBox(height: 8),
            Text(
              comment,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 🌐 ASYNC PRODUCT LOADERS (Fetch single product from backend if missing info)
// ─────────────────────────────────────────────────────────────────────────────

class AsyncProductImage extends StatelessWidget {
  final String productId;
  final double? width;
  final double? height;
  final BoxFit fit;

  const AsyncProductImage({
    super.key,
    required this.productId,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProductModel>(
      future: EcommerceRepository().getProductById(productId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: width,
            height: height,
            child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
          );
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.images.isEmpty) {
          return SizedBox(
            width: width,
            height: height,
            child: const _ImagePlaceholder(),
          );
        }
        return CachedNetworkImage(
          imageUrl: snapshot.data!.images[0],
          width: width,
          height: height,
          fit: fit,
          placeholder: (context, url) => const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
          errorWidget: (context, url, err) => const _ImagePlaceholder(),
        );
      },
    );
  }
}

class AsyncProductName extends StatelessWidget {
  final String productId;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  const AsyncProductName({
    super.key,
    required this.productId,
    this.style,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProductModel>(
      future: EcommerceRepository().getProductById(productId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('...', style: style);
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Text('Product ID: $productId', style: style, maxLines: maxLines, overflow: overflow);
        }
        return Text(
          snapshot.data!.name,
          style: style,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}
