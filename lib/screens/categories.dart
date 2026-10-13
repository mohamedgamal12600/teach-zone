// categories.dart
import 'package:flutter/material.dart';

import '../data/products.dart';
import '../main.dart' show cartModel, favoritesModel;
import '../models/product.dart';
import '../widgets/category_tabs.dart';
import '../widgets/product_card.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final List<String> _categories = [
    'ALL',
    ...{for (final p in products) p.category},
  ];
  int _category = 0;

  List<Product> get _visible => _category == 0
      ? products.toList()
      : products.where((p) => p.category == _categories[_category]).toList();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final items = _visible;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.compare_arrows),
            tooltip: 'Compare Products',
            onPressed: () => Navigator.pushNamed(context, '/compare_products'),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () => Navigator.pushNamed(context, '/search'),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          CategoryTabs(
            items: _categories,
            selected: _category,
            onSelected: (i) => setState(() => _category = i),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Text('No products found', style: text.bodyMedium),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.62,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final p = items[i];
                      return ListenableBuilder(
                        listenable: favoritesModel,
                        builder: (_, _) => ProductCard(
                          product: p,
                          isFavorite: favoritesModel.contains(p.id),
                          onFavorite: () => favoritesModel.toggle(p.id),
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/product_details',
                            arguments: p,
                          ),
                          onAddToCart: () {
                            cartModel.add(p);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${p.name} added to cart'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
