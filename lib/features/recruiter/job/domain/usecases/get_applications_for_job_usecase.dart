import 'package:pbl6/features/shared/application/domain/entities/application.dart';
import 'package:pbl6/features/shared/application/domain/repositories/application_repository.dart';

class GetApplicationsForJobUsecase {
  final ApplicationRepository repository;

  GetApplicationsForJobUsecase(this.repository);

  Future<List<Application>> call(String jobId) {
    return repository.getApplicationsForJob(jobId);
  }
}