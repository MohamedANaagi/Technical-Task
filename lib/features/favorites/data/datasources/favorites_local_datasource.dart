abstract interface class FavoritesLocalDataSource {
  Future<Set<int>> getFavoriteIds();
  Future<void> addFavorite(int productId);
  Future<void> removeFavorite(int productId);
  Future<bool> isFavorite(int productId);
}
