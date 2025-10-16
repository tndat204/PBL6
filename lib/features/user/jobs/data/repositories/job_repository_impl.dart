import '../../domain/entities/job.dart';
import '../../domain/repositories/job_repository.dart';
import '../datasources/job_remote_datasource.dart';

class JobRepositoryImpl implements JobRepository {
  final JobRemoteDataSource remoteDataSource;

  JobRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Job>> fetchAllJobs({String? category, String? keyword}) async {
    return remoteDataSource.fetchAllJobs(category: category, keyword: keyword);
  }

  @override
  Future<Job> fetchJobDetails(String jobId) async {
    return remoteDataSource.fetchJobDetails(jobId);
  }
}
