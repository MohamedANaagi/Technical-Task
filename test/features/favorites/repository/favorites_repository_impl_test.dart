import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:technica_task/features/favorites/data/datasources/favorites_local_datasource.dart';
import 'package:technica_task/features/favorites/data/repositories/favorites_repository_impl.dart';

class MockFavoritesLocalDataSource extends Mock
    implements FavoritesLocalDataSource {}

void main() {
  late MockFavoritesLocalDataSource mockLocal;
  late FavoritesRepositoryImpl repository;

  setUp(() {
    mockLocal = MockFavoritesLocalDataSource();
    repository = FavoritesRepositoryImpl(mockLocal);
  });

  group('FavoritesRepositoryImpl', () {
    test('getFavoriteIds returns ids from datasource', () async {
      when(() => mockLocal.getFavoriteIds()).thenAnswer((_) async => {1, 2, 3});

      final result = await repository.getFavoriteIds();

      expect(result, {1, 2, 3});
    });

    test('toggleFavorite adds when not favorite', () async {
      when(() => mockLocal.isFavorite(5)).thenAnswer((_) async => false);
      when(() => mockLocal.addFavorite(5)).thenAnswer((_) async => {});

      await repository.toggleFavorite(5);

      verify(() => mockLocal.addFavorite(5)).called(1);
      verifyNever(() => mockLocal.removeFavorite(5));
    });

    test('toggleFavorite removes when already favorite', () async {
      when(() => mockLocal.isFavorite(5)).thenAnswer((_) async => true);
      when(() => mockLocal.removeFavorite(5)).thenAnswer((_) async => {});

      await repository.toggleFavorite(5);

      verify(() => mockLocal.removeFavorite(5)).called(1);
      verifyNever(() => mockLocal.addFavorite(5));
    });

    test('isFavorite returns value from datasource', () async {
      when(() => mockLocal.isFavorite(3)).thenAnswer((_) async => true);

      final result = await repository.isFavorite(3);

      expect(result, true);
    });
  });
}
