# TechZone – Electronics Store

A Flutter e-commerce app for electronics, built with Material 3 and Google Fonts (Poppins).

## Design Attribution

Design by **Heba Zatar** – "Free Electronics E-Commerce App" (free for personal use).

## Tech Stack

- Flutter + Dart 3.7+
- Material 3 (`useMaterial3: true`)
- `google_fonts` (Poppins)
- State: `setState` + `ChangeNotifier` / `ListenableBuilder`
- Navigation: named routes + `onGenerateRoute`

## Folder Structure

```
lib/
  main.dart
  core/theme/        app_colors.dart, app_theme.dart
  core/state/        cart_model.dart, favorites_model.dart   (Phase 2)
  models/            product.dart, cart_item.dart, order.dart
  data/              products.dart
  screens/           splash, home, categories, product_details,
                     cart, profile  (+ more in later phases)
  widgets/           product_card.dart, category_tabs.dart,
                     color_dot.dart, app_bottom_bar.dart
assets/images/       ps5.png, ps5_digital.png, pulse_3d.png,
                     dualsense.png, charging_station.png, media_remote.png
```

## Phases

| Phase | Status | Contents |
|-------|--------|----------|
| 1 | ✅ Done | Splash, Home, Product Details, Categories, Cart/Profile placeholders |
| 2 | ⏳ | Favorites, Cart (full), EGP pricing |
| 3 | ⏳ | Search/filter, Compare, Checkout, Orders |
| 4 | ⏳ | Firebase Auth + Firestore |
