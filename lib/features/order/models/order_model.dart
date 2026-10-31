import 'package:flutter/foundation.dart';

import '../../cart/models/cart_item.dart';
import 'payment_method.dart';
import 'shipping_address.dart';

/// A placed order: what was bought, where it ships and how it was paid.
@immutable
class OrderModel {
  const OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.createdAt,
    this.status = 'Confirmed',
  });

  final String id;
  final int userId;
  final List<CartItem> items;
  final double subtotal;
  final double tax;
  final double total;
  final ShippingAddress shippingAddress;
  final PaymentMethod paymentMethod;
  final DateTime createdAt;
  final String status;

  int get itemCount =>
      items.fold(0, (total, item) => total + item.quantity);

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id: json['id']?.toString() ?? '',
    userId: (json['userId'] as num?)?.toInt() ?? 0,
    items: json['items'] is List
        ? (json['items'] as List)
              .whereType<Map>()
              .map((item) => CartItem.fromJson(Map<String, dynamic>.from(item)))
              .toList()
        : const [],
    subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
    tax: (json['tax'] as num?)?.toDouble() ?? 0,
    total: (json['total'] as num?)?.toDouble() ?? 0,
    shippingAddress: json['shippingAddress'] is Map
        ? ShippingAddress.fromJson(
            Map<String, dynamic>.from(json['shippingAddress'] as Map),
          )
        : const ShippingAddress(
            fullName: '',
            addressLine: '',
            city: '',
            postalCode: '',
            phone: '',
          ),
    paymentMethod: PaymentMethod.fromName(json['paymentMethod']?.toString()),
    createdAt:
        DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
        DateTime.now(),
    status: json['status']?.toString() ?? 'Confirmed',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'items': items.map((item) => item.toJson()).toList(),
    'subtotal': subtotal,
    'tax': tax,
    'total': total,
    'shippingAddress': shippingAddress.toJson(),
    'paymentMethod': paymentMethod.name,
    'createdAt': createdAt.toIso8601String(),
    'status': status,
  };

  OrderModel copyWith({String? status}) => OrderModel(
    id: id,
    userId: userId,
    items: items,
    subtotal: subtotal,
    tax: tax,
    total: total,
    shippingAddress: shippingAddress,
    paymentMethod: paymentMethod,
    createdAt: createdAt,
    status: status ?? this.status,
  );
}
