import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_local_datasource.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl(this._local);
  final FavoritesLocalDataSource _local;

  @override
  Future<Set<int>> getFavoriteIds() => _local.getFavoriteIds();

  @override
  Future<void> toggleFavorite(int productId) async {
    final isFav = await _local.isFavorite(productId);
    if (isFav) {
      await _local.removeFavorite(productId);
    } else {
      await _local.addFavorite(productId);
    }
  }

  @override
  Future<bool> isFavorite(int productId) => _local.isFavorite(productId);
}
