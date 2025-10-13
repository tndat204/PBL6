import '../entities/category.dart';
import '../entities/company.dart';
import '../entities/job_post.dart';
abstract class JobRepository {
  Future<List<JobPost>> getJobs({String? category, String? searchQuery});
  Future<Company> getCompany(String companyId);
  Future<List<Category>> getCategories();
}