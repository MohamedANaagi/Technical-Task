import 'package:equatable/equatable.dart';

/// Base class for application exceptions.
abstract base class AppException implements Exception {
  const AppException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Thrown when a server or network error occurs.
final class ServerException extends AppException with EquatableMixin {
  const ServerException(super.message);
  @override
  List<Object?> get props => [message];
}

/// Thrown when the request times out.
final class TimeoutException extends AppException with EquatableMixin {
  const TimeoutException(super.message);
  @override
  List<Object?> get props => [message];
}

/// Thrown when the device is offline.
final class OfflineException extends AppException with EquatableMixin {
  const OfflineException(super.message);
  @override
  List<Object?> get props => [message];
}

/// Thrown when authentication fails.
final class AuthException extends AppException with EquatableMixin {
  const AuthException(super.message);
  @override
  List<Object?> get props => [message];
}

/// Thrown when cached data is invalid or missing.
final class CacheException extends AppException with EquatableMixin {
  const CacheException(super.message);
  @override
  List<Object?> get props => [message];
}
