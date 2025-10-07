import 'package:dio/dio.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  final Dio _dio;

  factory DioClient() => _instance;

  DioClient._internal() : _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 50),
    receiveTimeout: const Duration(seconds: 50),
    validateStatus: (status) {
        return status != null && status >= 200 && status < 500; // Chấp nhận 200-499
      },
  )) {
    // _dio.interceptors.add(LogInterceptor(
    //   request: true,
    //   responseBody: true,
    //   requestBody: true,
    // ));
  }

  Dio get instance => _dio;

  void setBaseUrl(String url) {
    _dio.options.baseUrl = url;
  }
}