import 'package:equatable/equatable.dart';

sealed class FavoritesState extends Equatable {
  const FavoritesState();
  @override
  List<Object?> get props => [];
}

final class FavoritesStateInitial extends FavoritesState {
  const FavoritesStateInitial();
}

final class FavoritesStateLoaded extends FavoritesState {
  const FavoritesStateLoaded(this.ids);
  final Set<int> ids;
  @override
  List<Object?> get props => [ids];
}
