// init.dart
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:pbl6/core/network/dio_client.dart';
import 'package:pbl6/core/services/api_service.dart';
import 'package:pbl6/features/shared/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pbl6/features/shared/auth/data/repositories/auth_repository_impl.dart';
import 'package:pbl6/features/shared/auth/data/services/google_sign_in_service.dart';
import 'package:pbl6/features/shared/auth/domain/repositories/auth_repository.dart';
import 'package:pbl6/features/shared/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:pbl6/features/shared/auth/domain/usecases/login_usecase.dart';
import 'package:pbl6/features/shared/auth/domain/usecases/register_usecase.dart';
import 'package:pbl6/features/shared/user/data/datasources/user_remote_datasource.dart';
import 'package:pbl6/features/shared/user/domain/repositories/user_repository.dart';
import 'package:pbl6/features/shared/user/domain/usecases/get_my_info_usecase.dart';
import 'package:pbl6/features/user/jobs/data/datasources/job_local_datasource.dart'; // Import JobLocalDataSource
import 'package:pbl6/features/user/jobs/domain/repositories/job_repository.dart';
import 'package:pbl6/features/user/jobs/domain/usecases/get_categories_usecase.dart'; // Import GetCategoriesUseCase nếu dùng
import 'package:pbl6/features/user/jobs/domain/usecases/get_jobs_usecase.dart';

import '../features/user/jobs/data/repositories/job_repository_impl.dart';

final sl = GetIt.instance;

void init() {
  // Dio chính (backend của bạn)
  sl.registerSingleton<DioClient>(DioClient());

  // Dio riêng cho provinces API
  sl.registerSingleton<Dio>(Dio(BaseOptions(
    baseUrl: 'https://provinces.open-api.vn/api/',
    connectTimeout: const Duration(seconds: 50),
    receiveTimeout: const Duration(seconds: 50),
  )));

  // ApiService dùng Dio riêng cho provinces
  sl.registerSingleton<ApiService>(ApiService(sl<Dio>()));

  // AuthRemoteDataSource dùng Dio chính
  sl.registerSingleton<AuthRemoteDataSource>(
    AuthRemoteDataSourceImpl(sl<ApiService>(), sl<DioClient>().instance),
  );

  // UserRemoteDataSource dùng ApiService chính và DioClient (2 args)
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(sl<ApiService>(), sl<DioClient>().instance),
  );



  // Các phần khác giữ nguyên
  sl.registerSingleton<AuthRepository>(AuthRepositoryImpl(sl<AuthRemoteDataSource>()));
  sl.registerSingleton<ForgotPasswordUseCase>(ForgotPasswordUseCase(sl<AuthRepository>()));
  sl.registerSingleton<LoginUseCase>(LoginUseCase(sl<AuthRepository>()));
  sl.registerSingleton<GoogleSignInService>(GoogleSignInService());
  sl.registerSingleton<RegisterUseCase>(RegisterUseCase(sl<AuthRepository>()));

  sl.registerLazySingleton<JobLocalDataSource>(() => JobLocalDataSource());
  sl.registerLazySingleton<JobRepository>(() => JobRepositoryImpl(sl<JobLocalDataSource>()));
  sl.registerLazySingleton<GetJobsUseCase>(() => GetJobsUseCase(sl<JobRepository>()));
  sl.registerLazySingleton<GetCategoriesUseCase>(() => GetCategoriesUseCase(sl<JobRepository>()));

  sl.registerLazySingleton<GetMyInfoUseCase>(() => GetMyInfoUseCase(sl<UserRepository>()));
}