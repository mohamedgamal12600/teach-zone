// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'core/state/auth_model.dart';
import 'core/state/cart_model.dart';
import 'core/state/favorites_model.dart';
import 'core/state/orders_model.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'models/product.dart';
import 'screens/auth/auth_gate.dart';
import 'screens/auth/create_account_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/categories/categories_screen.dart';
import 'screens/checkout/checkout_screen.dart';
import 'screens/compare/compare_screen.dart';
import 'screens/favorites/favorites_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/products/product_details_screen.dart';
import 'screens/products/products_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/search/search_screen.dart';

// Providers for the app-wide state.
class TechZoneProviders {
  static List<SingleChildWidget> get providers => [
    ChangeNotifierProvider<AuthModel>(create: (_) => AuthModel()),
    ChangeNotifierProvider<CartModel>(create: (_) => CartModel()),
    ChangeNotifierProvider<FavoritesModel>(create: (_) => FavoritesModel()),
    ChangeNotifierProvider<OrdersModel>(create: (_) => OrdersModel()),
  ];
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const TechZoneApp());
}

class TechZoneApp extends StatelessWidget {
  const TechZoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: TechZoneProviders.providers,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TechZone',
        theme: AppTheme.dark,
        initialRoute: '/',
        routes: {
          '/': (_) => const AuthGate(),
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
      ),
    );
  }
}
