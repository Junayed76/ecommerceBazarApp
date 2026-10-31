import 'package:flutter/foundation.dart';

import '../../../core/network/api_exceptions.dart';
import '../data/product_repository.dart';
import '../models/product.dart';

/// Holds the catalog state: the product list, the category filter, the search
/// term and the currently opened product.
class ProductProvider extends ChangeNotifier {
  ProductProvider({required this.repository, bool autoLoad = true}) {
    if (autoLoad) {
      loadProducts();
      loadCategories();
    }
  }

  static const String allCategory = 'All';

  final ProductRepository repository;

  List<Product> _products = [];
  List<String> _categories = const [allCategory];
  Product? _selectedProduct;
  String _selectedCategory = allCategory;
  String _searchQuery = '';
  bool _isLoading = false;
  bool _isLoadingDetail = false;
  String? _errorMessage;

  List<Product> get products => List.unmodifiable(_products);
  List<String> get categories => _categories;
  Product? get selectedProduct => _selectedProduct;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get errorMessage => _errorMessage;

  bool get hasProducts => _products.isNotEmpty;

  /// Loads (or reloads) the catalog using the active filter and search term.
  Future<void> loadProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await repository.getProducts(
        category: _selectedCategory == allCategory ? null : _selectedCategory,
        query: _searchQuery.isEmpty ? null : _searchQuery,
      );
    } on ApiException catch (error) {
      _errorMessage = error.message;
      _products = [];
    } catch (error) {
      _errorMessage = 'Something went wrong while loading products.';
      _products = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCategories() async {
    try {
      final fetched = await repository.getCategories();
      if (fetched.isEmpty) return;
      _categories = [allCategory, ...fetched];
      notifyListeners();
    } catch (_) {
      // The category bar is optional: keep the "All" chip when it fails.
    }
  }

  /// Loads a single product for the details screen. If the product is already
  /// in the catalog it is shown immediately and refreshed in the background.
  Future<void> loadProduct(int id) async {
    final cached = _products.where((product) => product.id == id).firstOrNull;
    _selectedProduct = cached;
    _isLoadingDetail = cached == null;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedProduct = await repository.getProductById(id);
    } on ApiException catch (error) {
      if (cached == null) _errorMessage = error.message;
    } catch (_) {
      if (cached == null) {
        _errorMessage = 'This product could not be loaded.';
      }
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  void selectCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    loadProducts();
  }

  void search(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    loadProducts();
  }

  void clearFilters() {
    _selectedCategory = allCategory;
    _searchQuery = '';
    loadProducts();
  }

  @override
  void dispose() {
    _products = [];
    super.dispose();
  }
}
