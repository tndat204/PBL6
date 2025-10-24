// file: features/shared/profile/domain/usecases/get_cv_url_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:pbl6/core/error/failures.dart';
import 'package:pbl6/core/usecase/usecase.dart';

import '../repositories/profile_repository.dart';


class GetCVUrlUseCase implements UseCase<String, NoParams> {
  final ProfileRepository repository;

  GetCVUrlUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(NoParams params) async {
    return await repository.getCVUrl();
  }
}