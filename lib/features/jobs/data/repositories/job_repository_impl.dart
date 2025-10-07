import '../../domain/entities/category.dart';
import '../../domain/entities/company.dart';
import '../../domain/entities/job_post.dart';
import '../../domain/repositories/job_repository.dart';
import '../datasources/job_local_datasource.dart'; // Sau thay remote

class JobRepositoryImpl implements JobRepository {
  final JobLocalDataSource localDataSource; // Sau: + RemoteDataSource

  JobRepositoryImpl(this.localDataSource);

  @override
  Future<List<JobPost>> getJobs({String? category, String? searchQuery}) async {
    return localDataSource.getJobs(category: category, searchQuery: searchQuery);
  }

  @override
  Future<Company> getCompany(String companyId) async {
    return localDataSource.getCompany(companyId);
  }

  @override
  Future<List<Category>> getCategories() async {
    return localDataSource.getCategories();
  }
}