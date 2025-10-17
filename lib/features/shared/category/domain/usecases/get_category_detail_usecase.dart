

import '../entities/category.dart';
import '../repositories/category_repository.dart';

class GetCategoryDetailUseCase {
  final CategoryRepository repository;
  GetCategoryDetailUseCase(this.repository);

  Future<Category?> call(String id) async => await repository.getCategoryById(id);
}