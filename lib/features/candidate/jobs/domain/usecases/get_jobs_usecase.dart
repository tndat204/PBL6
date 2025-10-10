import '../entities/job_post.dart';
import '../repositories/job_repository.dart';

class GetJobsUseCase {
  final JobRepository repository;

  GetJobsUseCase(this.repository);

  Future<List<JobPost>> call({String? category, String? searchQuery}) async {
    return await repository.getJobs(category: category, searchQuery: searchQuery);
  }
}