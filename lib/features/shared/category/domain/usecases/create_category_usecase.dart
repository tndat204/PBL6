
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class CreateCategoryUseCase {
  final CategoryRepository repository;
  CreateCategoryUseCase(this.repository);

  Future<Category> call(Map<String, dynamic> data) async =>
      await repository.createCategory(data);
}