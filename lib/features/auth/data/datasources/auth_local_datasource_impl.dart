import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/constants/app_constants.dart';
import 'auth_local_datasource.dart';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl(this._storage);
  final FlutterSecureStorage _storage;

  @override
  Future<void> saveToken(String token) =>
      _storage.write(key: AppConstants.authTokenKey, value: token);

  @override
  Future<String?> getToken() => _storage.read(key: AppConstants.authTokenKey);

  @override
  Future<void> clearToken() => _storage.delete(key: AppConstants.authTokenKey);
}
