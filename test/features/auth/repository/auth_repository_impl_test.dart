import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:technica_task/core/errors/app_exceptions.dart';
import 'package:technica_task/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:technica_task/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:technica_task/features/auth/data/repositories/auth_repository_impl.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

void main() {
  late MockAuthRemoteDataSource mockRemote;
  late MockAuthLocalDataSource mockLocal;
  late AuthRepositoryImpl repository;

  setUp(() {
    mockRemote = MockAuthRemoteDataSource();
    mockLocal = MockAuthLocalDataSource();
    repository = AuthRepositoryImpl(mockRemote, mockLocal);
  });

  group('AuthRepositoryImpl', () {
    group('login', () {
      test('returns AuthUser and saves token on success', () async {
        when(
          () => mockRemote.login(username: 'user', password: 'pass'),
        ).thenAnswer((_) async => 'token123');
        when(() => mockLocal.saveToken(any())).thenAnswer((_) async => {});

        final result = await repository.login(email: 'user', password: 'pass');

        expect(result.token, 'token123');
        verify(
          () => mockRemote.login(username: 'user', password: 'pass'),
        ).called(1);
        verify(() => mockLocal.saveToken('token123')).called(1);
      });

      test('throws AuthException when email is empty', () async {
        await expectLater(
          repository.login(email: '  ', password: 'pass'),
          throwsA(isA<AuthException>()),
        );
        verifyNever(() => mockRemote.login(username: '  ', password: 'pass'));
      });

      test('throws AuthException when password is empty', () async {
        await expectLater(
          repository.login(email: 'user', password: ''),
          throwsA(isA<AuthException>()),
        );
        verifyNever(() => mockRemote.login(username: 'user', password: ''));
      });
    });

    group('logout', () {
      test('clears token', () async {
        when(() => mockLocal.clearToken()).thenAnswer((_) async => {});

        await repository.logout();

        verify(() => mockLocal.clearToken()).called(1);
      });
    });

    group('getStoredAuth', () {
      test('returns AuthUser when token exists', () async {
        when(() => mockLocal.getToken()).thenAnswer((_) async => 'saved_token');

        final result = await repository.getStoredAuth();

        expect(result, isNotNull);
        expect(result!.token, 'saved_token');
      });

      test('returns null when token is null', () async {
        when(() => mockLocal.getToken()).thenAnswer((_) async => null);

        final result = await repository.getStoredAuth();

        expect(result, isNull);
      });

      test('returns null when token is empty', () async {
        when(() => mockLocal.getToken()).thenAnswer((_) async => '');

        final result = await repository.getStoredAuth();

        expect(result, isNull);
      });
    });
  });
}
