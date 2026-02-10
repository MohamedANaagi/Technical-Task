abstract interface class AuthRemoteDataSource {
  Future<String> login({required String username, required String password});
}
