import '../../../../shared/job/domain/entities/job.dart';
import '../../../../shared/job/domain/repositories/job_repository.dart';

class GetAllJobsUseCase {
  final JobRepository repository;
  GetAllJobsUseCase(this.repository);

  Future<List<Job>> call({String? category, String? keyword}) async {
    return await repository.fetchAllJobs(category: category, keyword: keyword);
  }
}
