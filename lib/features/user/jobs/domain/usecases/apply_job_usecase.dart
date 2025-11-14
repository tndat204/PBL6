import 'package:pbl6/features/shared/application/domain/entities/application.dart';

import '../../../../shared/application/domain/repositories/application_repository.dart';

class ApplyJobUsecase {
  final ApplicationRepository repository;
  ApplyJobUsecase(this.repository);
  Future<Application> call({required String jobId, String? notes, String? filePath}) async {
    return await repository.applyJob(jobId: jobId, notes: notes, filePath: filePath);
  }
}