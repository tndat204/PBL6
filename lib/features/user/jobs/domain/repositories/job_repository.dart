import '../entities/job.dart';

abstract class JobRepository {
  Future<List<Job>> fetchAllJobs({String? category, String? keyword});
  Future<Job> fetchJobDetails(String jobId);
}
