import 'package:bazaar_app/features/auth/models/user_model.dart';
import 'package:bazaar_app/features/cart/models/cart_item.dart';
import 'package:bazaar_app/features/order/data/order_repository.dart';
import 'package:bazaar_app/features/order/models/order_model.dart';
import 'package:bazaar_app/features/order/models/payment_method.dart';
import 'package:bazaar_app/features/order/models/shipping_address.dart';
import 'package:bazaar_app/features/order/provider/order_provider.dart';
import 'package:bazaar_app/features/product/models/product.dart';
import 'package:flutter_test/flutter_test.dart';

class _InMemoryOrderRepository implements OrderRepository {
  List<OrderModel> stored = [];

  @override
  Future<List<OrderModel>> loadOrders() async => List.of(stored);

  @override
  Future<void> saveOrder(OrderModel order) async {
    stored = [order, ...stored];
  }
}

const _address = ShippingAddress(
  fullName: 'Nusrat Jahan',
  addressLine: 'House 12, Road 4',
  city: 'Dhaka',
  postalCode: '1200',
  phone: '01700000000',
);

const _items = [
  CartItem(
    product: Product(id: 1, title: 'Keyboard', price: 60),
    quantity: 2,
  ),
];

const _user = UserModel(id: 5, username: 'nusrat', firstName: 'Nusrat');

void main() {
  group('OrderModel', () {
    final order = OrderModel(
      id: 'BZR-1',
      userId: 5,
      items: _items,
      subtotal: 120,
      tax: 9.6,
      total: 129.6,
      shippingAddress: _address,
      paymentMethod: PaymentMethod.card,
      createdAt: DateTime(2026, 11, 1, 10, 30),
    );

    test('counts the total number of products', () {
      expect(order.itemCount, 2);
    });

    test('survives a json round trip', () {
      final restored = OrderModel.fromJson(order.toJson());

      expect(restored.id, 'BZR-1');
      expect(restored.userId, 5);
      expect(restored.total, 129.6);
      expect(restored.paymentMethod, PaymentMethod.card);
      expect(restored.shippingAddress.city, 'Dhaka');
      expect(restored.items.single.product.title, 'Keyboard');
      expect(restored.createdAt, order.createdAt);
    });

    test('unknown payment names fall back to cash on delivery', () {
      expect(
        PaymentMethod.fromName('bitcoin'),
        PaymentMethod.cashOnDelivery,
      );
    });
  });

  group('OrderProvider', () {
    late _InMemoryOrderRepository repository;
    late OrderProvider orders;

    setUp(() {
      repository = _InMemoryOrderRepository();
      orders = OrderProvider(repository: repository, autoLoad: false);
    });

    test('placeOrder stores the order and exposes it as lastOrder', () async {
      final placed = await orders.placeOrder(
        items: _items,
        subtotal: 120,
        tax: 9.6,
        total: 129.6,
        address: _address,
        user: _user,
      );

      expect(placed, isNotNull);
      expect(placed!.id, startsWith('BZR-'));
      expect(orders.orders.length, 1);
      expect(orders.lastOrder, placed);
      expect(repository.stored.single.id, placed.id);
    });

    test('placeOrder refuses an empty cart', () async {
      final placed = await orders.placeOrder(
        items: const [],
        subtotal: 0,
        tax: 0,
        total: 0,
        address: _address,
        user: _user,
      );

      expect(placed, isNull);
      expect(orders.errorMessage, isNotNull);
      expect(orders.orders, isEmpty);
    });

    test('ordersFor filters by user id', () async {
      await orders.placeOrder(
        items: _items,
        subtotal: 120,
        tax: 9.6,
        total: 129.6,
        address: _address,
        user: _user,
      );

      expect(orders.ordersFor(5).length, 1);
      expect(orders.ordersFor(99), isEmpty);
    });

    test('selectPaymentMethod notifies only on change', () {
      var notifications = 0;
      orders.addListener(() => notifications++);

      orders.selectPaymentMethod(PaymentMethod.wallet);
      orders.selectPaymentMethod(PaymentMethod.wallet);

      expect(orders.selectedPaymentMethod, PaymentMethod.wallet);
      expect(notifications, 1);
    });
  });
}
