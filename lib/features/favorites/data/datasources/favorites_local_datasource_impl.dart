import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import 'favorites_local_datasource.dart';

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  FavoritesLocalDataSourceImpl(this._prefs);
  final SharedPreferences _prefs;

  @override
  Future<Set<int>> getFavoriteIds() async {
    final raw = _prefs.getString(AppConstants.favoritesKey);
    if (raw == null) return {};
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => (e as num).toInt()).toSet();
  }

  @override
  Future<void> addFavorite(int productId) async {
    final set = await getFavoriteIds();
    set.add(productId);
    await _prefs.setString(AppConstants.favoritesKey, jsonEncode(set.toList()));
  }

  @override
  Future<void> removeFavorite(int productId) async {
    final set = await getFavoriteIds();
    set.remove(productId);
    await _prefs.setString(AppConstants.favoritesKey, jsonEncode(set.toList()));
  }

  @override
  Future<bool> isFavorite(int productId) async {
    final set = await getFavoriteIds();
    return set.contains(productId);
  }
}
