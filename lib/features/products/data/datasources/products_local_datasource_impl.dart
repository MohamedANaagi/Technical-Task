import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/product_model.dart';
import 'products_local_datasource.dart';

class ProductsLocalDataSourceImpl implements ProductsLocalDataSource {
  ProductsLocalDataSourceImpl(this._prefs);
  final SharedPreferences _prefs;

  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    final list = products.map((e) => e.toJson()).toList();
    await _prefs.setString(AppConstants.productsCacheKey, jsonEncode(list));
    await _prefs.setInt(
      AppConstants.cacheExpiryKey,
      DateTime.now().add(AppConstants.cacheExpiry).millisecondsSinceEpoch,
    );
  }

  @override
  Future<List<ProductModel>?> getCachedProducts() async {
    final raw = _prefs.getString(AppConstants.productsCacheKey);
    if (raw == null) return null;
    final expiry = _prefs.getInt(AppConstants.cacheExpiryKey);
    if (expiry != null && DateTime.now().millisecondsSinceEpoch > expiry) {
      return null;
    }
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> clearCache() async {
    await _prefs.remove(AppConstants.productsCacheKey);
    await _prefs.remove(AppConstants.cacheExpiryKey);
  }
}
