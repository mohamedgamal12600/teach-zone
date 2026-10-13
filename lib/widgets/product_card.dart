// product_card.dart
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/price_formatter.dart';
import '../data/brand_logos.dart';
import '../models/product.dart';
import 'color_dot.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.onFavorite,
    required this.onTap,
    this.onAddToCart,
  });

  final Product product;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onTap;
  final VoidCallback? onAddToCart;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final logoUrl = brandLogos[product.brand];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top: Brand, Name & Favorite Button
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (logoUrl != null) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: Image.network(
                                logoUrl,
                                width: 14,
                                height: 14,
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) => const SizedBox.shrink(),
                              ),
                            ),
                            const SizedBox(width: 4),
                          ],
                          Flexible(
                            child: Text(
                              product.brand,
                              style: text.labelSmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleMedium?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: onFavorite,
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: 20,
                    color: isFavorite ? AppColors.danger : Colors.white,
                  ),
                ),
              ],
            ),

            // Middle: Product Image
            Expanded(
              child: Center(
                child: Hero(
                  tag: 'product-${product.id}',
                  child: Image.asset(
                    product.image,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.image_not_supported_outlined,
                      size: 50,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ),

            // Color dots (if any)
            if (product.colors.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    for (final c in product.colors.take(3))
                      Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: ColorDot(color: c, size: 12),
                      ),
                  ],
                ),
              ),

            // Bottom: Price Pill & Cart Button
            Row(
              children: [
                Expanded(
                  child: _PricePill(price: product.price, oldPrice: product.oldPrice),
                ),
                if (onAddToCart != null) ...[
                  const SizedBox(width: 6),
                  Material(
                    color: AppColors.accent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onAddToCart,
                      child: const SizedBox(
                        width: 34,
                        height: 34,
                        child: Icon(
                          Icons.add_shopping_cart,
                          size: 17,
                          color: AppColors.surfaceDark,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PricePill extends StatelessWidget {
  const _PricePill({required this.price, this.oldPrice});

  final double price;
  final double? oldPrice;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              PriceFormatter.formatWithCurrency(price),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          if (oldPrice != null)
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                PriceFormatter.formatWithCurrency(oldPrice!),
                style: const TextStyle(
                  fontSize: 9,
                  color: AppColors.textSecondary,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
