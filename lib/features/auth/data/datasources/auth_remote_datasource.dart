import 'package:dio/dio.dart';
import 'package:pbl6/core/services/api_service.dart';
import 'package:pbl6/features/auth/data/models/api_response_model.dart';
import 'package:pbl6/features/auth/data/models/login_response_model.dart';
import 'package:pbl6/features/auth/data/models/reset_password_request_model.dart';
import 'package:pbl6/features/auth/data/models/send_otp_request_model.dart';
import 'package:pbl6/features/auth/data/models/verify_otp_request_model.dart';

abstract class AuthRemoteDataSource {
  Future<List<Map<String, dynamic>>> fetchProvinces();
  Future<List<Map<String, dynamic>>> fetchWards(int provinceCode);
  Future<LoginResponse> login(String email, String password);
  Future<APIResponse<String>> sendOTP(SendOTPRequest request);
  Future<APIResponse<String>> verifyOTP(VerifyOTPRequest request);  
  Future<APIResponse<String>> resetPassword(ResetPasswordRequest request, String token);
  Future<LoginResponse> googleLogin(String idToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiService _apiService;
  final Dio _dio;

  // 👉 chỉ cần đổi 1 dòng này khi chạy emulator/máy thật/server khác
  // static const String baseUrl = 'http://10.0.2.2:8080/';
  static const String baseUrl ='http://192.168.1.195:8080/';

  AuthRemoteDataSourceImpl(this._apiService, this._dio) {
    _dio.options.baseUrl = baseUrl;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchProvinces() async {
    return await _apiService.getProvinces();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchWards(int provinceCode) async {
    return await _apiService.getWards(provinceCode);
  }

  @override
  Future<LoginResponse> login(String email, String password) async {
    final response = await _dio.post(
      '/api/auth/login',
      data: {'email': email, 'password': password},
    );
    return LoginResponse.fromJson(response.data);
  }

  @override
  Future<APIResponse<String>> sendOTP(SendOTPRequest request) async {
    final response = await _dio.post(
      '/api/auth/otp/forgot-password',
      data: request.toJson(),
    );
    return APIResponse.fromJson(response.data, (json) => json.toString());
  }

  @override
  Future<APIResponse<String>> verifyOTP(VerifyOTPRequest request) async {
    final response = await _dio.post(
      '/api/auth/otp/verify-otp',
      data: request.toJson(),
    );
    return APIResponse.fromJson(response.data, (json) => json.toString());
  }

  @override
  Future<APIResponse<String>> resetPassword(ResetPasswordRequest request, String token) async {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    final response = await _dio.post(
      '/api/auth/reset-password',
      data: request.toJson(),
    );
    return APIResponse.fromJson(response.data, (json) => json.toString());
  }

  @override
  Future<LoginResponse> googleLogin(String idToken) async {
    final response = await _dio.post('/api/auth/google-app?id_token=$idToken');
    return LoginResponse.fromJson(response.data);
  }
}
