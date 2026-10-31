import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../auth/models/user_model.dart';
import '../../cart/models/cart_item.dart';
import '../data/order_repository.dart';
import '../models/order_model.dart';
import '../models/payment_method.dart';
import '../models/shipping_address.dart';

/// Checkout state: the chosen payment method, the placed orders and the
/// submission flags used by the UI.
class OrderProvider extends ChangeNotifier {
  OrderProvider({required this.repository, bool autoLoad = true}) {
    if (autoLoad) loadOrders();
  }

  final OrderRepository repository;

  List<OrderModel> _orders = [];
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cashOnDelivery;
  OrderModel? _lastOrder;
  bool _isLoading = false;
  bool _isPlacing = false;
  String? _errorMessage;

  List<OrderModel> get orders => List.unmodifiable(_orders);
  PaymentMethod get selectedPaymentMethod => _selectedPaymentMethod;
  OrderModel? get lastOrder => _lastOrder;
  bool get isLoading => _isLoading;
  bool get isPlacing => _isPlacing;
  String? get errorMessage => _errorMessage;

  List<OrderModel> ordersFor(int userId) =>
      _orders.where((order) => order.userId == userId).toList();

  void selectPaymentMethod(PaymentMethod method) {
    if (_selectedPaymentMethod == method) return;
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  Future<void> loadOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      _orders = await repository.loadOrders();
    } catch (_) {
      _orders = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Creates the order, stores it and exposes it as [lastOrder].
  Future<OrderModel?> placeOrder({
    required List<CartItem> items,
    required double subtotal,
    required double tax,
    required double total,
    required ShippingAddress address,
    required UserModel user,
  }) async {
    if (items.isEmpty) {
      _errorMessage = 'Your cart is empty.';
      notifyListeners();
      return null;
    }

    _isPlacing = true;
    _errorMessage = null;
    notifyListeners();

    final order = OrderModel(
      id: _generateOrderId(),
      userId: user.id,
      items: List.of(items),
      subtotal: subtotal,
      tax: tax,
      total: total,
      shippingAddress: address,
      paymentMethod: _selectedPaymentMethod,
      createdAt: DateTime.now(),
    );

    try {
      await repository.saveOrder(order);
      _orders = [order, ..._orders];
      _lastOrder = order;
      _isPlacing = false;
      notifyListeners();
      return order;
    } catch (_) {
      _errorMessage = 'We could not save your order. Please try again.';
      _isPlacing = false;
      notifyListeners();
      return null;
    }
  }

  void clearLastOrder() {
    _lastOrder = null;
    notifyListeners();
  }

  /// Resets checkout state after sign out.
  void reset() {
    _orders = [];
    _lastOrder = null;
    _selectedPaymentMethod = PaymentMethod.cashOnDelivery;
    _errorMessage = null;
    notifyListeners();
  }

  String _generateOrderId() {
    final random = Random().nextInt(9000) + 1000;
    return 'BZR-${DateTime.now().millisecondsSinceEpoch}-$random';
  }
}
