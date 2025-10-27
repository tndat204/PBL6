import 'package:get_it/get_it.dart';
import 'package:pbl6/core/network/dio_client.dart';
import 'package:pbl6/core/services/api_service.dart';
// ===== AUTH =====
import 'package:pbl6/features/shared/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pbl6/features/shared/auth/data/repositories/auth_repository_impl.dart';
import 'package:pbl6/features/shared/auth/data/services/google_sign_in_service.dart';
import 'package:pbl6/features/shared/auth/domain/repositories/auth_repository.dart';
import 'package:pbl6/features/shared/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:pbl6/features/shared/auth/domain/usecases/login_usecase.dart';
import 'package:pbl6/features/shared/auth/domain/usecases/register_usecase.dart';
// ===== CATEGORY =====
import 'package:pbl6/features/shared/category/data/datasources/category_remote_datasource.dart';
import 'package:pbl6/features/shared/category/data/repositories/category_repository_impl.dart';
import 'package:pbl6/features/shared/category/domain/repositories/category_repository.dart';
import 'package:pbl6/features/shared/category/domain/usecases/create_category_usecase.dart';
import 'package:pbl6/features/shared/category/domain/usecases/delete_category_usecase.dart';
import 'package:pbl6/features/shared/category/domain/usecases/get_all_categories_usecase.dart';
import 'package:pbl6/features/shared/category/domain/usecases/get_category_detail_usecase.dart';
import 'package:pbl6/features/shared/category/domain/usecases/update_category_usecase.dart';
// ===== COMPANY =====

// ===== JOB =====

// ===== SKILL =====
import 'package:pbl6/features/shared/skill/data/datasources/skill_remote_datasource.dart';
import 'package:pbl6/features/shared/skill/data/repositories/skill_repository_impl.dart';
import 'package:pbl6/features/shared/skill/domain/repositories/skill_repository.dart';
import 'package:pbl6/features/shared/skill/domain/usecases/create_skill_usecase.dart';
import 'package:pbl6/features/shared/skill/domain/usecases/delete_skill_usecase.dart';
import 'package:pbl6/features/shared/skill/domain/usecases/get_all_skills_usecase.dart';
import 'package:pbl6/features/shared/skill/domain/usecases/get_skill_detail_usecase.dart';
import 'package:pbl6/features/shared/skill/domain/usecases/update_skill_usecase.dart';
// ===== USER =====
import 'package:pbl6/features/shared/user/data/datasources/user_remote_datasource.dart';
import 'package:pbl6/features/shared/user/data/repositories/user_repository_impl.dart';
import 'package:pbl6/features/shared/user/domain/repositories/user_repository.dart';
import 'package:pbl6/features/shared/user/domain/usecases/change_my_password_usecase.dart';
import 'package:pbl6/features/shared/user/domain/usecases/get_my_info_usecase.dart';
import 'package:pbl6/features/user/jobs/data/datasources/application_remote_datasource.dart';
import 'package:pbl6/features/user/jobs/data/datasources/company_remote_datasource.dart';
import 'package:pbl6/features/user/jobs/data/datasources/job_remote_datasource.dart';
import 'package:pbl6/features/user/jobs/data/repositories/application_repository_impl.dart';
import 'package:pbl6/features/user/jobs/data/repositories/company_repository_impl.dart';
import 'package:pbl6/features/user/jobs/data/repositories/job_repository_impl.dart';
import 'package:pbl6/features/user/jobs/domain/repositories/application_repository.dart';
import 'package:pbl6/features/user/jobs/domain/repositories/company_repository.dart';
import 'package:pbl6/features/user/jobs/domain/repositories/job_repository.dart';
import 'package:pbl6/features/user/jobs/domain/usecases/apply_job_usecase.dart';
import 'package:pbl6/features/user/jobs/domain/usecases/get_all_companies_usecase.dart';
import 'package:pbl6/features/user/jobs/domain/usecases/get_all_jobs_usecase.dart';
import 'package:pbl6/features/user/jobs/domain/usecases/get_company_details_usecase.dart';
import 'package:pbl6/features/user/jobs/domain/usecases/get_job_details_usecase.dart';
import 'package:pbl6/features/user/profile/data/datasources/profile_remote_datasource.dart';
import 'package:pbl6/features/user/profile/data/repositories/profile_repository_impl.dart';
import 'package:pbl6/features/user/profile/domain/repositories/profile_repository.dart';
import 'package:pbl6/features/user/profile/domain/usecases/create_profile_usecase.dart';
import 'package:pbl6/features/user/profile/domain/usecases/get_cv_url_usecase.dart';
import 'package:pbl6/features/user/profile/domain/usecases/get_my_profile_usecase.dart';
import 'package:pbl6/features/user/profile/domain/usecases/update_profile_usecase.dart';
import 'package:pbl6/features/user/profile/domain/usecases/upload_cv_usecase.dart';

import '../features/shared/user/domain/usecases/update_my_info_usecase.dart';
import '../features/shared/user/domain/usecases/upload_avatar_usecase.dart';

final sl = GetIt.instance;

