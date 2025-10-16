import 'package:dio/dio.dart';
import 'package:pbl6/core/constants/api_constants.dart';
import 'package:pbl6/features/shared/category/domain/entities/category.dart';

abstract class CategoryRemoteDataSource {
  Future<List<Category>> fetchAllCategories();
  Future<Category> fetchCategory(String id);
  Future<Category> createCategory(Map<String, dynamic> body);
  Future<Category> updateCategory(String id, Map<String, dynamic> body);
  Future<void> deleteCategory(String id);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final Dio _dio;

  CategoryRemoteDataSourceImpl(this._dio) {
    _dio.options.baseUrl = ApiConstants.baseUrl;
  }

  @override
  Future<List<Category>> fetchAllCategories() async {
    final response = await _dio.get("${ApiConstants.profile}/category/all");
    final List<dynamic> data = response.data['result'];
    return data.map((json) => Category.fromJson(json)).toList();
  }

  @override
  Future<Category> fetchCategory(String id) async {
    final response = await _dio.get("${ApiConstants.profile}/category/$id");
    return Category.fromJson(response.data['result']);
  }

  @override
  Future<Category> createCategory(Map<String, dynamic> body) async {
    final response = await _dio.post("${ApiConstants.profile}/category", data: body);
    return Category.fromJson(response.data['result']);
  }

  @override
  Future<Category> updateCategory(String id, Map<String, dynamic> body) async {
    final response = await _dio.put("${ApiConstants.profile}/category/$id", data: body);
    return Category.fromJson(response.data['result']);
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _dio.delete("${ApiConstants.profile}/category/$id");
  }
}
