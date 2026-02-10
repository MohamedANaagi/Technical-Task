abstract interface class FavoritesRepository {
  Future<Set<int>> getFavoriteIds();
  Future<void> toggleFavorite(int productId);
  Future<bool> isFavorite(int productId);
}
