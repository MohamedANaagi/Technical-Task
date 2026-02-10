import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_exceptions.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/usecases/check_auth_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._login, this._logout, this._checkAuth)
    : super(const AuthStateInitial());

  final LoginUseCase _login;
  final LogoutUseCase _logout;
  final CheckAuthUseCase _checkAuth;

  Future<void> checkAuth() async {
    emit(const AuthStateLoading());
    final user = await _checkAuth();
    if (user != null) {
      emit(AuthStateAuthenticated(user));
    } else {
      emit(const AuthStateUnauthenticated());
    }
  }

  Future<void> login({required String email, required String password}) async {
    emit(const AuthStateLoading());
    try {
      final user = await _login(email: email, password: password);
      emit(AuthStateAuthenticated(user));
    } on AuthException catch (e) {
      emit(AuthStateError(e.message));
    } catch (_) {
      emit(const AuthStateError('Login failed. Please try again.'));
    }
  }

  Future<void> logout() async {
    await _logout();
    emit(const AuthStateUnauthenticated());
  }
}
