import 'package:get_it/get_it.dart';
import 'package:pbl6/core/network/dio_client.dart';
import 'package:pbl6/core/services/api_service.dart';
import 'package:pbl6/features/auth/data/datasources/auth_remote_datasource.dart';

final sl = GetIt.instance;

void init() {
  // Đăng ký DioClient
  sl.registerSingleton<DioClient>(DioClient());
  // Đăng ký ApiService với instance của DioClient từ GetIt
  sl.registerSingleton<ApiService>(ApiService(sl<DioClient>().instance));
  // Đăng ký AuthRemoteDataSource với instance của ApiService từ GetIt
  sl.registerSingleton<AuthRemoteDataSource>(AuthRemoteDataSource(sl<ApiService>()));
}