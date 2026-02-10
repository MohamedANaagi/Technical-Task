/// Application-wide constants.
abstract final class AppConstants {
  AppConstants._();

  static const String baseUrl = 'https://fakestoreapi.com';
  static const String authTokenKey = 'auth_token';
  static const String favoritesKey = 'favorites_ids';
  static const String cartKey = 'cart_items';
  static const String productsCacheKey = 'products_cache';
  static const String cacheExpiryKey = 'products_cache_expiry';
  static const Duration cacheExpiry = Duration(hours: 24);
  static const int productsPageSize = 10;
  static const int connectTimeoutSeconds = 15;
  static const int receiveTimeoutSeconds = 15;
}
