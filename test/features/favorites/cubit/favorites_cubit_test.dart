import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:technica_task/features/favorites/domain/usecases/favorites_usecases.dart';
import 'package:technica_task/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:technica_task/features/favorites/presentation/cubit/favorites_state.dart';

class MockGetFavoritesIdsUseCase extends Mock
    implements GetFavoritesIdsUseCase {}

class MockToggleFavoriteUseCase extends Mock implements ToggleFavoriteUseCase {}

class MockIsFavoriteUseCase extends Mock implements IsFavoriteUseCase {}

void main() {
  late MockGetFavoritesIdsUseCase mockGetIds;
  late MockToggleFavoriteUseCase mockToggle;
  late MockIsFavoriteUseCase mockIsFavorite;

  setUp(() {
    mockGetIds = MockGetFavoritesIdsUseCase();
    mockToggle = MockToggleFavoriteUseCase();
    mockIsFavorite = MockIsFavoriteUseCase();
  });

  group('FavoritesCubit', () {
    test('initial state is FavoritesStateInitial', () {
      final cubit = FavoritesCubit(mockGetIds, mockToggle, mockIsFavorite);
      expect(cubit.state, const FavoritesStateInitial());
      cubit.close();
    });

    blocTest<FavoritesCubit, FavoritesState>(
      'loadFavorites emits Loaded with ids',
      build: () {
        when(() => mockGetIds()).thenAnswer((_) async => {1, 2, 3});
        return FavoritesCubit(mockGetIds, mockToggle, mockIsFavorite);
      },
      act: (cubit) => cubit.loadFavorites(),
      expect: () => [
        FavoritesStateLoaded({1, 2, 3}),
      ],
    );

    blocTest<FavoritesCubit, FavoritesState>(
      'toggleFavorite emits Loaded with updated ids',
      build: () {
        when(() => mockToggle(5)).thenAnswer((_) async => {});
        when(() => mockGetIds()).thenAnswer((_) async => {1, 5});
        return FavoritesCubit(mockGetIds, mockToggle, mockIsFavorite);
      },
      act: (cubit) => cubit.toggleFavorite(5),
      expect: () => [
        FavoritesStateLoaded({1, 5}),
      ],
    );
  });
}
