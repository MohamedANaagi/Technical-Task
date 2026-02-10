import 'package:equatable/equatable.dart';

import '../../domain/entities/auth_user.dart';

sealed class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

final class AuthStateInitial extends AuthState {
  const AuthStateInitial();
}

final class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

final class AuthStateAuthenticated extends AuthState {
  const AuthStateAuthenticated(this.user);
  final AuthUser user;
  @override
  List<Object?> get props => [user];
}

final class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated();
}

final class AuthStateError extends AuthState {
  const AuthStateError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
