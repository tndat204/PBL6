import 'package:dio/dio.dart';
import 'package:pbl6/core/constants/api_constants.dart';
import 'package:pbl6/core/services/api_service.dart';
import 'package:pbl6/features/shared/auth/data/models/user_api_response.dart';



abstract class UserRemoteDataSource {
  Future<UserApiResponse> getMyInfo();
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
}

