import 'dart:io';

import 'package:pbl6/features/shared/auth/data/models/user_api_response.dart';

import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';


class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserApiResponse> getMyInfo() async {
    return await remoteDataSource.getMyInfo();
  }
  @override
  Future<UserApiResponse> updateMyInfo(Map<String, dynamic> updatedData) async {
    return await remoteDataSource.updateMyInfo(updatedData);
  }
   @override 
  Future<String> uploadAvatar(File imageFile) async {
    return await remoteDataSource.uploadAvatar(imageFile);
  }
  @override
  Future<void> changePassword({required String oldPassword, required String newPassword}) async {
    return await remoteDataSource.changePassword(oldPassword: oldPassword, newPassword: newPassword);
  }
}

