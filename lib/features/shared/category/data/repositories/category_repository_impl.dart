import 'package:pbl6/features/shared/category/data/datasources/category_remote_datasource.dart';
import 'package:pbl6/features/shared/category/domain/entities/category.dart';
import 'package:pbl6/features/shared/category/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remoteDataSource;

  CategoryRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Category>> getAllCategories() => remoteDataSource.fetchAllCategories();

  @override
  Future<Category?> getCategoryById(String id) => remoteDataSource.fetchCategory(id);

  @override
  Future<Category> createCategory(Map<String, dynamic> data) => remoteDataSource.createCategory(data);

  @override
  Future<Category> updateCategory(String id, Map<String, dynamic> data) => remoteDataSource.updateCategory(id, data);

  @override
  Future<void> deleteCategory(String id) => remoteDataSource.deleteCategory(id);
}
