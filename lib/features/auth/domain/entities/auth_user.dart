import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  const AuthUser({required this.token});
  final String token;
  @override
  List<Object?> get props => [token];
}
