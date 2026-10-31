import 'package:flutter/foundation.dart';

import '../../product/models/product.dart';
import '../data/cart_repository.dart';
import '../models/cart_item.dart';

/// Owns the cart state and keeps the local copy in sync with every mutation.
class CartProvider extends ChangeNotifier {
  CartProvider({required this.repository, bool autoLoad = true}) {
    if (autoLoad) load();
  }

  static const double taxRate = 0.08;

  final CartRepository repository;

  List<CartItem> _items = [];
  bool _isLoading = false;

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  bool get isEmpty => _items.isEmpty;

  int get itemCount =>
      _items.fold(0, (total, item) => total + item.quantity);

  double get subtotal =>
      _items.fold(0.0, (total, item) => total + item.total);

  double get tax => double.parse((subtotal * taxRate).toStringAsFixed(2));

  double get total => double.parse((subtotal + tax).toStringAsFixed(2));

  int quantityOf(int productId) {
    final match = _items.where((item) => item.product.id == productId);
    return match.isEmpty ? 0 : match.first.quantity;
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      _items = await repository.loadCart();
    } catch (_) {
      _items = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adds [item], merging the quantity when the product is already in the cart.
  Future<void> add(CartItem item) async {
    final index = _items.indexWhere(
      (existing) => existing.product.id == item.product.id,
    );

    if (index >= 0) {
      final existing = _items[index];
      _items[index] = existing.copyWith(
        quantity: (existing.quantity + item.quantity).clamp(1, 99),
      );
    } else {
      _items.add(item);
    }

    notifyListeners();
    await _persist();
  }

  /// Adds a product straight from the catalog (used by the quick add button).
  Future<void> addProduct(Product product, {int quantity = 1}) =>
      add(CartItem(product: product, quantity: quantity));

  Future<void> updateQuantity(int productId, int quantity) async {
    if (quantity <= 0) return remove(productId);

    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index < 0) return;

    _items[index] = _items[index].copyWith(quantity: quantity.clamp(1, 99));
    notifyListeners();
    await _persist();
  }

  Future<void> remove(int productId) async {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
    await _persist();
  }

  Future<void> clear() async {
    _items = [];
    notifyListeners();
    await repository.clearCart();
  }

  Future<void> _persist() async {
    try {
      await repository.saveCart(_items);
    } catch (_) {
      // A failed write must never break the UI; the in-memory cart stays valid.
    }
  }
}
