import '../entities/job.dart';
import '../repositories/job_repository.dart';

/// 🧩 UseCase: Lấy chi tiết một Job theo ID
class GetJobDetailsUseCase {
  final JobRepository repository;

  GetJobDetailsUseCase(this.repository);

  Future<Job> call(String jobId) async {
    return await repository.fetchJobDetails(jobId);
  }
}
