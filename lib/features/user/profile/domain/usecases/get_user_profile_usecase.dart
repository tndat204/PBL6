import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:pbl6/core/error/failures.dart';
import 'package:pbl6/core/usecase/usecase.dart';

import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class GetUserProfileUseCase implements UseCase<ProfileEntity, GetUserProfileParams> {
  final ProfileRepository repository;

  GetUserProfileUseCase(this.repository);

  @override
  Future<Either<Failure, ProfileEntity>> call(GetUserProfileParams params) async {
    return await repository.getUserProfile(params.userId);
  }
}

// Params class để truyền userId vào UseCase
class GetUserProfileParams extends Equatable {
  final String userId;

  const GetUserProfileParams({required this.userId});

  @override
  List<Object> get props => [userId];
}