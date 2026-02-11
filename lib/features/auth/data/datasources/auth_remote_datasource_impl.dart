import 'package:dio/dio.dart';

import '../../../../core/errors/app_exceptions.dart';
import 'auth_remote_datasource.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// AuthRemoteDataSourceImpl — تنفيذ استدعاء API تسجيل الدخول
// ═══════════════════════════════════════════════════════════════════════════════
//
// العلاقات:
//   • ينفّذ: AuthRemoteDataSource (واجهة في نفس المجلد).
//   • يعتمد على: Dio (من core/di)، AuthException (من core/errors).
//   • يُستخدم من: AuthRepositoryImpl (يُحقَن عبر GetIt).
//
// الديمو: mohamed / 0000 — تسجيل دخول ناجح بدون أي HTTP request (للتجربة السريعة).
// غير الديمو: POST /auth/login مع body { username, password } (Fake Store API).
// ═══════════════════════════════════════════════════════════════════════════════

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  /// بيانات الديمو — تسجيل الدخول ينجح بدون استدعاء الـ API.
  static const _demoUsername = 'mohamed';
  static const _demoPassword = '0000';
  static const _demoToken = 'demo_token_mohamed';

  @override
  Future<String> login({
    required String username,
    required String password,
  }) async {
    // ديمو: قبول mohamed / 0000 وإرجاع token وهمي بدون HTTP
    if (username.trim().toLowerCase() == _demoUsername &&
        password == _demoPassword) {
      return _demoToken;
    }

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'username': username, 'password': password},
      );
      final token = response.data?['token'] as String?;
      if (token == null || token.isEmpty) {
        throw const AuthException('Invalid response from server.');
      }
      return token;
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == 401 || code == 400 || code == 404) {
        throw const AuthException('Invalid email or password.');
      }
      rethrow;
    }
  }
}
