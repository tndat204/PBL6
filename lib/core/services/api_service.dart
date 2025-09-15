
import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio;

  ApiService(this._dio);

  // Lấy danh sách tỉnh/thành phố
  Future<List<Map<String, dynamic>>> getProvinces() async {
    try {
      final response = await _dio.get('https://provinces.open-api.vn/api/v2/p/').timeout(const Duration(seconds: 10));
      print('Provinces API response: ${response.data}');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else {
          throw Exception('Provinces data is not a list');
        }
      } else {
        throw Exception('Failed to load provinces: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching provinces: $e');
    }
  }

  // Lấy danh sách phường/xã của 1 tỉnh
  Future<List<Map<String, dynamic>>> getWards(int provinceCode) async {
    try {
      final response = await _dio.get('https://provinces.open-api.vn/api/v2/p/$provinceCode?depth=2').timeout(const Duration(seconds: 10));
      print('Wards API response: ${response.data}');
      if (response.statusCode == 200) {
        final wards = response.data['wards'] ?? [];
        if (wards is List) {
          return List<Map<String, dynamic>>.from(wards);
        } else {
          throw Exception('Wards data is not a list');
        }
      } else {
        throw Exception('Failed to load wards: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching wards: $e');
    }
  }

  // Gửi yêu cầu đăng ký nhà tuyển dụng
  Future<void> signupEmployer({
    required String fullName,
    required String companyName,
    required String phone,
    required String province,
    required String ward,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/signup/employer',
        data: {
          'fullName': fullName,
          'companyName': companyName,
          'phone': phone,
          'province': province,
          'ward': ward,
          'email': email,
          'password': password,
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to sign up: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error signing up: $e');
    }
  }
}
