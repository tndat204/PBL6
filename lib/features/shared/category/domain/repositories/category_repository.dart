import '../entities/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getAllCategories();
  Future<Category?> getCategoryById(String id);
  Future<Category> createCategory(Map<String, dynamic> data);
  Future<Category> updateCategory(String id, Map<String, dynamic> data);
  Future<void> deleteCategory(String id);
}
