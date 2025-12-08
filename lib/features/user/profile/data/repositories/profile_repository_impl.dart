// file: features/shared/profile/data/repositories/profile_repository_impl.dart

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:pbl6/core/error/failures.dart';

import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/profile_models.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  // Hàm helper để xử lý chung
  Either<Failure, T> _handleResponse<T>(ProfileApiResponse apiResponse) {
   if ((apiResponse.code == 0 || apiResponse.code == 200) && apiResponse.result != null) {
      return Right(apiResponse.result as T);
    } else {
      final message = apiResponse.message.isNotEmpty
          ? apiResponse.message
          : 'Lỗi máy chủ không xác định';
      return Left(ServerFailure(message: message));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> getMyProfile() async {
    try {
      final apiResponse = await remoteDataSource.getMyProfile();
      
      final resultEither = _handleResponse<ProfileResponse>(apiResponse);
      
      return resultEither.fold(
        (failure) => Left(failure),
        (response) => Right(ProfileEntity.fromResponse(response)),
      );
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadCV(File cvFile) async {
    try {
      final apiResponse = await remoteDataSource.uploadCV(cvFile);
      
      final resultEither = _handleResponse<String>(apiResponse);
      
      // Nếu thành công, trả về String (URL), nếu lỗi trả về Failure
      return resultEither.fold(
        (failure) => Left(failure),
        (url) => Right(url),
      );
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getCVUrl() async {
    try {
      final apiResponse = await remoteDataSource.getCVUrl();
      
      final resultEither = _handleResponse<String>(apiResponse);
      
      // Nếu thành công, trả về String (URL), nếu lỗi trả về Failure
      return resultEither.fold(
        (failure) => Left(failure),
        (url) => Right(url),
      );
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  @override
  Future<Either<Failure, ProfileEntity>> createProfile(ProfileRequestModel request) async {
    try {
      final apiResponse = await remoteDataSource.createProfile(request);
      
      final resultEither = _handleResponse<ProfileResponse>(apiResponse);
      
      return resultEither.fold(
        (failure) => Left(failure),
        (response) => Right(ProfileEntity.fromResponse(response)),
      );
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // 💡 Bổ sung: Update Profile
  @override
  Future<Either<Failure, ProfileEntity>> updateProfile(ProfileRequestModel request) async {
    try {
      final apiResponse = await remoteDataSource.updateProfile(request);
      
      final resultEither = _handleResponse<ProfileResponse>(apiResponse);
      
      return resultEither.fold(
        (failure) => Left(failure),
        (response) => Right(ProfileEntity.fromResponse(response)),
      );
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  @override
  Future<Either<Failure, ProfileEntity>> getUserProfile(String userId) async {
    try {
      final apiResponse = await remoteDataSource.getUserProfile(userId);
      
      final resultEither = _handleResponse<ProfileResponse>(apiResponse);
      
      return resultEither.fold(
        (failure) => Left(failure),
        // Convert từ Model (ProfileResponse) sang Entity (ProfileEntity)
        (response) => Right(ProfileEntity.fromResponse(response)),
      );
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}