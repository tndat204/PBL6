// init.dart
import 'package:get_it/get_it.dart';
import 'package:pbl6/core/network/dio_client.dart';
import 'package:pbl6/core/services/api_service.dart';
import 'package:pbl6/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pbl6/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:pbl6/features/auth/data/services/google_sign_in_service.dart';
import 'package:pbl6/features/auth/domain/repositories/auth_repository.dart';
import 'package:pbl6/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:pbl6/features/auth/domain/usecases/login_usecase.dart';

final sl = GetIt.instance;

void init() {
  // Đăng ký DioClient
  sl.registerSingleton<DioClient>(DioClient());

  // Đăng ký ApiService với Dio từ GetIt
  sl.registerSingleton<ApiService>(ApiService(sl<DioClient>().instance));

  // Đăng ký AuthRemoteDataSource với ApiService và Dio từ GetIt
  sl.registerSingleton<AuthRemoteDataSource>(
    AuthRemoteDataSourceImpl(sl<ApiService>(), sl<DioClient>().instance),
  );

  // Đăng ký AuthRepository với AuthRemoteDataSource từ GetIt
  sl.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );

  // Đăng ký ForgotPasswordUseCase với AuthRepository từ GetIt
  sl.registerSingleton<ForgotPasswordUseCase>(
    ForgotPasswordUseCase(sl<AuthRepository>()),
  );

  // Đăng ký LoginUseCase với AuthRepository từ GetIt
  sl.registerSingleton<LoginUseCase>(
    LoginUseCase(sl<AuthRepository>()),
  );

  // Đăng ký GoogleSignInService
  sl.registerSingleton<GoogleSignInService>(GoogleSignInService());
}