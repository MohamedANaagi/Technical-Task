import '../repositories/favorites_repository.dart';

class GetFavoritesIdsUseCase {
  GetFavoritesIdsUseCase(this._repository);
  final FavoritesRepository _repository;
  Future<Set<int>> call() => _repository.getFavoriteIds();
}

class ToggleFavoriteUseCase {
  ToggleFavoriteUseCase(this._repository);
  final FavoritesRepository _repository;
  Future<void> call(int productId) => _repository.toggleFavorite(productId);
}

class IsFavoriteUseCase {
  IsFavoriteUseCase(this._repository);
  final FavoritesRepository _repository;
  Future<bool> call(int productId) => _repository.isFavorite(productId);
}
