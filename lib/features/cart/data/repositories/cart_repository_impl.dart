import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_datasource.dart';

class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl(this._dataSource);
  final CartLocalDataSource _dataSource;

  @override
  Future<Map<int, int>> getCart() => _dataSource.getCart();

  @override
  Future<void> addToCart(int productId, {int quantity = 1}) =>
      _dataSource.addToCart(productId, quantity: quantity);

  @override
  Future<void> removeFromCart(int productId) =>
      _dataSource.removeFromCart(productId);

  @override
  Future<void> updateQuantity(int productId, int quantity) =>
      _dataSource.updateQuantity(productId, quantity);
}
