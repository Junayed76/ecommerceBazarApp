import 'package:bazaar_app/features/cart/data/cart_repository.dart';
import 'package:bazaar_app/features/cart/models/cart_item.dart';
import 'package:bazaar_app/features/cart/provider/cart_provider.dart';
import 'package:bazaar_app/features/product/models/product.dart';
import 'package:flutter_test/flutter_test.dart';

class _InMemoryCartRepository implements CartRepository {
  List<CartItem> stored = [];
  int saveCount = 0;

  @override
  Future<List<CartItem>> loadCart() async => List.of(stored);

  @override
  Future<void> saveCart(List<CartItem> items) async {
    stored = List.of(items);
    saveCount++;
  }

  @override
  Future<void> clearCart() async {
    stored = [];
  }
}

const _headphones = Product(
  id: 1,
  title: 'Headphones',
  price: 100,
  discountPercentage: 10,
);
const _charger = Product(id: 2, title: 'Charger', price: 50);

void main() {
  group('CartItem', () {
    test('total uses the discounted price', () {
      const item = CartItem(product: _headphones, quantity: 3);

      expect(item.total, 270);
    });

    test('survives a json round trip', () {
      const item = CartItem(product: _charger, quantity: 2);

      final restored = CartItem.fromJson(item.toJson());

      expect(restored.product.id, 2);
      expect(restored.product.title, 'Charger');
      expect(restored.quantity, 2);
      expect(restored.total, 100);
    });
  });

  group('CartProvider', () {
    late _InMemoryCartRepository repository;
    late CartProvider cart;

    setUp(() {
      repository = _InMemoryCartRepository();
      cart = CartProvider(repository: repository, autoLoad: false);
    });

    test('add inserts a new line and persists it', () async {
      await cart.add(const CartItem(product: _headphones));

      expect(cart.items.length, 1);
      expect(cart.itemCount, 1);
      expect(repository.stored.length, 1);
    });

    test('add merges quantities for the same product', () async {
      await cart.add(const CartItem(product: _headphones, quantity: 2));
      await cart.add(const CartItem(product: _headphones, quantity: 3));

      expect(cart.items.length, 1);
      expect(cart.items.single.quantity, 5);
    });

    test('totals include the tax rate', () async {
      await cart.add(const CartItem(product: _headphones, quantity: 2));

      expect(cart.subtotal, 180);
      expect(cart.tax, closeTo(14.4, 0.001));
      expect(cart.total, closeTo(194.4, 0.001));
    });

    test('updateQuantity changes the line and clamps at one', () async {
      await cart.add(const CartItem(product: _charger, quantity: 2));
      await cart.updateQuantity(2, 4);
      expect(cart.items.single.quantity, 4);

      await cart.updateQuantity(2, 0);
      expect(cart.items, isEmpty);
    });

    test('remove deletes the line', () async {
      await cart.add(const CartItem(product: _headphones));
      await cart.add(const CartItem(product: _charger));

      await cart.remove(1);

      expect(cart.items.length, 1);
      expect(cart.items.single.product.id, 2);
    });

    test('clear empties the cart', () async {
      await cart.add(const CartItem(product: _headphones));

      await cart.clear();

      expect(cart.items, isEmpty);
      expect(cart.total, 0);
    });

    test('load restores a previously saved cart', () async {
      repository.stored = [const CartItem(product: _charger, quantity: 2)];

      await cart.load();

      expect(cart.items.length, 1);
      expect(cart.itemCount, 2);
    });
  });
}
