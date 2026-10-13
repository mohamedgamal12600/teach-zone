// home.dart
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../data/products.dart';
import '../main.dart' show cartModel, favoritesModel;
import '../models/product.dart';
import '../widgets/app_bottom_bar.dart';
import '../widgets/category_tabs.dart';
import '../widgets/product_card.dart';
import 'cart.dart';
import 'profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _pageController = PageController(viewportFraction: 0.86);
  final _search = TextEditingController();
  final List<String> _categories = [
    'ALL',
    ...{for (final p in products) p.category},
  ];
  int _category = 0;
  int _nav = 0;
  String _query = '';

  @override
  void initState() {
    super.initState();
    // Rebuild when cart or favorites change so the badge & cards update.
    cartModel.addListener(_onModelChange);
    favoritesModel.addListener(_onModelChange);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _search.dispose();
    cartModel.removeListener(_onModelChange);
    favoritesModel.removeListener(_onModelChange);
    super.dispose();
  }

  void _onModelChange() {
    if (mounted) setState(() {});
  }

  List<Product> get _visible => products.where((p) {
        final inCategory =
            _category == 0 || p.category == _categories[_category];
        final matches = p.name.toLowerCase().contains(_query.toLowerCase()) ||
            p.brand.toLowerCase().contains(_query.toLowerCase());
        return inCategory && matches;
      }).toList();

  void _resetPage() {
    if (_pageController.hasClients) _pageController.jumpToPage(0);
  }

  Widget _homeBody() {
    final text = Theme.of(context).textTheme;
    final items = _visible;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.grid_view_rounded),
                tooltip: 'All Categories',
                onPressed: () => Navigator.pushNamed(context, '/categories'),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.compare_arrows),
                    tooltip: 'Compare Products',
                    onPressed: () => Navigator.pushNamed(context, '/compare_products'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    tooltip: 'My Favorites',
                    onPressed: () => Navigator.pushNamed(context, '/favorites'),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 12),
          child: Text('Categories', style: text.titleLarge),
        ),
        CategoryTabs(
          items: _categories,
          selected: _category,
          onSelected: (i) {
            setState(() => _category = i);
            _resetPage();
          },
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _search,
                  onChanged: (v) {
                    setState(() => _query = v);
                    _resetPage();
                  },
                  decoration: InputDecoration(
                    hintText: 'Search Products...',
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _search.clear();
                              setState(() => _query = '');
                              _resetPage();
                            },
                          )
                        : const Icon(Icons.search, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () => Navigator.pushNamed(context, '/search'),
                borderRadius: BorderRadius.circular(AppRadius.field),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.field),
                  ),
                  child: const Icon(Icons.tune, size: 20),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Text('No products found', style: text.bodyMedium),
                )
              : PageView.builder(
                  controller: _pageController,
                  padEnds: false,
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final p = items[i];
                    return Padding(
                      padding: EdgeInsets.only(
                        left: i == 0 ? 22 : 8,
                        right: 8,
                        bottom: 16,
                      ),
                      child: ProductCard(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _nav,
          children: [_homeBody(), const CartScreen(), const ProfileScreen()],
        ),
      ),
      bottomNavigationBar: AppBottomBar(
        index: _nav,
        cartCount: cartModel.itemCount,
        onChanged: (i) => setState(() => _nav = i),
      ),
    );
  }
}
