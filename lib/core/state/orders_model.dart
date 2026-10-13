// orders_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/cart_item.dart';
import '../../models/order.dart';

export '../../models/order.dart';

// ── Model ────────────────────────────────────────────────────────────────────

/// ChangeNotifier that manages the current user's orders via Firestore.
class OrdersModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<AppOrder> _orders = [];

  /// The list of orders loaded for the signed-in user, most recent first.
  List<AppOrder> get orders => List.unmodifiable(_orders);

  // ── Firestore helpers ────────────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> _ordersRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('orders');

  // ── Public API ───────────────────────────────────────────────────────────────

  /// Fetches orders for [uid] from Firestore, ordered by creation time
  /// descending, and rebuilds the local list.
  Future<void> loadOrders(String uid) async {
    final snapshot = await _ordersRef(uid)
        .orderBy('createdAt', descending: true)
        .get();

    _orders = snapshot.docs
        .map((doc) =>
            AppOrder.fromDoc(doc as DocumentSnapshot<Map<String, dynamic>>))
        .toList();

    notifyListeners();
  }

  /// Writes a new order to Firestore under `users/{uid}/orders` and appends
  /// it to the local list. Returns the generated Firestore document ID.
  Future<String> placeOrder({
    required String uid,
    required List<CartItem> items,
    required double subtotal,
    required double deliveryFee,
    required double total,
    required String address,
    required String phone,
    required String paymentMethod,
  }) async {
    final lineItems = items
        .map(
          (ci) => OrderLineItem(
            productId: ci.product.id,
            productName: ci.product.name,
            unitPrice: ci.product.price,
            quantity: ci.quantity,
          ),
        )
        .toList();

    final docRef = _ordersRef(uid).doc();

    final now = Timestamp.now();

    await docRef.set({
      'userId': uid,
      'items': lineItems.map((li) => li.toMap()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'address': address,
      'phone': phone,
      'paymentMethod': paymentMethod,
      'status': 'active',
      'createdAt': now,
    });

    // Optimistically prepend the new order so the UI updates immediately.
    _orders.insert(
      0,
      AppOrder(
        id: docRef.id,
        userId: uid,
        items: lineItems,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        total: total,
        address: address,
        phone: phone,
        paymentMethod: paymentMethod,
        status: 'active',
        createdAt: now.toDate(),
      ),
    );

    notifyListeners();
    return docRef.id;
  }

  /// Clears the locally cached orders (e.g., on sign-out).
  void clear() {
    _orders = [];
    notifyListeners();
  }
}
