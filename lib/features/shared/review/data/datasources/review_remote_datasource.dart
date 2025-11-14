import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:pbl6/core/constants/api_constants.dart';
import 'package:pbl6/features/shared/auth/data/models/api_response_model.dart';
import 'package:pbl6/features/shared/review/domain/entities/review.dart';
import 'package:pbl6/features/shared/review/domain/entities/review_paginated_response.dart'; // Cho MediaType

// Lớp trừu tượng
abstract class ReviewRemoteDataSource {
  Future<ReviewPaginatedResponse> getCompanyReviews({
    required String companyId,
    int page = 0,
    int size = 10,
  });

  Future<Review> getReviewDetail(String reviewId);

  Future<Review> createReview({
    required String companyId,
    required String title,
    required String comment,
    required double rating,
    List<File>? images,
  });

  Future<Review> updateReview({
    required String reviewId,
    required String title,
    required String comment,
    required double rating,
    List<File>? newImages,
  });

  Future<Review> toggleLikeReview(String reviewId);

  Future<APIResponse<String>> deleteReview(String reviewId);
}

// Lớp triển khai
class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final Dio _dio;

  ReviewRemoteDataSourceImpl(this._dio) {
    _dio.options.baseUrl = ApiConstants.baseUrl;
  }

  @override
  Future<ReviewPaginatedResponse> getCompanyReviews({
    required String companyId,
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.reviews}/company/$companyId',
        queryParameters: {'page': page, 'size': size},
      );

      if (response.statusCode == 200 && response.data['result'] != null) {
        return ReviewPaginatedResponse.fromJson(response.data['result']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  @override
  Future<Review> getReviewDetail(String reviewId) async {
    try {
      final response = await _dio.get('${ApiConstants.reviews}/$reviewId');
      if (response.statusCode == 200 && response.data['result'] != null) {
        return Review.fromJson(response.data['result']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  @override
  Future<Review> createReview({
    required String companyId,
    required String title,
    required String comment,
    required double rating,
    List<File>? images,
  }) async {
    try {
      final Map<String, dynamic> dataMap = {
        'companyId': companyId,
        'title': title,
        'comment': comment,
        'rating': rating,
      };

      if (images != null && images.isNotEmpty) {
        dataMap['images'] = [
          for (var file in images)
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
              contentType: MediaType('image', 'jpeg'), // Giả định là ảnh
            ),
        ];
      }

      final formData = FormData.fromMap(dataMap);

      final response = await _dio.post(
        ApiConstants.reviews,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200 && response.data['result'] != null) {
        return Review.fromJson(response.data['result']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  @override
  Future<Review> updateReview({
    required String reviewId,
    required String title,
    required String comment,
    required double rating,
    List<File>? newImages,
  }) async {
    try {
      final Map<String, dynamic> dataMap = {
        'title': title,
        'comment': comment,
        'rating': rating,
      };

      if (newImages != null && newImages.isNotEmpty) {
        dataMap['newImages'] = [
          for (var file in newImages)
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
              contentType: MediaType('image', 'jpeg'),
            ),
        ];
      }

      final formData = FormData.fromMap(dataMap);

      final response = await _dio.put(
        '${ApiConstants.reviews}/$reviewId',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200 && response.data['result'] != null) {
        return Review.fromJson(response.data['result']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  @override
  Future<Review> toggleLikeReview(String reviewId) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.reviews}/$reviewId/toggle-like',
      );
      if (response.statusCode == 200 && response.data['result'] != null) {
        return Review.fromJson(response.data['result']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  @override
  Future<APIResponse<String>> deleteReview(String reviewId) async {
    try {
      final response = await _dio.delete('${ApiConstants.reviews}/$reviewId');

      // API này trả về APIResponse<String>
      return APIResponse.fromJson(response.data, (data) => data.toString());
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }
}
