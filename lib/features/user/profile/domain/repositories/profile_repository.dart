// file: features/shared/profile/domain/repositories/profile_repository.dart

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:pbl6/core/error/failures.dart'; // Cần có class Failure

import '../../data/models/profile_models.dart';
import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileEntity>> getMyProfile();
  Future<Either<Failure, String>> uploadCV(File cvFile);
  Future<Either<Failure, String>> getCVUrl();
  Future<Either<Failure, ProfileEntity>> createProfile(ProfileRequestModel request);
  // 💡 Bổ sung
  Future<Either<Failure, ProfileEntity>> updateProfile(ProfileRequestModel request);
Future<Either<Failure, ProfileEntity>> getUserProfile(String userId);
}