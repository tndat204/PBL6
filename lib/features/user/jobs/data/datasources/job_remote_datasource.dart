import 'package:dio/dio.dart';
import 'package:pbl6/core/constants/api_constants.dart';

import '../../domain/entities/job.dart';

abstract class JobRemoteDataSource {
  Future<List<Job>> fetchAllJobs({String? category, String? keyword});
  Future<Job> fetchJobDetails(String jobId);
}

class JobRemoteDataSourceImpl implements JobRemoteDataSource {
  final Dio _dio;

  JobRemoteDataSourceImpl(this._dio) {
    _dio.options.baseUrl = ApiConstants.baseUrl;
  }

  @override
  Future<List<Job>> fetchAllJobs({String? category, String? keyword}) async {
    final response = await _dio.get(
      "${ApiConstants.jobs}/all",
      queryParameters: {
        if (category != null) "category": category,
        if (keyword != null) "q": keyword,
      },
    );

    final List<dynamic> data = response.data['result'];
    return data.map((job) => Job.fromJson(job)).toList();
  }

  @override
  Future<Job> fetchJobDetails(String jobId) async {
    final response = await _dio.get("${ApiConstants.jobs}/$jobId");
    final jobData = response.data['result'];
    return Job.fromJson(jobData);
  }
}
