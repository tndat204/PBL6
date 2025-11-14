import 'dart:io';

import 'package:dio/dio.dart';
import 'package:pbl6/core/constants/api_constants.dart';

import '../../domain/entities/application.dart';

abstract class ApplicationRemoteDataSource {
  Future<Application> applyJob({
    required String jobId,
    String? notes,
    String? filePath,
  });
  Future<List<Application>> getApplicationsForJob(String jobId);
  Future<Application> getApplicationDetail(String applicationId);
  Future<Application> updateApplicationStatus({
    required String applicationId,
    required ApplicationStatus newStatus,
  });
  Future<List<Application>> getMyApplications();
}

class ApplicationRemoteDataSourceImpl implements ApplicationRemoteDataSource {
  final Dio _dio;

  ApplicationRemoteDataSourceImpl(this._dio) {
    _dio.options.baseUrl = ApiConstants.baseUrl;
  }

  @override
  Future<Application> applyJob({
    required String jobId,
    String? notes,
    String? filePath,
  }) async {
    try {
      final formData = FormData();
      formData.fields.add(MapEntry('jobId', jobId));
      formData.fields.add(MapEntry('notes', notes ?? ''));
      if (filePath != null && filePath.isNotEmpty) {
        final file = File(filePath);
        final multipart = await MultipartFile.fromFile(
          filePath,
          filename: file.path.split('/').last,
        );
        formData.files.add(MapEntry('cv', multipart));
      }
      final response = await _dio.post(
        ApiConstants.applications,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      if (response.statusCode == 200 && response.data['result'] != null) {
        return Application.fromJson(response.data['result']);
      } else {
        throw Exception("Apply Job thất bại: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception("DioException applyJob: ${e.message}");
    } catch (e) {
      throw Exception("Lỗi applyJob: $e");
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

  @override
  Future<List<Application>> getMyApplications() async {
    try {
      final response = await _dio.get('${ApiConstants.applications}/me');

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
          message: "Lấy danh sách applications của tôi thất bại",
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception("Lỗi không xác định khi get my applications: $e");
    }
  }
}
