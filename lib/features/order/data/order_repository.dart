import '../../../core/constants/api_constants.dart';
import '../../../core/storage/preference_service.dart';
import '../models/order_model.dart';

abstract class OrderRepository {
  Future<List<OrderModel>> loadOrders();

  Future<void> saveOrder(OrderModel order);
}

/// Orders are kept on the device, newest first, so the history survives an app
/// restart without needing a backend.
class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl({required this.preferenceService});

  final PreferenceService preferenceService;

  @override
  Future<List<OrderModel>> loadOrders() async {
    final raw = preferenceService.readJsonList(ApiConstants.ordersKey);
    final orders = raw.map(OrderModel.fromJson).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return orders;
  }

  @override
  Future<void> saveOrder(OrderModel order) async {
    final orders = await loadOrders();
    orders.removeWhere((existing) => existing.id == order.id);
    orders.insert(0, order);
    await preferenceService.writeJsonList(
      ApiConstants.ordersKey,
      orders.map((item) => item.toJson()).toList(),
    );
  }
}
