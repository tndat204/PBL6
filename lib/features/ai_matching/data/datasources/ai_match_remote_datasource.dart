import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:pbl6/features/ai_matching/domain/entities/ai_matching_entities.dart';

abstract class AiMatchRemoteDataSource {
  Future<AiMatchResponse> matchMultipleCvs({
    required String jdUrl,
    required List<String> cvUrls,
    MatchWeights? weights,
  });

  Future<CvMatchResult> matchSingleCv({
    required String jdFilePath,
    required String cvFilePath,
    MatchWeights? weights,
  });
  Future<JdSummaryResponse> summarizeJd({
    required String jdFilePath,
  });
}

class AiMatchRemoteDataSourceImpl implements AiMatchRemoteDataSource {
  static const String _aiBaseUrl = "http://10.0.2.2:8000";

  final Dio _dio;

  AiMatchRemoteDataSourceImpl(this._dio);

  Future<FormData> _buildFormData({
    required String jdFilePath,
    required List<String> cvFilePaths,
    MatchWeights? weights,
    String? cvFilePath,
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
    required String jdUrl,
    required List<String> cvUrls,
    MatchWeights? weights,
  }) async {
    
    final formData = FormData();

    // 1. JD URL
    formData.fields.add(MapEntry("jd_url", jdUrl));

    // 🔴 SỬA ĐỔI QUAN TRỌNG TẠI ĐÂY:
    // Thay vì gửi từng dòng, ta gom nó thành chuỗi JSON String: '["url1", "url2", ...]'
    // Điều này giúp Backend Python json.loads() được ngay.
    formData.fields.add(MapEntry("cv_urls", jsonEncode(cvUrls))); 

    // 3. Weights
    // Nếu weights null, ta gửi "{}" (JSON rỗng) để tránh backend parse null bị lỗi
    if (weights != null) {
      formData.fields.add(MapEntry("weights", jsonEncode(weights.toJson())));
    } else {
      formData.fields.add(const MapEntry("weights", "{}"));
    }

    try {
      final response = await _dio.post(
        '$_aiBaseUrl/match/multiple',
        data: formData,
        options: Options(
          // Dio tự động set multipart/form-data
          headers: {
            "X-API-Key": "8f1c0c4d-0a0c-4e5e-b3b3-f1c8bde4a7d7",
            "Connection": "keep-alive",
          },
          sendTimeout: const Duration(milliseconds: 60000),
          receiveTimeout: const Duration(milliseconds: 60000),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return AiMatchResponse.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: "Server returned status: ${response.statusCode}",
        );
      }
    } on DioException catch (e) {
      // In chi tiết lỗi server trả về để debug
      if (e.response != null) {
        print("❌ Server Error Data: ${e.response?.data}");
      }
      throw Exception('Lỗi kết nối AI Server: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
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
        options: Options(
          contentType: 'multipart/form-data',
          // 🟢 ĐÃ THÊM HEADER VÀO ĐÂY
          headers: {
            "X-API-Key": "8f1c0c4d-0a0c-4e5e-b3b3-f1c8bde4a7d7",
            "Connection": "keep-alive",
          },
          sendTimeout: const Duration(milliseconds: 60000),
          receiveTimeout: const Duration(milliseconds: 60000),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return CvMatchResult.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Lỗi AI Match Single: $e');
    }
  }
  @override
  Future<JdSummaryResponse> summarizeJd({
    required String jdFilePath,
  }) async {
    final formData = FormData();

    // Key trong Swagger là "jd_file"
    formData.files.add(
      MapEntry(
        "jd_file", 
        await MultipartFile.fromFile(
          jdFilePath,
          filename: jdFilePath.split('/').last,
          contentType: MediaType('application', 'pdf'), // Giả định là PDF
        ),
      ),
    );

    try {
      final response = await _dio.post(
        '$_aiBaseUrl/summarize-jd',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {
            "X-API-Key": "8f1c0c4d-0a0c-4e5e-b3b3-f1c8bde4a7d7",
            "Connection": "keep-alive",
          },
          // Tăng timeout vì đọc PDF và tóm tắt có thể lâu
          sendTimeout: const Duration(milliseconds: 60000),
          receiveTimeout: const Duration(milliseconds: 60000),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return JdSummaryResponse.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: "Server returned status: ${response.statusCode}",
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print("❌ Summarize Error Data: ${e.response?.data}");
      }
      throw Exception('Lỗi tóm tắt JD: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }
}
