import '../../../core/constants/api_constants.dart';
import '../../../core/storage/preference_service.dart';
import '../models/cart_item.dart';

abstract class CartRepository {
  Future<List<CartItem>> loadCart();

  Future<void> saveCart(List<CartItem> items);

  Future<void> clearCart();
}

/// Stores the cart on the device so it survives an app restart.
class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl({required this.preferenceService});

  final PreferenceService preferenceService;

  @override
  Future<List<CartItem>> loadCart() async {
    final raw = preferenceService.readJsonList(ApiConstants.cartKey);
    return raw.map(CartItem.fromJson).toList();
  }

  @override
  Future<void> saveCart(List<CartItem> items) async {
    await preferenceService.writeJsonList(
      ApiConstants.cartKey,
      items.map((item) => item.toJson()).toList(),
    );
  }

  @override
  Future<void> clearCart() async {
    await preferenceService.remove(ApiConstants.cartKey);
  }
}
