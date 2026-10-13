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
    theme/
      app_colors.dart, app_theme.dart
    state/
      auth_model.dart                # Firebase Auth wrapper (ChangeNotifier)
      cart_model.dart                # Shopping cart state (ChangeNotifier)
      favorites_model.dart           # Favorites set (ChangeNotifier)
      orders_model.dart              # Firestore orders sync (ChangeNotifier)
      cart_item.dart                 # Cart line item
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
    splash.dart
    onboarding.dart
    login.dart
    create_account.dart
    home.dart
    categories.dart
    products.dart
    product_details.dart
    search.dart
    compare_products.dart
    favorites.dart
    cart.dart
    checkout.dart
    orders.dart
    profile.dart
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
| 4 | 🔄 | Firebase Auth/Firestore → dedicated services (auth_service, firestore_service) |
| 5 | ⏳ | Feature-based folders, split widgets/controllers, loading/empty/error states |
| 6 | ⏳ | Cleanup, dart format, analyzer warnings, final folder tree |

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
- `firebase_options.dart` generated via FlutterFire CLI