import 'package:flutter/foundation.dart';

import '../../product/models/product.dart';

/// One line of the shopping cart: a [Product] plus how many of it were added.
@immutable
class CartItem {
  const CartItem({required this.product, this.quantity = 1});

  final Product product;
  final int quantity;

  double get total => product.discountedPrice * quantity;

  CartItem copyWith({Product? product, int? quantity}) => CartItem(
    product: product ?? this.product,
    quantity: quantity ?? this.quantity,
  );

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final rawProduct = json['product'];
    return CartItem(
      product: Product.fromMap(
        rawProduct is Map ? Map<String, dynamic>.from(rawProduct) : const {},
      ),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'product': product.toMap(),
    'quantity': quantity,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CartItem &&
          other.product.id == product.id &&
          other.quantity == quantity);

  @override
  int get hashCode => Object.hash(product.id, quantity);

  @override
  String toString() => 'CartItem(${product.title} × $quantity)';
}
