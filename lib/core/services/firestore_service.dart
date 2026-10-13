// firestore_service.dart
// Centralized Firestore operations for orders and user data.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/cart_item.dart';
import '../../models/order.dart';

/// Service encapsulating all Firestore reads/writes for orders.
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _ordersRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('orders');

  /// Fetches orders for [uid] from Firestore, ordered by creation time descending.
  Future<List<AppOrder>> fetchOrders(String uid) async {
    final snapshot = await _ordersRef(uid)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) =>
            AppOrder.fromDoc(doc as DocumentSnapshot<Map<String, dynamic>>))
        .toList();
  }

  /// Writes a new order to Firestore under `users/{uid}/orders`.
  /// Returns the generated Firestore document ID.
  Future<String> createOrder({
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

    return docRef.id;
  }
}