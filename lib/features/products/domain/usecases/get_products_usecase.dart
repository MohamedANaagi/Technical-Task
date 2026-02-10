import '../repositories/products_repository.dart';

class GetProductsUseCase {
  GetProductsUseCase(this._repository);
  final ProductsRepository _repository;

  Future<GetProductsResult> call({bool forceRefresh = false}) =>
      _repository.getProducts(forceRefresh: forceRefresh);
}
