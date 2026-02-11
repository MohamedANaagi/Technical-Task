import '../../../../core/errors/app_exceptions.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// AuthRepositoryImpl — تنفيذ مستودع المصادقة (يجمع Remote + Local)
// ═══════════════════════════════════════════════════════════════════════════════
//
// العلاقات:
//   • ينفّذ: AuthRepository (واجهة من domain).
//   • يعتمد على: AuthRemoteDataSource، AuthLocalDataSource، AuthUser، AuthException.
//   • يُستخدم من: GetIt — يُحقَن في LoginUseCase، LogoutUseCase، CheckAuthUseCase.
//
// تدفق login: التحقق من الحقول → Remote.login() → Local.saveToken() → AuthUser.
// تدفق logout: Local.clearToken() فقط (لا استدعاء API).
// تدفق getStoredAuth: Local.getToken() → AuthUser أو null.
// ═══════════════════════════════════════════════════════════════════════════════

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._local);
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.isEmpty) {
      throw const AuthException('Email and password are required.');
    }
    final token = await _remote.login(
      username: email.trim(),
      password: password,
    );
    await _local.saveToken(token);
    return AuthUser(token: token);
  }

  @override
  Future<void> logout() => _local.clearToken();

  @override
  Future<AuthUser?> getStoredAuth() async {
    final token = await _local.getToken();
    return token != null && token.isNotEmpty ? AuthUser(token: token) : null;
  }
}
