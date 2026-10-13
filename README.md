# TechZone - Electronics Store

A Flutter e-commerce app for electronics, built with Material 3 and Google Fonts (Poppins).

## Design Attribution

Design by **Heba Zatar** - "Free Electronics E-Commerce App" (free for personal use).

## Tech Stack

- Flutter + Dart 3.7+
- Material 3 (`useMaterial3: true`)
- `google_fonts` (Poppins)
- **State: Provider (ChangeNotifier)** — auth, cart, favorites, orders
- Navigation: named routes + `onGenerateRoute`
- Firebase: Auth, Firestore, Core

## Folder Structure

```
lib/
  main.dart                          # MultiProvider setup (auth, cart, favorites, orders)
  core/
    constants/
      app_assets.dart                # 35 asset path constants
    services/
      auth_service.dart              # Firebase Auth + profile sync
      firestore_service.dart         # Orders CRUD
    state/
      auth_model.dart                # Provider wrapper for AuthService
      cart_model.dart                # Shopping cart state (ChangeNotifier)
      favorites_model.dart           # Favorites set (ChangeNotifier)
      orders_model.dart              # Provider wrapper for FirestoreService
      cart_item.dart                 # Cart line item
    theme/
      app_colors.dart, app_theme.dart
    utils/
      price_formatter.dart           # EGP formatting (format, formatWithCurrency)
  models/
    product.dart                     # Product domain model
    brand.dart                       # Brand domain model
    category.dart                    # Category domain model
    order.dart                       # AppOrder + OrderLineItem + OrderStatus
  data/
    products.dart                    # 35 products with real AppAssets images
    brands.dart                      # 20 Brand definitions + brandLogos map
    categories.dart                  # 6 categories (Consoles, Laptops, Smartphones, Headphones, Tablets, Accessories)
    brand_logos.dart                 # Re-exports brandLogos
  screens/
    auth/
      login_screen.dart
      create_account_screen.dart
    home/
      home_screen.dart
      widgets/
    products/
      products_screen.dart
      product_details_screen.dart
      widgets/
    categories/
      categories_screen.dart
    cart/
      cart_screen.dart
      widgets/
    checkout/
      checkout_screen.dart
      widgets/
    orders/
      orders_screen.dart
      widgets/
    profile/
      profile_screen.dart
      widgets/
    search/
      search_screen.dart
    favorites/
      favorites_screen.dart
    compare/
      compare_screen.dart
    onboarding/
      onboarding_screen.dart
      splash_screen.dart
  widgets/
    product_card.dart
    category_tabs.dart
    color_dot.dart
    app_bottom_bar.dart
assets/images/                       # 35 PNG images (snake_case)
```

## Features Completed

| Stage | Status | Description |
|-------|--------|-------------|
| 1 | ✅ | Assets renamed to snake_case, AppAssets constants, all 35 products mapped |
| 2 | ✅ | Brand/Category models, Consoles category, single Order model, PriceFormatter |
| 3 | ✅ | Global singletons → Provider (ChangeNotifierProvider for auth, cart, favorites, orders) |
| 4 | ✅ | Firebase Auth/Firestore → dedicated services (auth_service, firestore_service) |
| 5 | ✅ | Feature-based folders, split widgets/controllers, loading/empty/error states |
| 6 | ✅ | Cleanup, dart format, analyzer warnings, final folder tree |

## Running

```bash
flutter pub get
flutter run
# or
flutter build apk
```

## Build Requirements

- Flutter SDK 3.22+
- Android SDK (API 34+)
- Firebase project with Auth (email/password) + Firestore enabled
- `firebase_options.dart` generated via FlutterFire CLI# iOS Build Trigger
