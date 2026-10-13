// favorites.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/state/favorites_model.dart';
import '../../core/theme/app_colors.dart';
import '../../data/products.dart';
import '../../widgets/product_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final favorites = context.watch<FavoritesModel>();
    final favs = products.where((p) => favorites.contains(p.id)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My Favorites')),
      body: favs.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite_border,
                      size: 72, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  Text('No favorites yet', style: text.titleMedium),
                  const SizedBox(height: 8),
                  Text('Tap the heart on any product', style: text.bodyMedium),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.62,
              ),
              itemCount: favs.length,
              itemBuilder: (context, i) {
                final p = favs[i];
                return ProductCard(
                  product: p,
                  isFavorite: true,
                  onFavorite: () =>
                      context.read<FavoritesModel>().toggle(p.id),
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/product_details',
                    arguments: p,
                  ),
                );
              },
            ),
    );
  }
}

