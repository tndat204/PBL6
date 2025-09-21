import 'package:dio/dio.dart';
import 'package:pbl6/core/services/api_service.dart';

abstract class AuthRemoteDataSource {
  Future<List<Map<String, dynamic>>> fetchProvinces();
  Future<List<Map<String, dynamic>>> fetchWards(int provinceCode);
  Future<Map<String, dynamic>> login(String email, String password);
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
}