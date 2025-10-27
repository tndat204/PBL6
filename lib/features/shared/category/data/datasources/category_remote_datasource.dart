import 'package:dio/dio.dart';
import 'package:pbl6/core/constants/api_constants.dart';
import 'package:pbl6/features/shared/category/domain/entities/category.dart';

abstract class CategoryRemoteDataSource {
  Future<List<Category>> fetchAllCategories();
  Future<Category?> fetchCategory(String id); // 🌟 Đã sửa thành trả về Category?
  Future<Category> createCategory(Map<String, dynamic> body);
  Future<Category> updateCategory(String id, Map<String, dynamic> body);
  Future<void> deleteCategory(String id);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final Dio _dio;

  CategoryRemoteDataSourceImpl(this._dio) {
    // Đảm bảo Base URL được thiết lập
    _dio.options.baseUrl = ApiConstants.baseUrl;
  }

  @override
  Future<List<Category>> fetchAllCategories() async {
    final response = await _dio.get(ApiConstants.categories);
    final data = response.data;

    if (data == null || data['result'] == null) return [];

    final List<dynamic> list = data['result'];
    return list
        .map((json) => Category.fromJson(Map<String, dynamic>.from(json as Map))) 
        .toList();
  }

  @override
  Future<Category?> fetchCategory(String id) async { 
    try {
      final response = await _dio.get("${ApiConstants.categories}/$id");
      print(response.data);
      final dynamic rawData = response.data?['result'];
     
      if (rawData is Map) {
        final Map<String, dynamic> categoryData = Map<String, dynamic>.from(rawData);
        return Category.fromJson(categoryData);
      }
    } on DioException catch (e) {
      // Bắt lỗi HTTP (ví dụ: 404) do Dio ném ra.
      print("Dio Error fetching Category $id: $e");
    } catch (e) {
      // Bắt các lỗi khác
      print("Error fetching Category $id: $e");
    }
    
    // Trả về null khi API không tìm thấy (result: null) hoặc gặp lỗi Dio
    return null; 
  }

  @override
  Future<Category> createCategory(Map<String, dynamic> body) async {
    final response =
        await _dio.post(ApiConstants.categories, data: body);
        
    final dynamic rawData = response.data?['result'] ?? {};
    final Map<String, dynamic> data = Map<String, dynamic>.from(rawData as Map);
    
    return Category.fromJson(data);
  }

  @override
  Future<Category> updateCategory(String id, Map<String, dynamic> body) async {
    final response =
        await _dio.put("${ApiConstants.categories}/$id", data: body);
        
    final dynamic rawData = response.data?['result'] ?? {};
    final Map<String, dynamic> data = Map<String, dynamic>.from(rawData as Map);
    
    return Category.fromJson(data);
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _dio.delete("${ApiConstants.categories}/$id");
  }
}