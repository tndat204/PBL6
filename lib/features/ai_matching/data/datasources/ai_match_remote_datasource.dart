import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:pbl6/features/ai_matching/domain/entities/ai_matching_entities.dart';

abstract class AiMatchRemoteDataSource {
  // API URL: http://127.0.0.1:8000/match/multiple
  Future<AiMatchResponse> matchMultipleCvs({
    required String jdFilePath,
    required List<String> cvFilePaths, // Đường dẫn cục bộ của CVs
    MatchWeights? weights,
  });

  // API URL: http://127.00.1:8000/match
  Future<CvMatchResult> matchSingleCv({
    required String jdFilePath,
    required String cvFilePath,
    MatchWeights? weights,
  });
}

class AiMatchRemoteDataSourceImpl implements AiMatchRemoteDataSource {
  // 💡 Địa chỉ IP và Port của dịch vụ AI
  static const String _aiBaseUrl = "http://127.0.0.1:8000";

  final Dio _dio;

  AiMatchRemoteDataSourceImpl(this._dio);

  // Helper để tạo FormData cho File và Weights
  Future<FormData> _buildFormData({
    required String jdFilePath,
    required List<String> cvFilePaths,
    MatchWeights? weights,
    String? cvFilePath, // Chỉ dùng cho single match
  }) async {
    final formData = FormData();

    // 1. Thêm JD File
    formData.files.add(
      MapEntry(
        "jd",
        await MultipartFile.fromFile(
          jdFilePath,
          filename: jdFilePath.split('/').last,
          contentType: MediaType('application', 'pdf'),
        ),
      ),
    );

    // 2. Thêm CVs (dùng cho multiple)
    if (cvFilePaths.isNotEmpty) {
      for (var path in cvFilePaths) {
        // API Multiple Match yêu cầu gửi nhiều file CV (Key: cvs)
        formData.files.add(
          MapEntry(
            "cvs", // 💡 Key 'cvs'
            await MultipartFile.fromFile(
              path,
              filename: path.split('/').last,
              contentType: MediaType('application', 'pdf'),
            ),
          ),
        );
      }
    }

    // 3. Thêm CV (dùng cho single)
    if (cvFilePath != null) {
      formData.files.add(
        MapEntry(
          "cv", // 💡 Key 'cv'
          await MultipartFile.fromFile(
            cvFilePath,
            filename: cvFilePath.split('/').last,
            contentType: MediaType('application', 'pdf'),
          ),
        ),
      );
    }

  
    formData.fields.add(MapEntry("weights", jsonEncode(weights?.toJson())));

    return formData;
  }

  @override
  Future<AiMatchResponse> matchMultipleCvs({
    required String jdFilePath,
    required List<String> cvFilePaths,
    MatchWeights? weights,
  }) async {
    if (cvFilePaths.isEmpty) {
      throw Exception("Vui lòng cung cấp ít nhất một CV để so khớp.");
    }

    final formData = await _buildFormData(
      jdFilePath: jdFilePath,
      cvFilePaths: cvFilePaths,
      weights: weights,
    );

    try {
      final response = await _dio.post(
        '$_aiBaseUrl/match/multiple',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      // Giả định response.data là Map JSON chứa 'jd_filename', 'results', v.v.
      if (response.statusCode == 200 && response.data != null) {
        return AiMatchResponse.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Lỗi AI Match Multiple: $e');
    }
  }

  @override
  Future<CvMatchResult> matchSingleCv({
    required String jdFilePath,
    required String cvFilePath,
    MatchWeights? weights,
  }) async {
    final formData = await _buildFormData(
      jdFilePath: jdFilePath,
      cvFilePaths: [], // Không dùng cho single
      cvFilePath: cvFilePath,
      weights: weights,
    );

    try {
      final response = await _dio.post(
        '$_aiBaseUrl/match',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200 && response.data != null) {
        // API single match trả về object CvMatchResult trực tiếp (không nằm trong list)
        return CvMatchResult.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Lỗi AI Match Single: $e');
    }
  }
}
