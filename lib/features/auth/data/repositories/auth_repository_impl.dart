import 'package:pbl6/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pbl6/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Map<String, dynamic>>> fetchProvinces() {
    return _remoteDataSource.fetchProvinces();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchWards(int provinceCode) {
    return _remoteDataSource.fetchWards(provinceCode);
  }

  @override
  Future<Map<String, dynamic>> login(String email, String password) {
    return _remoteDataSource.login(email, password);
  }
}