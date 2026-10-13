import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/state/cart_model.dart';
import '../../core/state/favorites_model.dart';
import '../../core/theme/app_colors.dart';
import '../../data/products.dart';
import '../../models/product.dart';
import '../../widgets/product_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchCtrl = TextEditingController();
  String _selectedCategory = 'ALL';
  String _sortBy =
      'relevance'; // 'relevance', 'price_asc', 'price_desc', 'rating'
  double _minPrice = 0;
  double _maxPrice = 100000;
  bool _showFilters = false;

  final List<String> _categories = [
    'ALL',
    ...{for (final p in products) p.category},
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Product> get _filteredProducts {
    final query = _searchCtrl.text.trim().toLowerCase();
    var list =
        products.where((p) {
          final matchesQuery =
              query.isEmpty ||
              p.name.toLowerCase().contains(query) ||
              p.brand.toLowerCase().contains(query) ||
              p.category.toLowerCase().contains(query);

          final matchesCategory =
              _selectedCategory == 'ALL' || p.category == _selectedCategory;

          final matchesPrice = p.price >= _minPrice && p.price <= _maxPrice;

          return matchesQuery && matchesCategory && matchesPrice;
        }).toList();

    switch (_sortBy) {
      case 'price_asc':
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      default:
        break;
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final results = _filteredProducts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search & Filter'),
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: _showFilters ? AppColors.accent : Colors.white,
            ),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search input bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search laptops, consoles, headphones...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon:
                    _searchCtrl.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() {});
                          },
                        )
                        : null,
              ),
            ),
          ),

          // Collapsible filter panel
          if (_showFilters)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Categories', style: text.titleMedium),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedCategory = 'ALL';
                            _sortBy = 'relevance';
                            _minPrice = 0;
                            _maxPrice = 100000;
                          });
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          _categories.map((c) {
                            final isSel = _selectedCategory == c;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(c),
                                selected: isSel,
                                selectedColor: AppColors.accent,
                                labelStyle: TextStyle(
                                  color:
                                      isSel
                                          ? AppColors.surfaceDark
                                          : Colors.white,
                                  fontWeight:
                                      isSel ? FontWeight.w700 : FontWeight.w400,
                                  fontSize: 12,
                                ),
                                onSelected:
                                    (_) =>
                                        setState(() => _selectedCategory = c),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Sort By', style: text.titleMedium),
                      DropdownButton<String>(
                        value: _sortBy,
                        dropdownColor: AppColors.surfaceDark,
                        underline: const SizedBox(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'relevance',
                            child: Text('Relevance'),
                          ),
                          DropdownMenuItem(
                            value: 'price_asc',
                            child: Text('Price: Low to High'),
                          ),
                          DropdownMenuItem(
                            value: 'price_desc',
                            child: Text('Price: High to Low'),
                          ),
                          DropdownMenuItem(
                            value: 'rating',
                            child: Text('Top Rated'),
                          ),
                        ],
                        onChanged: (v) => setState(() => _sortBy = v!),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Price: EGP ${_minPrice.toInt()} - EGP ${_maxPrice.toInt()}',
                    style: text.bodyMedium,
                  ),
                  RangeSlider(
                    values: RangeValues(_minPrice, _maxPrice),
                    min: 0,
                    max: 100000,
                    divisions: 100,
                    activeColor: AppColors.accent,
                    inactiveColor: AppColors.surfaceDark,
                    onChanged: (vals) {
                      setState(() {
                        _minPrice = vals.start;
                        _maxPrice = vals.end;
                      });
                    },
                  ),
                ],
              ),
            ),

          // Results counter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${results.length} product${results.length == 1 ? '' : 's'} found',
                  style: text.labelSmall,
                ),
              ],
            ),
          ),

          // Product results list
          Expanded(
            child:
                results.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 64,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No products match your criteria',
                            style: text.bodyMedium,
                          ),
                        ],
                      ),
                    )
                    : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.62,
                          ),
                      itemCount: results.length,
                      itemBuilder: (context, i) {
                        final p = results[i];
                        final isFav = context.watch<FavoritesModel>().contains(
                          p.id,
                        );
                        return ProductCard(
                          product: p,
                          isFavorite: isFav,
                          onFavorite:
                              () => context.read<FavoritesModel>().toggle(p.id),
                          onTap:
                              () => Navigator.pushNamed(
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
          ),
        ],
      ),
    );
  }
}
