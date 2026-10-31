import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../models/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts({String? category, String? query});

  Future<Product> getProductById(int id);

  Future<List<String>> getCategories();
}

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl({required this.dioClient});

  final DioClient dioClient;

  @override
  Future<List<Product>> getProducts({String? category, String? query}) async {
    final search = query?.trim() ?? '';
    final selectedCategory = category?.trim() ?? '';

    final String path;
    final Map<String, dynamic> params = {'limit': 40};

    if (search.isNotEmpty) {
      path = ApiConstants.productSearch;
      params['q'] = search;
    } else if (selectedCategory.isNotEmpty) {
      path = ApiConstants.productsByCategory(selectedCategory);
    } else {
      path = ApiConstants.products;
    }

    final response = await dioClient.get(path, queryParameters: params);
    return _parseProducts(response.data);
  }

  @override
  Future<Product> getProductById(int id) async {
    final response = await dioClient.get(ApiConstants.productById(id));
    final data = response.data;
    if (data is Map) {
      return Product.fromMap(Map<String, dynamic>.from(data));
    }
    throw const NotFoundException('This product could not be loaded.');
  }

  @override
  Future<List<String>> getCategories() async {
    final response = await dioClient.get(ApiConstants.productCategories);
    final data = response.data;
    if (data is! List) return const [];

    return data
        .map((item) {
          if (item is Map) {
            return (item['slug'] ?? item['name'] ?? '').toString();
          }
          return item.toString();
        })
        .where((name) => name.isNotEmpty)
        .toList();
  }

  /// The products endpoint answers either with a bare list or with a wrapper
  /// object `{ products: [...] }`, so both shapes are handled here.
  List<Product> _parseProducts(dynamic data) {
    final List<dynamic> raw;
    if (data is Map && data['products'] is List) {
      raw = data['products'] as List<dynamic>;
    } else if (data is List) {
      raw = data;
    } else {
      return const [];
    }

    return raw
        .whereType<Map>()
        .map((item) => Product.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }
}
