import 'package:pbl6/features/shared/auth/data/models/user_api_response.dart';

import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';


class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl(UserRemoteDataSource userRemoteDataSource, {required this.remoteDataSource});

  @override
  Future<UserApiResponse> getMyInfo() async {
    return await remoteDataSource.getMyInfo();
  }

}
