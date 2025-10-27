import 'package:dio/dio.dart';
import 'package:pbl6/core/constants/api_constants.dart';

import '../../domain/entities/application.dart';


/// 🎯 DataSource thao tác với Application API
abstract class ApplicationRemoteDataSource {
  /// Ứng tuyển công việc (Apply Job)
  Future<Application> applyJob({
    required String jobId,
    String? notes,
  });
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
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.applications, // /api/applications
        data: {
          'jobId': jobId,
          'notes': notes ?? '',
        },
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
}
