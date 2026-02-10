import '../models/product_model.dart';

abstract interface class ProductsRemoteDataSource {
  Future<List<ProductModel>> fetchProducts();
}
