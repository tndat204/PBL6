// file: features/shared/profile/data/datasources/profile_remote_datasource.dart

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:pbl6/core/constants/api_constants.dart';

import '../models/profile_models.dart';


abstract class ProfileRemoteDataSource {
  Future<ProfileApiResponse> getMyProfile();
  Future<ProfileApiResponse> uploadCV(File cvFile);
  Future<ProfileApiResponse> getCVUrl();
  Future<ProfileApiResponse> createProfile(ProfileRequestModel request);
  // 💡 Bổ sung API cập nhật Profile
  Future<ProfileApiResponse> updateProfile(ProfileRequestModel request);

}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio _dio;
    ProfileRemoteDataSourceImpl(this._dio); 

  @override
  Future<ProfileApiResponse> getMyProfile() async {
    try {
      final response = await _dio.get("${ApiConstants.profiles}/me");
      
      // Trả về ProfileApiResponse chứa ProfileResponse
      return ProfileApiResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioError) {
        print('🟥 Dio error getting profile: ${e.response?.data}');
        // Xử lý lỗi chi tiết hơn nếu cần
      }
      throw Exception('Get my profile failed: $e');
    }
  }

  @override
  Future<ProfileApiResponse> uploadCV(File cvFile) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(cvFile.path, filename: cvFile.path.split('/').last),
      });

      final response = await _dio.put(
        "${ApiConstants.profiles}/me/cv",
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      
      // Trả về ProfileApiResponse chứa String (CV URL)
      return ProfileApiResponse.fromJson(response.data);

    } catch (e) {
      if (e is DioError) {
        print('🟥 Dio error uploading CV: ${e.response?.data}');
      }
      throw Exception('Upload CV failed: $e');
    }
  }

  @override
  Future<ProfileApiResponse> getCVUrl() async {
    try {
      final response = await _dio.get("${ApiConstants.profiles}/me/cv");
      
      // Trả về ProfileApiResponse chứa String (CV URL)
      return ProfileApiResponse.fromJson(response.data);

    } catch (e) {
      if (e is DioError) {
        print('🟥 Dio error getting CV URL: ${e.response?.data}');
      }
      throw Exception('Get CV URL failed: $e');
    }
  }
  // 💡 Bổ sung: POST /api/profile
  @override
  Future<ProfileApiResponse> createProfile(ProfileRequestModel request) async {
    try {
      final response = await _dio.post(
        ApiConstants.profiles, // /api/profile
        data: request.toJson(),
      );
      return ProfileApiResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioError) {
        print('🟥 Dio error creating profile: ${e.response?.data}');
      }
      throw Exception('Create profile failed: $e');
    }
  }

  // 💡 Bổ sung: PUT /api/profile
  @override
  Future<ProfileApiResponse> updateProfile(ProfileRequestModel request) async {
    try {
      final response = await _dio.put(
"${ApiConstants.profiles}/me", // /api/profile
        data: request.toJson(),
      );
      return ProfileApiResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioError) {
        print('🟥 Dio error updating profile: ${e.response?.data}');
      }
      throw Exception('Update profile failed: $e');
    }
  }
}