void init() {
  // ================= CORE =================
  sl.registerSingleton<DioClient>(DioClient());
  sl.registerSingleton<ApiService>(ApiService(sl<DioClient>().instance));

  // ================= AUTH =================
  sl.registerSingleton<AuthRemoteDataSource>(
    AuthRemoteDataSourceImpl(sl<ApiService>(), sl<DioClient>().instance),
  );
  sl.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );
  sl.registerSingleton<ForgotPasswordUseCase>(
    ForgotPasswordUseCase(sl<AuthRepository>()),
  );
  sl.registerSingleton<LoginUseCase>(
    LoginUseCase(sl<AuthRepository>()),
  );
  sl.registerSingleton<RegisterUseCase>(
    RegisterUseCase(sl<AuthRepository>()),
  );
  sl.registerSingleton<GoogleSignInService>(GoogleSignInService());

  // ================= USER =================
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(sl<ApiService>(), sl<DioClient>().instance),
  );
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(remoteDataSource: sl<UserRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetMyInfoUseCase>(
    () => GetMyInfoUseCase(sl<UserRepository>()),
  );
  sl.registerLazySingleton<UpdateMyInfoUseCase>(
    () => UpdateMyInfoUseCase(sl<UserRepository>()),
  );
  sl.registerLazySingleton<UploadAvatarUseCase>(
    () => UploadAvatarUseCase(sl<UserRepository>()),
  );
sl.registerLazySingleton<ChangeMyPasswordUsecase>(
    () => ChangeMyPasswordUsecase(sl<UserRepository>()),
  );

  // ================= JOB =================
  sl.registerLazySingleton<JobRemoteDataSource>(
    () => JobRemoteDataSourceImpl(sl<DioClient>().instance),
  );
  sl.registerLazySingleton<JobRepository>(
    () => JobRepositoryImpl(sl<JobRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetAllJobsUseCase>(
    () => GetAllJobsUseCase(sl<JobRepository>()),
  );
  sl.registerLazySingleton<GetJobDetailsUseCase>(
    () => GetJobDetailsUseCase(sl<JobRepository>()),
  );

  // ================= COMPANY =================
  sl.registerLazySingleton<CompanyRemoteDataSource>(
    () => CompanyRemoteDataSourceImpl(sl<DioClient>().instance),
  );
  sl.registerLazySingleton<CompanyRepository>(
    () => CompanyRepositoryImpl(sl<CompanyRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetAllCompaniesUseCase>(
    () => GetAllCompaniesUseCase(sl<CompanyRepository>()),
  );
  sl.registerLazySingleton<GetCompanyDetailsUseCase>(
    () => GetCompanyDetailsUseCase(sl<CompanyRepository>()),
  );

  // ================= CATEGORY =================
  sl.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(sl<DioClient>().instance),
  );
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(sl<CategoryRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetAllCategoriesUseCase>(
    () => GetAllCategoriesUseCase(sl<CategoryRepository>()),
  );
  sl.registerLazySingleton<GetCategoryDetailUseCase>(
    () => GetCategoryDetailUseCase(sl<CategoryRepository>()),
  );
  sl.registerLazySingleton<CreateCategoryUseCase>(
    () => CreateCategoryUseCase(sl<CategoryRepository>()),
  );
  sl.registerLazySingleton<UpdateCategoryUseCase>(
    () => UpdateCategoryUseCase(sl<CategoryRepository>()),
  );
  sl.registerLazySingleton<DeleteCategoryUseCase>(
    () => DeleteCategoryUseCase(sl<CategoryRepository>()),
  );

  // ================= SKILL =================
  sl.registerLazySingleton<SkillRemoteDataSource>(
    () => SkillRemoteDataSourceImpl(sl<DioClient>().instance),
  );
  sl.registerLazySingleton<SkillRepository>(
    () => SkillRepositoryImpl(sl<SkillRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetAllSkillsUseCase>(
    () => GetAllSkillsUseCase(sl<SkillRepository>()),
  );
  sl.registerLazySingleton<GetSkillDetailUseCase>(
    () => GetSkillDetailUseCase(sl<SkillRepository>()),
  );
  sl.registerLazySingleton<CreateSkillUseCase>(
    () => CreateSkillUseCase(sl<SkillRepository>()),
  );
  sl.registerLazySingleton<UpdateSkillUseCase>(
    () => UpdateSkillUseCase(sl<SkillRepository>()),
  );
  sl.registerLazySingleton<DeleteSkillUseCase>(
    () => DeleteSkillUseCase(sl<SkillRepository>()),
  );
// 💡 ================= PROFILE =================
sl.registerLazySingleton<ProfileRemoteDataSource>(
 () => ProfileRemoteDataSourceImpl(sl<DioClient>().instance),
 );
 sl.registerLazySingleton<ProfileRepository>(
 () => ProfileRepositoryImpl(remoteDataSource: sl<ProfileRemoteDataSource>()),
);
sl.registerLazySingleton<GetMyProfileUseCase>(
() => GetMyProfileUseCase(sl<ProfileRepository>()),
 );
sl.registerLazySingleton<CreateProfileUseCase>(
 () => CreateProfileUseCase(sl<ProfileRepository>()),
 );
sl.registerLazySingleton<UpdateProfileUseCase>(
 () => UpdateProfileUseCase(sl<ProfileRepository>()),
 );
sl.registerLazySingleton<UploadCVUseCase>(
() => UploadCVUseCase(sl<ProfileRepository>()),
 );
 sl.registerLazySingleton<GetCVUrlUseCase>(
 () => GetCVUrlUseCase(sl<ProfileRepository>()),
 );
// ======================APPLICATION=================
sl.registerLazySingleton<ApplicationRemoteDataSource>(
 () => ApplicationRemoteDataSourceImpl(sl<DioClient>().instance),
 );
 sl.registerLazySingleton<ApplicationRepository>(
 () => ApplicationRepositoryImpl(sl<ApplicationRemoteDataSource>()),
);
sl.registerLazySingleton<ApplyJobUsecase>(
() => ApplyJobUsecase(sl<ApplicationRepository>()),
 );

}
