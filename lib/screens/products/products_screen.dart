// products.dart
import 'package:flutter/material.dart';

import '../../data/products.dart' as catalog;
import '../../core/state/cart_model.dart';
import '../../core/state/favorites_model.dart';
import 'package:provider/provider.dart';
import '../../widgets/product_card.dart';

class ProductsScreen extends StatelessWidget {
  final String category;

  const ProductsScreen({super.key, this.category = 'ALL'});

  @override
  Widget build(BuildContext context) {
    final list = category == 'ALL'
        ? catalog.products
        : catalog.products.where((p) => p.category == category).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(category == 'ALL' ? 'All Products' : category),
      ),
      body: list.isEmpty
          ? const Center(child: Text('No products found in this category'))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.62,
              ),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final p = list[i];
                final isFav = context.watch<FavoritesModel>().contains(p.id);
                return ProductCard(
                  product: p,
                  isFavorite: isFav,
                  onFavorite: () => context.read<FavoritesModel>().toggle(p.id),
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/product_details',
                    arguments: p,
                  ),
                  onAddToCart: () {
                    context.read<CartModel>().add(p);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${p.name} added to cart'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

