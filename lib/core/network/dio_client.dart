import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Để lấy token từ local

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
    // Thêm interceptor cho logging (bỏ comment nếu cần debug)
    // _dio.interceptors.add(LogInterceptor(
    //   request: true,
    //   responseBody: true,
    //   requestBody: true,
    // ));

    // Interceptor cho token auth (thêm header Authorization)
   _dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) async {
    // Nếu endpoint là reset password thì bỏ qua token trong prefs
    if (options.path.contains('/api/auth/password/reset')) {
      return handler.next(options);
    }
    if (options.path.contains('/api/internal/users')) {
      return handler.next(options);
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  },
));

  }

  Dio get instance => _dio;

  void setBaseUrl(String url) {
    _dio.options.baseUrl = url;
  }
}