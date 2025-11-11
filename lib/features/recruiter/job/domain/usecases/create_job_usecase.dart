import 'package:pbl6/features/shared/job/domain/entities/job.dart';
import 'package:pbl6/features/shared/job/domain/repositories/job_repository.dart';

class CreateJobUseCase {
  final JobRepository repository;

  CreateJobUseCase(this.repository);

  Future<Job> call(Job params) async {
    return repository.createJob(params);
  }
}
