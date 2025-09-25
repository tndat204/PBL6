import 'package:dio/dio.dart';
import 'package:pbl6/core/services/api_service.dart';
import 'package:pbl6/features/auth/data/models/api_response_model.dart';
import 'package:pbl6/features/auth/data/models/reset_password_request_model.dart';
import 'package:pbl6/features/auth/data/models/send_otp_request_model.dart';
import 'package:pbl6/features/auth/data/models/verify_otp_request_model.dart';
abstract class AuthRemoteDataSource {
  Future<List<Map<String, dynamic>>> fetchProvinces();
  Future<List<Map<String, dynamic>>> fetchWards(int provinceCode);
  Future<Map<String, dynamic>> login(String email, String password);
  Future<APIResponse<String>> sendOTP(SendOTPRequest request);
  Future<APIResponse<String>> verifyOTP(VerifyOTPRequest request);  
  Future<APIResponse<String>> resetPassword(ResetPasswordRequest request, String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiService _apiService;
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._apiService, this._dio);

  @override
  Future<List<Map<String, dynamic>>> fetchProvinces() async {
    return await _apiService.getProvinces();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchWards(int provinceCode) async {
    return await _apiService.getWards(provinceCode);
  }

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    _dio.options.baseUrl = 'http://10.0.2.2:8080/';
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {'email': email, 'password': password},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Error logging in: $e');
    }
  }
  Future<APIResponse<String>> sendOTP(SendOTPRequest request) async {
    _dio.options.baseUrl = 'http://10.0.2.2:8080/';
    final response = await _dio.post('/api/auth/otp/forgot-password', data: request.toJson());
    return APIResponse.fromJson(response.data, (json) => json.toString());
  }
 Future<APIResponse<String>> verifyOTP(VerifyOTPRequest request) async {
    _dio.options.baseUrl = 'http://10.0.2.2:8080/';
    final response = await _dio.post('/api/auth/otp/verify-otp', data: request.toJson());
    return APIResponse.fromJson(response.data, (json) => json.toString());
  }

  Future<APIResponse<String>> resetPassword(ResetPasswordRequest request, String token) async {
    _dio.options.baseUrl = 'http://10.0.2.2:8080/';
    _dio.options.headers['Authorization'] = 'Bearer $token';
    final response = await _dio.post('/api/auth/reset-password', data: request.toJson());
    return APIResponse.fromJson(response.data, (json) => json.toString());
  }
}