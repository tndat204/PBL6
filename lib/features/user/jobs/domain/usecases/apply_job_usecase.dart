import 'package:pbl6/features/user/jobs/domain/entities/application.dart';

import '../repositories/application_repository.dart';

class ApplyJobUsecase {
  final ApplicationRepository repository;
  ApplyJobUsecase(this.repository);
  Future<Application> call({required String jobId, String? notes}) async {
    return await repository.applyJob(jobId: jobId, notes: notes);
  }
}