import '../repositories/cart_repository.dart';

class GetCartUseCase {
  GetCartUseCase(this._repository);
  final CartRepository _repository;
  Future<Map<int, int>> call() => _repository.getCart();
}

class AddToCartUseCase {
  AddToCartUseCase(this._repository);
  final CartRepository _repository;
  Future<void> call(int productId, {int quantity = 1}) =>
      _repository.addToCart(productId, quantity: quantity);
}

class RemoveFromCartUseCase {
  RemoveFromCartUseCase(this._repository);
  final CartRepository _repository;
  Future<void> call(int productId) => _repository.removeFromCart(productId);
}

class UpdateCartQuantityUseCase {
  UpdateCartQuantityUseCase(this._repository);
  final CartRepository _repository;
  Future<void> call(int productId, int quantity) =>
      _repository.updateQuantity(productId, quantity);
}
