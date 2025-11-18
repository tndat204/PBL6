import 'package:dio/dio.dart';
import 'package:pbl6/core/constants/api_constants.dart';
import 'package:pbl6/features/shared/auth/data/models/api_response_model.dart';

import '../../domain/entities/job.dart';

abstract class JobRemoteDataSource {
  Future<List<Job>> fetchAllJobs({
    String? category,
    String? keyword,
    String? companyId,
    JobStatus? status,
  });

  Future<Job> fetchJobDetails(String jobId);

  Future<Job> createJob(Job job, {String? jdFilePath});

  Future<Job> updateJob(String jobId, Job job, {String? jdFilePath});

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
        if (status != null) "status": status.name,
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

    @override
  Future<Job> createJob(Job job, {String? jdFilePath}) async {
    try {
      final formData = FormData();

      final data = job.toJsonForUpsert();

      data.forEach((key, value) {
        if (value is List) {
          for (var item in value) {
            formData.fields.add(MapEntry(key, item.toString()));
          }
        } else {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      });

      if (jdFilePath != null && jdFilePath.isNotEmpty) {
        formData.files.add(
          MapEntry(
            "jdFile",
            await MultipartFile.fromFile(
              jdFilePath,
              filename: jdFilePath.split('/').last,
            ),
          ),
        );
      }
     
      final response = await _dio.post(
        ApiConstants.jobs,
        data: formData,
        options: Options(contentType: "multipart/form-data"),
      );
   
     
      final resultData = response.data?['result'];
      if (resultData != null) {
        return Job.fromJson(resultData);
      } else {
        throw Exception("Create Job thành công nhưng không nhận được dữ liệu Job.");
      }

    } catch (e) {
      if (e is DioException) {
      
        throw Exception("Lỗi create job (Dio): ${e.response?.data ?? e.message}");
      }
      throw Exception("Lỗi create job: $e");
    }
  }

  @override
  Future<Job> updateJob(String jobId, Job job, {String? jdFilePath}) async {
    try {
      final formData = FormData();

      final data = job.toJsonForUpsert();

      data.forEach((key, value) {
        if (value is List) {
          for (var item in value) {
            formData.fields.add(MapEntry(key, item.toString()));
          }
        } else {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      });

      if (jdFilePath != null && jdFilePath.isNotEmpty) {
        formData.files.add(
          MapEntry(
            "jdFile",
            await MultipartFile.fromFile(
              jdFilePath,
              filename: jdFilePath.split('/').last,
            ),
          ),
        );
      }
    
      final response = await _dio.put(
        "${ApiConstants.jobs}/$jobId",
        data: formData,
        options: Options(contentType: "multipart/form-data"),
      );

      final resultData = response.data?["result"];
      if (response.statusCode == 200 && resultData != null) {
        return Job.fromJson(resultData);
      } else {
        throw Exception("Update Job thất bại: ${response.data}");
      }
    } on DioException catch (e) {
      throw Exception("Lỗi updateJob (Dio): ${e.response?.data ?? e.message}");
    } catch (e) {
      throw Exception("Lỗi không xác định updateJob: $e");
    }
  }

  @override
  Future<APIResponse<String>> deleteJob(String jobId) async {
    final response = await _dio.delete("${ApiConstants.jobs}/$jobId");

    return APIResponse.fromJson(response.data, (json) => json.toString());
  }
}
