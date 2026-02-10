import 'package:dio/dio.dart';

import '../../../../core/errors/app_exceptions.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  /// Demo credentials – login succeeds without calling the API.
  static const _demoUsername = 'mohamed';
  static const _demoPassword = '0000';
  static const _demoToken = 'demo_token_mohamed';

  @override
  Future<String> login({
    required String username,
    required String password,
  }) async {
    // Demo login: accept mohamed / 0000 without calling the API
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
      if (e.response?.statusCode == 401) {
        throw const AuthException('Invalid email or password.');
      }
      rethrow;
    }
  }
}
