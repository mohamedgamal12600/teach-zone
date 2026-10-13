import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/state/cart_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/price_formatter.dart';
import '../../data/products.dart';
import '../../models/product.dart';

class CompareProductsScreen extends StatefulWidget {
  const CompareProductsScreen({super.key});

  @override
  State<CompareProductsScreen> createState() => _CompareProductsScreenState();
}

class _CompareProductsScreenState extends State<CompareProductsScreen> {
  Product? _productA;
  Product? _productB;

  @override
  void initState() {
    super.initState();
    if (products.length >= 2) {
      _productA = products[0];
      _productB = products[1];
    }
  }

  void _selectProduct(bool isA) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollCtrl) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Select Product to Compare',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: products.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final p = products[i];
                      return ListTile(
                        leading: SizedBox(
                          width: 44,
                          height: 44,
                          child: Image.asset(
                            p.image,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.devices,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        title: Text(p.name, style: const TextStyle(fontSize: 14)),
                        subtitle: Text(
                          '${p.category} • ${PriceFormatter.formatWithCurrency(p.price)}',
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 12,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            if (isA) {
                              _productA = p;
                            } else {
                              _productB = p;
                            }
                          });
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    final pA = _productA;
    final pB = _productB;

    final allSpecKeys = <String>{};
    if (pA != null) allSpecKeys.addAll(pA.specs.keys);
    if (pB != null) allSpecKeys.addAll(pB.specs.keys);

    return Scaffold(
      appBar: AppBar(title: const Text('Compare Products')),
      body: (pA == null || pB == null)
          ? const Center(child: Text('Not enough products to compare'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Product Headers
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _ProductHeader(
                          product: pA,
                          onTapChange: () => _selectProduct(true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ProductHeader(
                          product: pB,
                          onTapChange: () => _selectProduct(false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Specs Table
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Comparison Overview', style: text.titleMedium),
                        const SizedBox(height: 12),
                        _compareRow('Brand', pA.brand, pB.brand),
                        _compareRow('Category', pA.category, pB.category),
                        _compareRow(
                          'Price',
                          PriceFormatter.formatWithCurrency(pA.price),
                          PriceFormatter.formatWithCurrency(pB.price),
                          highlightDiff: true,
                        ),
                        _compareRow(
                          'Rating',
                          '★ ${pA.rating}',
                          '★ ${pB.rating}',
                        ),
                        _compareRow('Popularity (Likes)', '${pA.likes}', '${pB.likes}'),
                        const Divider(height: 24),
                        Text('Detailed Specs', style: text.titleMedium),
                        const SizedBox(height: 12),
                        if (allSpecKeys.isEmpty)
                          Text('No specific hardware specs listed', style: text.bodyMedium)
                        else
                          for (final key in allSpecKeys)
                            _compareRow(
                              key,
                              pA.specs[key] ?? '—',
                              pB.specs[key] ?? '—',
                            ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _compareRow(String label, String valA, String valB, {bool highlightDiff = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  valA,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: highlightDiff ? FontWeight.w700 : FontWeight.w400,
                    color: highlightDiff ? AppColors.accent : Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  valB,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: highlightDiff ? FontWeight.w700 : FontWeight.w400,
                    color: highlightDiff ? AppColors.accent : Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 12, color: AppColors.outline),
        ],
      ),
    );
  }
}

class _ProductHeader extends StatelessWidget {
  const _ProductHeader({
    required this.product,
    required this.onTapChange,
  });

  final Product product;
  final VoidCallback onTapChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 90,
            child: Image.asset(
              product.image,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(
                Icons.devices,
                size: 48,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: onTapChange,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: const Size(80, 30),
              side: const BorderSide(color: AppColors.accent),
            ),
            child: const Text('Change', style: TextStyle(fontSize: 11, color: AppColors.accent)),
          ),
          const SizedBox(height: 6),
          ElevatedButton(
            onPressed: () {
              context.read<CartModel>().add(product);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.name} added to cart'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: const Size(90, 32),
            ),
            child: const Text('Add to Cart', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

