import 'package:pbl6/features/shared/auth/data/models/api_response_model.dart';

import '../entities/job.dart';

abstract class JobRepository {
  Future<List<Job>> fetchAllJobs({
    String? category,
    String? keyword,
    String? companyId,
    JobStatus? status,
  });

  /// Fetches the details for a single job by its ID.
  Future<Job> fetchJobDetails(String jobId);

  /// Creates a new job posting.
  Future<Job> createJob(Job job, {String? jdFilePath});

  /// Updates an existing job posting by its ID.
  Future<Job> updateJob(String jobId, Job job, {String? jdFilePath});

  /// Deletes a job posting by its ID.
  Future<APIResponse<String>> deleteJob(String jobId);
}
