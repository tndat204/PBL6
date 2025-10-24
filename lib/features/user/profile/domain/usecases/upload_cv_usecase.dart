// file: features/shared/profile/domain/usecases/upload_cv_usecase.dart

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:pbl6/core/error/failures.dart';
import 'package:pbl6/core/usecase/usecase.dart';

import '../repositories/profile_repository.dart';

class UploadCVUseCase implements UseCase<String, UploadCVParams> {
  final ProfileRepository repository;

  UploadCVUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(UploadCVParams params) async {
    return await repository.uploadCV(params.cvFile);
  }
}

class UploadCVParams {
  final File cvFile;

  UploadCVParams({required this.cvFile});
}