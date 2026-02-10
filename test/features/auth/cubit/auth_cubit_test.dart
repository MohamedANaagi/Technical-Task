import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:technica_task/core/errors/app_exceptions.dart';
import 'package:technica_task/features/auth/domain/entities/auth_user.dart';
import 'package:technica_task/features/auth/domain/usecases/check_auth_usecase.dart';
import 'package:technica_task/features/auth/domain/usecases/login_usecase.dart';
import 'package:technica_task/features/auth/domain/usecases/logout_usecase.dart';
import 'package:technica_task/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:technica_task/features/auth/presentation/cubit/auth_state.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockCheckAuthUseCase extends Mock implements CheckAuthUseCase {}

void main() {
  late MockLoginUseCase mockLogin;
  late MockLogoutUseCase mockLogout;
  late MockCheckAuthUseCase mockCheckAuth;

  setUp(() {
    mockLogin = MockLoginUseCase();
    mockLogout = MockLogoutUseCase();
    mockCheckAuth = MockCheckAuthUseCase();
  });

  group('AuthCubit', () {
    const user = AuthUser(token: 'test_token');

    test('initial state is AuthStateInitial', () {
      final cubit = AuthCubit(mockLogin, mockLogout, mockCheckAuth);
      expect(cubit.state, const AuthStateInitial());
      cubit.close();
    });

    blocTest<AuthCubit, AuthState>(
      'checkAuth emits Authenticated when user exists',
      build: () {
        when(() => mockCheckAuth()).thenAnswer((_) async => user);
        return AuthCubit(mockLogin, mockLogout, mockCheckAuth);
      },
      act: (cubit) => cubit.checkAuth(),
      expect: () => [const AuthStateLoading(), AuthStateAuthenticated(user)],
    );

    blocTest<AuthCubit, AuthState>(
      'checkAuth emits Unauthenticated when no user',
      build: () {
        when(() => mockCheckAuth()).thenAnswer((_) async => null);
        return AuthCubit(mockLogin, mockLogout, mockCheckAuth);
      },
      act: (cubit) => cubit.checkAuth(),
      expect: () => [
        const AuthStateLoading(),
        const AuthStateUnauthenticated(),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'login emits Authenticated on success',
      build: () {
        when(
          () => mockLogin(email: 'user@test.com', password: 'pass123'),
        ).thenAnswer((_) async => user);
        return AuthCubit(mockLogin, mockLogout, mockCheckAuth);
      },
      act: (cubit) => cubit.login(email: 'user@test.com', password: 'pass123'),
      expect: () => [const AuthStateLoading(), AuthStateAuthenticated(user)],
    );

    blocTest<AuthCubit, AuthState>(
      'login emits AuthStateError on AuthException',
      build: () {
        when(
          () => mockLogin(email: 'bad@test.com', password: 'wrong'),
        ).thenThrow(const AuthException('Invalid credentials'));
        return AuthCubit(mockLogin, mockLogout, mockCheckAuth);
      },
      act: (cubit) => cubit.login(email: 'bad@test.com', password: 'wrong'),
      expect: () => [
        const AuthStateLoading(),
        const AuthStateError('Invalid credentials'),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'logout emits Unauthenticated',
      build: () {
        when(() => mockLogout()).thenAnswer((_) async => {});
        return AuthCubit(mockLogin, mockLogout, mockCheckAuth);
      },
      act: (cubit) => cubit.logout(),
      expect: () => [const AuthStateUnauthenticated()],
    );
  });
}
