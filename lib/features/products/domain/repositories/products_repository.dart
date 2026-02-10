import '../entities/product.dart';

class GetProductsResult {
  const GetProductsResult({required this.products, this.fromCache = false});
  final List<Product> products;
  final bool fromCache;
}

abstract interface class ProductsRepository {
  Future<GetProductsResult> getProducts({bool forceRefresh = false});
}
