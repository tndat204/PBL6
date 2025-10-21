import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio;

  ApiService(this._dio);

  Future<List<Map<String, dynamic>>> getProvinces() async {
    try {
      final response = await _dio.get('https://provinces.open-api.vn/api/v2/').timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Failed to load provinces: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching provinces: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getWards(int provinceCode) async {
    try {
      final response = await _dio.get('https://provinces.open-api.vn/api/v2/p/$provinceCode?depth=2').timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['wards'] ?? []);
      } else {
        throw Exception('Failed to load wards: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching wards: $e');
    }
  }
}
