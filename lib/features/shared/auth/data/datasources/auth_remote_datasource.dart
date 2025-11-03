import 'package:dio/dio.dart';
import 'package:pbl6/core/constants/api_constants.dart';
import 'package:pbl6/core/services/api_service.dart';
import 'package:pbl6/features/shared/auth/data/models/api_response_model.dart';
import 'package:pbl6/features/shared/auth/data/models/login_response_model.dart';
import 'package:pbl6/features/shared/auth/data/models/register_request_model.dart';
import 'package:pbl6/features/shared/auth/data/models/reset_password_request_model.dart';
import 'package:pbl6/features/shared/auth/data/models/send_otp_request_model.dart';
import 'package:pbl6/features/shared/auth/data/models/user_api_response.dart';
import 'package:pbl6/features/shared/auth/data/models/verify_otp_request_model.dart';

abstract class AuthRemoteDataSource {
  Future<List<Map<String, dynamic>>> fetchProvinces();
  Future<List<Map<String, dynamic>>> fetchWards(String provinceName);
  Future<LoginResponse> login(String email, String password);
  Future<APIResponse<String>> sendOTP(SendOTPRequest request);
  Future<APIResponse<String>> verifyOTP(VerifyOTPRequest request);
  Future<APIResponse<String>> resetPassword(
    ResetPasswordRequest request,
    String token,
  );
  Future<LoginResponse> googleLogin(String idToken);
  Future<UserApiResponse> register(RegisterRequest request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiService _apiService;
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._apiService, this._dio) {
    _dio.options.baseUrl = ApiConstants.baseUrl;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchProvinces() async {
    return await _apiService.getProvinces();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchWards(String provinceName) async {
    return await _apiService.getWards(provinceName);
  }

  @override
  Future<LoginResponse> login(String email, String password) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
    return LoginResponse.fromJson(response.data);
  }

  @override
  Future<APIResponse<String>> sendOTP(SendOTPRequest request) async {
    final response = await _dio.post(
      ApiConstants.sendOTP,
      data: request.toJson(),
    );
    return APIResponse.fromJson(response.data, (json) => json.toString());
  }

  @override
  Future<APIResponse<String>> verifyOTP(VerifyOTPRequest request) async {
    final response = await _dio.post(
      ApiConstants.verifyOTP,
      data: request.toJson(),
    );
    return APIResponse.fromJson(response.data, (json) => json.toString());
  }

  @override
  Future<APIResponse<String>> resetPassword(
    ResetPasswordRequest request,
    String token,
  ) async {
    final response = await _dio.post(
      ApiConstants.resetPassword,
      data: request.toJson(),
      // 💡 Chỉ áp dụng header cho request này
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return APIResponse.fromJson(response.data, (json) => json.toString());
  }

  @override
  Future<LoginResponse> googleLogin(String idToken) async {
    final response = await _dio.post(
      '${ApiConstants.googleLogin}?id_token=$idToken',
    );
    return LoginResponse.fromJson(response.data);
  }

  @override
  @override
  Future<UserApiResponse> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: request.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.data is String) {
        print('⚠️ Server trả về HTML hoặc chuỗi không hợp lệ!');
        throw Exception('Phản hồi không phải JSON: ${response.data}');
      }
      return UserApiResponse.fromJson(response.data);
    } catch (e) {
      print('❌ Đăng ký thất bại: $e');
      rethrow;
    }
  }
}
