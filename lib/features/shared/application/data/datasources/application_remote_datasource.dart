import 'package:dio/dio.dart';
import 'package:pbl6/core/constants/api_constants.dart';

import '../../domain/entities/application.dart';

abstract class ApplicationRemoteDataSource {
  Future<Application> applyJob({required String jobId, String? notes});
  Future<List<Application>> getApplicationsForJob(String jobId);
  Future<Application> getApplicationDetail(String applicationId);
  Future<Application> updateApplicationStatus({
    required String applicationId,
    required ApplicationStatus newStatus,
  });
}

class ApplicationRemoteDataSourceImpl implements ApplicationRemoteDataSource {
  final Dio _dio;

  ApplicationRemoteDataSourceImpl(this._dio) {
    _dio.options.baseUrl = ApiConstants.baseUrl;
  }

  @override
  Future<Application> applyJob({required String jobId, String? notes}) async {
    try {
      final response = await _dio.post(
        ApiConstants.applications, // /api/applications
        data: {'jobId': jobId, 'notes': notes ?? ''},
      );

      if (response.statusCode == 200 && response.data['result'] != null) {
        final app = Application.fromJson(response.data['result']);
        print("✅ Apply job thành công: ${app.id}");
        return app;
      } else {
        throw Exception("❌ Apply job thất bại (${response.statusCode})");
      }
    } catch (e) {
      print("Lỗi applyJob: $e");
      rethrow;
    }
  }

  @override
  Future<List<Application>> getApplicationsForJob(String jobId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.applications}/job/$jobId',
      );

      if (response.statusCode == 200 && response.data['result'] != null) {
        final List<dynamic> resultList = response.data['result'];
        final applications = resultList
            .map((json) => Application.fromJson(json))
            .toList();
        return applications;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: "Lấy danh sách applications thất bại",
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception("Lỗi không xác định khi get applications: $e");
    }
  }

  @override
  Future<Application> getApplicationDetail(String applicationId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.applications}/$applicationId',
      );

      if (response.statusCode == 200 && response.data['result'] != null) {
        final app = Application.fromJson(response.data['result']);
        return app;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: "Lấy chi tiết application thất bại",
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception("Lỗi không xác định khi get application detail: $e");
    }
  }

  @override
  Future<Application> updateApplicationStatus({
    required String applicationId,
    required ApplicationStatus newStatus,
  }) async {
    try {
      final statusString = newStatus.toShortString();

      final response = await _dio.put(
        '${ApiConstants.applications}/$applicationId/status',
        queryParameters: {'newStatus': statusString},
      );

      if (response.statusCode == 200 && response.data['result'] != null) {
        final app = Application.fromJson(response.data['result']);
        return app;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: "Cập nhật status thất bại",
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception("Lỗi không xác định khi cập nhật status: $e");
    }
  }
}
