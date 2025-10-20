import 'dart:io';

import 'package:dio/dio.dart';
import 'package:pbl6/core/constants/api_constants.dart';
import 'package:pbl6/core/services/api_service.dart';
import 'package:pbl6/features/shared/auth/data/models/user_api_response.dart';

abstract class UserRemoteDataSource {
  Future<UserApiResponse> getMyInfo();
  Future<UserApiResponse> updateMyInfo(Map<String, dynamic> updatedData);
  Future<String> uploadAvatar(File imageFile);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final ApiService apiService;
  final Dio _dio;

  UserRemoteDataSourceImpl(this.apiService, this._dio) {
    _dio.options.baseUrl = ApiConstants.baseUrl;
  }

  @override
  Future<UserApiResponse> getMyInfo() async {
    try {
      final response = await _dio.get(ApiConstants.getMyInfo);
      return UserApiResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Get my info failed: $e');
    }
  }

  @override
  Future<UserApiResponse> updateMyInfo(Map<String, dynamic> updatedData) async {
    try {
      final response = await _dio.patch(
        ApiConstants.updateMyInfo,
        data: updatedData,
      );
      return UserApiResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Update user info failed: $e');
    }
  }

  @override
  @override
  Future<String> uploadAvatar(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imageFile.path),
      });

      final response = await _dio.put(
        ApiConstants.uploadAvatar,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      // Kiểm tra phản hồi
      final code = response.data['code'];
      if (code == 0 || code == 200) {
        return response.data['result'];
      } else {
        throw Exception(response.data['message'] ?? 'Upload avatar failed');
      }
    } catch (e) {
      if (e is DioError) {
        print('🟥 Dio error: ${e.response?.data}');
      }
      throw Exception('Upload avatar failed: $e');
    }
  }
}
