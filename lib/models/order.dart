// order.dart
// Unified order domain model and line item for TechZone.

import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus {
  active,
  completed,
  cancelled;

  static OrderStatus fromString(String val) {
    switch (val.toLowerCase()) {
      case 'completed':
        return OrderStatus.completed;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'active':
      default:
        return OrderStatus.active;
    }
  }

  String get label {
    switch (this) {
      case OrderStatus.completed:
        return 'completed';
      case OrderStatus.cancelled:
        return 'cancelled';
      case OrderStatus.active:
        return 'active';
    }
  }
}

/// A single line item inside an [AppOrder].
class OrderLineItem {
  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;

  const OrderLineItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
  });

  /// Deserialises a map into an [OrderLineItem].
  factory OrderLineItem.fromMap(Map<String, dynamic> map) {
    return OrderLineItem(
      productId: map['productId'] as String? ?? '',
      productName: map['productName'] as String? ?? '',
      unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0.0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  /// Serialises to a map.
  Map<String, dynamic> toMap() => {
        'productId': productId,
        'productName': productName,
        'unitPrice': unitPrice,
        'quantity': quantity,
      };
}

/// Represents a customer order in TechZone.
class AppOrder {
  final String id;
  final String userId;
  final List<OrderLineItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String address;
  final String phone;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;

  const AppOrder({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.address,
    required this.phone,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
  });

  /// Deserialises from raw map and id.
  factory AppOrder.fromMap(String id, Map<String, dynamic> data) {
    return AppOrder(
      id: id,
      userId: data['userId'] as String? ?? '',
      items: (data['items'] as List<dynamic>? ?? [])
          .map((e) => OrderLineItem.fromMap(e as Map<String, dynamic>))
          .toList(),
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (data['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      total: (data['total'] as num?)?.toDouble() ?? 0.0,
      address: data['address'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      paymentMethod: data['paymentMethod'] as String? ?? '',
      status: data['status'] as String? ?? 'active',
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : (data['createdAt'] is String
              ? DateTime.tryParse(data['createdAt'] as String) ?? DateTime.now()
              : DateTime.now()),
    );
  }

  /// Deserialises a Firestore document into an [AppOrder].
  factory AppOrder.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return AppOrder.fromMap(doc.id, doc.data() ?? {});
  }
}

/// Backward compatibility alias
typedef Order = AppOrder;
