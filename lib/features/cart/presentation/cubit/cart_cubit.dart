import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/cart_usecases.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit(
    this._getCart,
    this._addToCart,
    this._removeFromCart,
    this._updateQuantity,
  ) : super(const CartStateInitial());

  final GetCartUseCase _getCart;
  final AddToCartUseCase _addToCart;
  final RemoveFromCartUseCase _removeFromCart;
  final UpdateCartQuantityUseCase _updateQuantity;

  Future<void> loadCart() async {
    final items = await _getCart();
    emit(CartStateLoaded(items));
  }

  Future<void> addToCart(int productId, {int quantity = 1}) async {
    await _addToCart(productId, quantity: quantity);
    final items = await _getCart();
    emit(CartStateLoaded(items));
  }

  Future<void> removeFromCart(int productId) async {
    await _removeFromCart(productId);
    final items = await _getCart();
    emit(CartStateLoaded(items));
  }

  Future<void> updateQuantity(int productId, int quantity) async {
    await _updateQuantity(productId, quantity);
    final items = await _getCart();
    emit(CartStateLoaded(items));
  }
}
