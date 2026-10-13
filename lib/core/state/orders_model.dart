// orders_model.dart
import 'package:flutter/foundation.dart';
import '../../models/cart_item.dart';
import '../../models/order.dart';
import '../services/firestore_service.dart';

export '../../models/order.dart';

/// ChangeNotifier that manages the current user's orders via [FirestoreService].
class OrdersModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<AppOrder> _orders = [];
  bool _isLoading = false;
  String? _error;

  /// The list of orders loaded for the signed-in user, most recent first.
  List<AppOrder> get orders => List.unmodifiable(_orders);

  /// Whether orders are currently being fetched or placed.
  bool get isLoading => _isLoading;

  /// Last error message encountered, if any.
  String? get error => _error;

  // Public API

  /// Fetches orders for [uid] from Firestore, ordered by creation time
  /// descending, and rebuilds the local list.
  Future<void> loadOrders(String uid) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _firestoreService.fetchOrders(uid);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Writes a new order to Firestore under `users/{uid}/orders` and appends
  /// it to the local list. Returns the generated Firestore document ID.
  Future<String> placeOrder({
    required String uid,
    String customerName = '',
    required List<CartItem> items,
    required double subtotal,
    required double deliveryFee,
    required double total,
    required String address,
    required String phone,
    required String paymentMethod,
  }) async {
    final orderId = await _firestoreService.createOrder(
      uid: uid,
      customerName: customerName,
      items: items,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      total: total,
      address: address,
      phone: phone,
      paymentMethod: paymentMethod,
    );

    await loadOrders(uid);
    return orderId;
  }

  /// Clears the locally cached orders (e.g., on sign-out).
  void clear() {
    _orders = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}

