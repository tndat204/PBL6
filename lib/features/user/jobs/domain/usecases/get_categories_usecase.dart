import '../entities/category.dart';
import '../repositories/job_repository.dart';

class GetCategoriesUseCase {
  final JobRepository repository;

  GetCategoriesUseCase(this.repository);

  Future<List<Category>> call() async {
    return await repository.getCategories();
  }
}