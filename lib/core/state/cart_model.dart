// cart_model.dart
import 'package:flutter/foundation.dart';
import '../../models/cart_item.dart';
import '../../models/product.dart';

/// ChangeNotifier that manages the shopping cart state.
class CartModel extends ChangeNotifier {
  final List<CartItem> _items = [];

  /// Read-only list of cart items.
  List<CartItem> get items => List.unmodifiable(_items);

  /// The flat shipping fee applied when subtotal is below [freeDeliveryThreshold].
  static const double deliveryFee = 50.0;

  /// Subtotal threshold above which delivery is free.
  static const double freeDeliveryThreshold = 2000.0;

  // ── Computed getters ────────────────────────────────────────────────────────

  /// Sum of (price × quantity) for every cart item.
  double get subtotal =>
      _items.fold(0.0, (sum, i) => sum + i.product.price * i.quantity);

  /// Returns 0 if [subtotal] meets [freeDeliveryThreshold]; otherwise [deliveryFee].
  double get deliveryCharge =>
      subtotal >= freeDeliveryThreshold ? 0.0 : deliveryFee;

  /// Total payable amount (subtotal + delivery).
  double get total => subtotal + deliveryCharge;

  /// Total number of individual units across all cart items.
  int get itemCount => _items.fold(0, (sum, i) => sum + i.quantity);

  // ── Mutation methods ────────────────────────────────────────────────────────

  /// Adds [p] to the cart. If [p] is already present, increments its quantity.
  void add(Product p) {
    final index = _items.indexWhere((i) => i.product.id == p.id);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product: p));
    }
    notifyListeners();
  }

  /// Removes the item with [productId] from the cart entirely.
  void remove(String productId) {
    _items.removeWhere((i) => i.product.id == productId);
    notifyListeners();
  }

  /// Increments the quantity of the item with [productId] by one.
  void increase(String productId) {
    final index = _items.indexWhere((i) => i.product.id == productId);
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  /// Decrements the quantity of the item with [productId] by one.
  /// Removes the item entirely when quantity reaches zero.
  void decrease(String productId) {
    final index = _items.indexWhere((i) => i.product.id == productId);
    if (index < 0) return;
    if (_items[index].quantity == 1) {
      _items.removeAt(index);
    } else {
      _items[index].quantity--;
    }
    notifyListeners();
  }

  /// Empties the cart.
  void clear() {
    _items.clear();
    notifyListeners();
  }
}
