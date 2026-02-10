import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import 'cart_local_datasource.dart';

class CartLocalDataSourceImpl implements CartLocalDataSource {
  CartLocalDataSourceImpl(this._prefs);
  final SharedPreferences _prefs;

  Map<int, int> _decode(String? raw) {
    if (raw == null) return {};
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(int.parse(k), (v as num).toInt()));
  }

  Future<void> _save(Map<int, int> cart) async {
    final encoded = jsonEncode(cart.map((k, v) => MapEntry(k.toString(), v)));
    await _prefs.setString(AppConstants.cartKey, encoded);
  }

  @override
  Future<Map<int, int>> getCart() async {
    final raw = _prefs.getString(AppConstants.cartKey);
    return _decode(raw);
  }

  @override
  Future<void> addToCart(int productId, {int quantity = 1}) async {
    final cart = await getCart();
    cart[productId] = (cart[productId] ?? 0) + quantity;
    await _save(cart);
  }

  @override
  Future<void> removeFromCart(int productId) async {
    final cart = await getCart();
    cart.remove(productId);
    await _save(cart);
  }

  @override
  Future<void> updateQuantity(int productId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(productId);
      return;
    }
    final cart = await getCart();
    cart[productId] = quantity;
    await _save(cart);
  }
}
