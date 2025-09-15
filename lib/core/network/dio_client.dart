import 'package:dio/dio.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  final Dio _dio;

  factory DioClient() {
    return _instance;
  }

  DioClient._internal() : _dio = Dio(BaseOptions(
          baseUrl: 'https://provinces.open-api.vn/api/',
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 3),
        )) {
    _dio.interceptors.add(LogInterceptor(
      request: true,
      responseBody: true,
      requestBody: true,
    )); // Thêm interceptor để debug
  }

  Dio get instance => _dio;
}