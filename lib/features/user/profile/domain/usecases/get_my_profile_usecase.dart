// file: features/shared/profile/domain/usecases/get_my_profile_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:pbl6/core/error/failures.dart';
import 'package:pbl6/core/usecase/usecase.dart';

import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class GetMyProfileUseCase implements UseCase<ProfileEntity, NoParams> {
  final ProfileRepository repository;

  GetMyProfileUseCase(this.repository);

  @override
  Future<Either<Failure, ProfileEntity>> call(NoParams params) async {
    return await repository.getMyProfile();
  }
}