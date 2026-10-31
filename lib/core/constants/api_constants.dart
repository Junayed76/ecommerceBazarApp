/// Every network endpoint and storage key used by the app lives here so that
/// nothing else in the codebase has to hard-code a URL or a preference key.
class ApiConstants {
  ApiConstants._();

  /// DummyJSON is used as a free, credential-free demo backend for products
  /// and authentication.
  static const String baseUrl = 'https://dummyjson.com';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);

  // ---- Product endpoints -------------------------------------------------
  static const String products = '/products';
  static const String productSearch = '/products/search';
  static const String productCategories = '/products/categories';

  static String productById(int id) => '/products/$id';

  static String productsByCategory(String category) =>
      '/products/category/$category';

  // ---- Auth endpoints ----------------------------------------------------
  static const String login = '/auth/login';
  static const String currentUser = '/auth/me';

  // ---- SharedPreferences keys -------------------------------------------
  static const String accessTokenKey = 'access_token';
  static const String userKey = 'auth_user';
  static const String cartKey = 'cart_items';
  static const String ordersKey = 'orders';
}
