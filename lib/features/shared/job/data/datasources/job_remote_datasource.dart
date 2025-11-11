
import 'package:dio/dio.dart';
import 'package:pbl6/core/constants/api_constants.dart';
import 'package:pbl6/features/shared/auth/data/models/api_response_model.dart';

import '../../domain/entities/job.dart';

abstract class JobRemoteDataSource {
  /// Fetches a list of all jobs based on optional filters.
  /// (Based on GET /api/jobs)
  Future<List<Job>> fetchAllJobs({
    String? category,
    String? keyword,
    String? companyId,
    JobStatus? status,
  });

  /// Fetches the details for a single job by its ID.
  /// (Based on GET /api/jobs/{id})
  Future<Job> fetchJobDetails(String jobId);

  /// Creates a new job posting.
  /// (Based on POST /api/jobs)
  Future<Job> createJob(Job job);

  /// Updates an existing job posting by its ID.
  /// (Based on PUT /api/jobs/{id})
  Future<Job> updateJob(String jobId, Job job);

  /// Deletes a job posting by its ID.
  /// (Based on DELETE /api/jobs/{id})
  Future<APIResponse<String>> deleteJob(String jobId);
}

class JobRemoteDataSourceImpl implements JobRemoteDataSource {
  final Dio _dio;

  JobRemoteDataSourceImpl(this._dio) {
    _dio.options.baseUrl = ApiConstants.baseUrl;
  }

  @override
  Future<List<Job>> fetchAllJobs({
    String? category,
    String? keyword,
    String? companyId,
    JobStatus? status,
  }) async {
    final response = await _dio.get(
      ApiConstants.jobs,
      queryParameters: {
        if (category != null) "category": category,
        if (keyword != null) "q": keyword,
        if (companyId != null) "companyId": companyId,
        if (status != null) "status": status.name, // Gửi tên enum (ví dụ: "ACTIVE")
      },
    );

    // Dựa trên response API của bạn (có 'result' là một List)
    final List<dynamic> data = response.data['result'];
    return data.map((job) => Job.fromJson(job)).toList();
  }

  @override
  Future<Job> fetchJobDetails(String jobId) async {
    final response = await _dio.get("${ApiConstants.jobs}/$jobId");
    // Dựa trên response API của bạn (có 'result' là một Object)
    final jobData = response.data['result'];
    return Job.fromJson(jobData);
  }

  @override
  Future<Job> createJob(Job job) async {
    final response = await _dio.post(
      ApiConstants.jobs,
      data: job.toJsonForUpsert(), // Gửi Map đã được chuẩn bị
    );
    // Dựa trên response API (trả về {code, message, result: {job}})
    final jobData = response.data['result'];
    return Job.fromJson(jobData);
  }

  @override
  Future<Job> updateJob(String jobId, Job job) async {
    final response = await _dio.put(
      "${ApiConstants.jobs}/$jobId",
      data: job.toJsonForUpsert(), // Gửi Map đã được chuẩn bị
    );
    // Dựa trên response API (trả về {code, message, result: {job}})
    final jobData = response.data['result'];
    return Job.fromJson(jobData);
  }

  @override
  Future<APIResponse<String>> deleteJob(String jobId) async {
    final response = await _dio.delete(
      "${ApiConstants.jobs}/$jobId",
    );
    // Dựa trên response API (trả về {code, message, result: "string"})
    return APIResponse.fromJson(response.data, (json) => json.toString());
  }
}