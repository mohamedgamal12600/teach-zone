// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/state/auth_model.dart';
import 'core/state/cart_model.dart';
import 'core/state/favorites_model.dart';
import 'core/state/orders_model.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'models/product.dart';
import 'screens/cart.dart';
import 'screens/categories.dart';
import 'screens/checkout.dart';
import 'screens/compare_products.dart';
import 'screens/create_account.dart';
import 'screens/favorites.dart';
import 'screens/home.dart';
import 'screens/login.dart';
import 'screens/onboarding.dart';
import 'screens/orders.dart';
import 'screens/product_details.dart';
import 'screens/products.dart';
import 'screens/profile.dart';
import 'screens/search.dart';
import 'screens/splash.dart';

// Global singleton models — shared across the whole app.
final cartModel = CartModel();
final favoritesModel = FavoritesModel();
final authModel = AuthModel();
final ordersModel = OrdersModel();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const TechZoneApp());
}

class TechZoneApp extends StatelessWidget {
  const TechZoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TechZone',
      theme: AppTheme.dark,
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/home': (_) => const HomeScreen(),
        '/login': (_) => const LoginScreen(),
        '/create_account': (_) => const CreateAccountScreen(),
        '/categories': (_) => const CategoriesScreen(),
        '/products': (_) => const ProductsScreen(),
        '/search': (_) => const SearchScreen(),
        '/favorites': (_) => const FavoritesScreen(),
        '/compare_products': (_) => const CompareProductsScreen(),
        '/cart': (_) => const CartScreen(),
        '/checkout': (_) => const CheckoutScreen(),
        '/orders': (_) => const OrdersScreen(),
        '/profile': (_) => const ProfileScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/product_details') {
          final product = settings.arguments as Product;
          return MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: product),
          );
        }
        return null;
      },
    );
  }
}
