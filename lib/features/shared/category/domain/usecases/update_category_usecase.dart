
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class UpdateCategoryUseCase {
  final CategoryRepository repository;
  UpdateCategoryUseCase(this.repository);

  Future<Category> call(String id, Map<String, dynamic> data) async =>
      await repository.updateCategory(id, data);
}