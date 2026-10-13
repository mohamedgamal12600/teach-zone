import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/state/cart_model.dart';
import '../../core/state/favorites_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/price_formatter.dart';
import '../../data/brand_logos.dart';
import '../../models/product.dart';
import '../../widgets/color_dot.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _color = 0;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                  ),
                  Expanded(
                    child: Text(
                      p.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodyLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        context.read<FavoritesModel>().toggle(p.id),
                    icon: Icon(
                      context.watch<FavoritesModel>().contains(p.id)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      size: 20,
                      color: context.watch<FavoritesModel>().contains(p.id)
                          ? AppColors.danger
                          : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (brandLogos[p.brand] != null) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(
                                  brandLogos[p.brand]!,
                                  width: 18,
                                  height: 18,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Text(p.brand, style: text.labelSmall),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(p.name, style: text.headlineMedium),
                        const SizedBox(height: 4),
                        Text(p.category, style: text.bodyMedium),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            _Stat(icon: Icons.visibility, value: p.views),
                            const SizedBox(width: 18),
                            _Stat(icon: Icons.favorite, value: '${p.likes}'),
                            const SizedBox(width: 18),
                            _Stat(
                              icon: Icons.shopping_bag,
                              value: '${p.sold}',
                            ),
                          ],
                        ),
                        if (p.rating > 0) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 16, color: AppColors.accent),
                              const SizedBox(width: 4),
                              Text(
                                p.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accent,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      for (var i = 0; i < p.colors.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: GestureDetector(
                            onTap: () => setState(() => _color = i),
                            child: ColorDot(
                              color: p.colors[i],
                              size: 26,
                              selected: _color == i,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Hero(
                  tag: 'product-${p.id}',
                  child: Image.asset(
                    p.image,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.image_not_supported_outlined,
                      size: 80,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ),
            if (p.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 8),
                child: Text(p.description, style: text.bodyMedium, maxLines: 3,
                    overflow: TextOverflow.ellipsis),
              ),
            if (p.specs.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: p.specs.entries
                      .take(4)
                      .map((e) => Chip(
                            label: Text('${e.key}: ${e.value}',
                                style: const TextStyle(fontSize: 11)),
                            backgroundColor: AppColors.surfaceDark,
                            side: BorderSide.none,
                            padding: EdgeInsets.zero,
                          ))
                      .toList(),
                ),
              ),
            Container(
              width: 36,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 16, 28, 20),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        PriceFormatter.formatWithCurrency(p.price),
                        style: text.titleLarge?.copyWith(color: AppColors.accent),
                      ),
                      if (p.oldPrice != null)
                        Text(
                          PriceFormatter.formatWithCurrency(p.oldPrice!),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Builder(
                    builder: (context) {
                      final inCart = context
                          .watch<CartModel>()
                          .items
                          .any((i) => i.product.id == p.id);
                      return ElevatedButton.icon(
                        onPressed: () {
                          context.read<CartModel>().add(p);
                          final messenger = ScaffoldMessenger.of(context);
                          messenger.showSnackBar(
                            SnackBar(content: Text('${p.name} added to cart')),
                          );
                        },
                        icon: Icon(
                          inCart
                              ? Icons.shopping_bag
                              : Icons.shopping_bag_outlined,
                          size: 18,
                        ),
                        label: Text(inCart ? 'In Cart' : 'Add to cart'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

