// file: features/shared/profile/domain/usecases/update_profile_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:pbl6/core/error/failures.dart';
import 'package:pbl6/core/usecase/usecase.dart';
import 'package:pbl6/features/user/profile/domain/entities/profile_entity.dart';
import 'package:pbl6/features/user/profile/domain/usecases/create_profile_usecase.dart';

import '../repositories/profile_repository.dart';


class UpdateProfileUseCase implements UseCase<ProfileEntity, ProfileRequestParams> {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, ProfileEntity>> call(ProfileRequestParams params) async {
    return await repository.updateProfile(params.requestModel);
  }
}

// Re-use ProfileRequestParams
// class ProfileRequestParams {
//   final ProfileRequestModel requestModel;
//   ProfileRequestParams({required this.requestModel});
// }