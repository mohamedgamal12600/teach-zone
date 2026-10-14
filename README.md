# TechZone Flutter App

Flutter mobile storefront for TechZone, an electronics and gaming retailer. The app uses Material 3, Poppins typography, Provider state management, Firebase Authentication, and Cloud Firestore.

> **Integration status:** The app and website use the same Firebase project, but their Firestore profile and order schemas are not yet compatible. The website's deployed rules reject the Flutter app's current profile/order writes. See [Firebase integration and known gaps](#firebase-integration-and-known-gaps) before treating checkout as production-ready.

## Project at a glance

- **Firebase project:** `teach-zone-adec7`
- **Dart constraint:** `^3.7.0` (see `pubspec.yaml`)
- **Catalog:** 35 locally defined products, 20 brands, and 6 categories
- **Currency:** EGP
- **Primary platforms:** Android and iOS
- **Separate web storefront:** [teach-zone-web](https://github.com/mohamedgamal12600/teach-zone-web/tree/fix/final-audit)

The Flutter catalog is defined in `lib/data/products.dart` and rendered from bundled assets. It is not a live Firestore product subscription. The website reads the corresponding 35 records from Firestore; updates are not automatically synchronized between the app source and the web catalog.

## Features

- Splash/onboarding flow and authenticated/guest entry.
- Email/password sign-in, account creation, password reset, and profile editing through Firebase Authentication.
- Home/product browsing, category filtering, product details, search, and brand navigation.
- Local cart state, checkout form, and order-history UI.
- Favorites and product comparison.
- Loading, empty, and error states throughout the main user flows.
- TechZone app icon and splash branding for Android, iOS, and the Flutter splash screen.

The app does **not** integrate card payments. Before accepting real orders, resolve the Firestore order-schema/security gap described below.

## Architecture

| Area | Location | Responsibility |
|---|---|---|
| Bootstrap and routes | `lib/main.dart` | Firebase initialization, providers, named routes, and route generation |
| Product/catalog models | `lib/models/`, `lib/data/` | Product, brand, category, order models and static catalog |
| App state | `lib/core/state/` | Provider/ChangeNotifier state for auth, cart, favorites, and orders |
| Firebase services | `lib/core/services/` | Authentication/profile operations and Firestore order operations |
| Screens | `lib/screens/` | Auth, home, product, category, cart, checkout, order, profile, search, favorites, compare, onboarding |
| Shared widgets | `lib/widgets/`, feature `widgets/` | Product cards, tabs, navigation, and screen-specific components |
| App theme/assets | `lib/core/theme/`, `lib/core/constants/`, `assets/` | Colors, Material theme, asset paths, product imagery, and splash artwork |

### Main models

- `Product`: ID, brand, name, category, local image path, price/optional old price, colors, ratings/statistics, description, and specifications.
- `Brand` and `Category`: display metadata for browsing and filtering.
- `AppOrder` / `OrderLineItem`: order header and line-item data used by the Flutter order screens.

## Repository layout

```text
lib/
  main.dart
  core/
    constants/  services/  state/  theme/  utils/
  data/         # products.dart, brands.dart, categories.dart
  models/       # Product, Brand, Category, AppOrder
  screens/      # auth, home, products, cart, checkout, orders, profile, etc.
  widgets/
assets/
  images/       # 35 product images and TechZone splash logo
  branding/     # icon source artwork
android/        # launcher/adaptive icon and Android splash resources
ios/            # AppIcon, LaunchImage, and LaunchScreen assets
```

## Local development

Use a Flutter/Dart SDK compatible with the `^3.7.0` constraint and the Android/iOS toolchains required for the platform you are building.

```bash
flutter pub get
flutter analyze
flutter run
```

There is no `test/` directory in this repository yet; add a Flutter test suite before using `flutter test` as a project check.

Android debug build:

```bash
flutter build apk --debug
```

To avoid dependency resolution during a repeat build after packages have already been resolved:

```bash
flutter build apk --debug --no-pub
```

iOS builds require macOS, Xcode, and the usual CocoaPods setup. A Windows machine can build/test the Android target, but cannot produce a native iOS build.

## Firebase configuration

- FlutterFire configuration is in `lib/firebase_options.dart`; its project ID is `teach-zone-adec7`.
- Enable Firebase Authentication's Email/Password provider and configure the required authorized domains in Firebase Console.
- Enable Cloud Firestore and review security rules before using account or order features.
- Firebase client configuration is public application configuration. Do not add service-account JSON files or Admin private keys to this repository.

## Firebase integration and known gaps

The website repository is configured for the same Firebase project. Its current Firestore rules and web order flow are **not** compatible with the Flutter app's existing writes:

1. **User profile shape:** Flutter's `AuthService` writes `users/{uid}` fields such as `uid`, `fullName`, `email`, `createdAt`, and `updatedAt`. The website rules currently allow only `name`, `email`, `phone`, and `createdAt`, with `name` and `phone` required. The app catches profile-write failures, so Firebase Authentication account creation may succeed while the Firestore profile is not saved.
2. **Order path and trust boundary:** Flutter writes directly to `users/{uid}/orders/{orderId}` and sends item prices, subtotal, delivery fee, and total from the client. The website uses an authenticated callable `createOrder` function that reads product prices on the server and writes to top-level `orders/{orderId}`. The deployed website rules deny client order creation and do not grant the Flutter nested order path. Flutter checkout is therefore not interoperable with the deployed rules and its client-priced order writes should not be used as a production trust boundary.
3. **Function deployment:** The website's `createOrder` function exists in source but was not deployed; the last deployment attempt required a Firebase Blaze billing plan to enable/deploy Cloud Functions. Website checkout order placement is not available until the function is deployed and end-to-end tested.

**Recommended integration:** agree on one profile contract, route both clients through the server-side order function, use Firestore product prices as authoritative, and align order status/model fields (the web function uses `pending`/`cancelled`; the Flutter model currently defaults to `active`). Test the rules and function in a staging project or emulator before changing production rules.

## Branding

- Flutter splash artwork: `assets/images/techzone_splash_logo.png`.
- Android launcher/adaptive icon and splash resources: `android/app/src/main/res/`.
- iOS icons and launch screen: `ios/Runner/Assets.xcassets/` and `ios/Runner/Base.lproj/LaunchScreen.storyboard`.
- The icon/splash setup does not require an additional Dart package.

## Verification snapshot

Verified on 2026-10-14:

- `flutter analyze` — passed with no issues.
- `flutter build apk --debug --no-pub` — passed.
- iOS build was not run in this Windows environment.

## Design attribution

The original storefront UI design is attributed to **Heba Zatar**, “Free Electronics E-Commerce App” (free for personal use). Check the original design and individual product-image licenses before commercial redistribution.

## Duplicate-file audit (2026-10-14)

An exact SHA-256 comparison of the app tree (excluding generated build/dependency caches) found one product-art pair with identical bytes: `assets/images/ps5.png` and `assets/images/ps5_digital.png` (340,390 bytes each). They represent different catalog items, so verify that the shared artwork is intentional before replacing either image. The remaining exact matches are platform/build-slot files (iOS icon slots, Android debug/profile manifests, Xcode workspace metadata, and Flutter Debug/Release config); their separate paths are referenced by their platform projects and should not be deleted solely because the bytes match.

The product artwork is also copied into the separate website repository under numbered names so each app can be built/hosted independently; those cross-repository copies are expected.
