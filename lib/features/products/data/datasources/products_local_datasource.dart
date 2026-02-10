import '../models/product_model.dart';

abstract interface class ProductsLocalDataSource {
  Future<void> cacheProducts(List<ProductModel> products);
  Future<List<ProductModel>?> getCachedProducts();
  Future<void> clearCache();
}
