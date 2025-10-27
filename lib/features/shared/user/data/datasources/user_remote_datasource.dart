import 'dart:io';

import 'package:dio/dio.dart';
import 'package:pbl6/core/constants/api_constants.dart';
import 'package:pbl6/core/services/api_service.dart';
import 'package:pbl6/features/shared/auth/data/models/user_api_response.dart';

abstract class UserRemoteDataSource {
  Future<UserApiResponse> getMyInfo();
  Future<UserApiResponse> updateMyInfo(Map<String, dynamic> updatedData);
  Future<String> uploadAvatar(File imageFile);
  Future<void> changePassword({required String oldPassword, required String newPassword});
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
  @override
  Future<void> changePassword({required String oldPassword, required String newPassword}) async {
    try {
      final response = await _dio.put( 
        ApiConstants.changePassword, 
        data: {
          "oldPassword": oldPassword,
          "newPassword": newPassword,
        },
      );

      
       if (response.statusCode == 200 && response.data != null && response.data is Map) {
          final responseData = response.data as Map<String, dynamic>;
          final code = responseData['code'];
          // Check for success code (0 or 200)
          if (code != 0 && code != 200) {
             // Throw exception with the message from the API if available
             throw Exception(responseData['message'] ?? 'Change password failed with code $code');
          }
          // If code is 0 or 200, operation was successful, return void
          print("Password changed successfully: ${responseData['result']}"); // Log success message
       } else {
          // Handle non-200 status codes or invalid data structure
          throw DioException(
             requestOptions: response.requestOptions,
             response: response,
             error: 'Invalid response data or status code (${response.statusCode})',
           );
       }
    } on DioException catch (e) {
      // Handle Dio-specific errors (network, timeout, etc.)
      print('🟥 Dio error [changePassword]: ${e.response?.data ?? e.message}');
      // Re-throw with a user-friendly message, potentially using the API's error message
      throw Exception('Change password failed: ${e.response?.data?['message'] ?? e.message}');
    } catch (e) {
       // Handle other unexpected errors
       print('🟥 Unexpected error [changePassword]: $e');
       throw Exception('Change password failed: $e');
    }
  }

}
