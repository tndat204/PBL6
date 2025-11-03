import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio;

  ApiService(this._dio);

  // Hàm này đã chính xác
  Future<List<Map<String, dynamic>>> getProvinces() async {
    try {
      final response = await _dio.get('https://vietnamlabs.com/api/vietnamprovince').timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data != null && data['data'] is List) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
        
        throw Exception('Invalid response format: Missing or invalid "data" field.');
      } else {
        throw Exception('Failed to load provinces: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching provinces: $e');
    }
  }

  // SỬA LỖI LOGIC TẠI HÀM NÀY
  Future<List<Map<String, dynamic>>> getWards(String provinceName) async {
    try {
      final response = await _dio.get(
        'https://vietnamlabs.com/api/vietnamprovince',
        queryParameters: {'province': provinceName},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = response.data;
        
        // 1. Kiểm tra 'data' có phải là Map (chi tiết tỉnh) không
        if (data != null && data['data'] is Map<String, dynamic>) {
          final provinceDetail = data['data'] as Map<String, dynamic>;
          
          // 2. Trích xuất danh sách phường/xã từ khóa 'wards'
          if (provinceDetail['wards'] is List) {
            return List<Map<String, dynamic>>.from(provinceDetail['wards']);
          }
          
          // Nếu không tìm thấy trường 'wards' hoặc không phải là List
          throw Exception('Invalid province detail format: Missing or invalid "wards" field.');
        }
        
        // Nếu trường 'data' không phải là Map
        throw Exception('Invalid response format: Missing or invalid "data" field (expected Map).');
      } else {
        throw Exception('Failed to load wards: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching wards: $e');
    }
  }
}