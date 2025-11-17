import 'package:pbl6/features/shared/auth/data/models/api_response_model.dart';

import '../../domain/entities/job.dart';
import '../../domain/repositories/job_repository.dart';
import '../datasources/job_remote_datasource.dart';

class JobRepositoryImpl implements JobRepository {
  final JobRemoteDataSource remoteDataSource;

  JobRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Job>> fetchAllJobs({
    String? category,
    String? keyword,
    String? companyId,
    JobStatus? status,
  }) async {
    return remoteDataSource.fetchAllJobs(
      category: category,
      keyword: keyword,
      companyId: companyId,
      status: status,
    );
  }

  @override
  Future<Job> fetchJobDetails(String jobId) async {
    return remoteDataSource.fetchJobDetails(jobId);
  }

  @override
  Future<Job> createJob(Job job, {String? jdFilePath}) async {
     return remoteDataSource.createJob(job, jdFilePath: jdFilePath);
  }

  @override
  Future<Job> updateJob(String jobId, Job job, {String? jdFilePath}) async {
    return remoteDataSource.updateJob(jobId, job, jdFilePath: jdFilePath);
  }

  @override
  Future<APIResponse<String>> deleteJob(String jobId) async {
    return remoteDataSource.deleteJob(jobId);
  }
}
