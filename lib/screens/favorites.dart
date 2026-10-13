// favorites.dart
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../data/products.dart';
import '../main.dart' show favoritesModel;
import '../models/product.dart';
import '../widgets/product_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    favoritesModel.addListener(_rebuild);
  }

  @override
  void dispose() {
    favoritesModel.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  List<Product> get _favProducts =>
      products.where((p) => favoritesModel.contains(p.id)).toList();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final favs = _favProducts;

    return Scaffold(
      appBar: AppBar(title: const Text('My Favorites')),
      body: favs.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite_border, size: 72, color: AppColors.textMuted),
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
                  onFavorite: () => favoritesModel.toggle(p.id),
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
