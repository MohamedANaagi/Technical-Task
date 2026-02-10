import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/favorites_usecases.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit(this._getIds, this._toggle, this._isFavorite)
    : super(const FavoritesStateInitial());

  final GetFavoritesIdsUseCase _getIds;
  final ToggleFavoriteUseCase _toggle;
  final IsFavoriteUseCase _isFavorite;

  Future<void> loadFavorites() async {
    final ids = await _getIds();
    emit(FavoritesStateLoaded(ids));
  }

  Future<void> toggleFavorite(int productId) async {
    await _toggle(productId);
    final ids = await _getIds();
    emit(FavoritesStateLoaded(ids));
  }

  Future<bool> isFavorite(int productId) => _isFavorite(productId);
}
