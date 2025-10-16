import '../entities/company.dart';
import '../repositories/company_repository.dart';

class GetAllCompaniesUseCase {
  final CompanyRepository repository;

  GetAllCompaniesUseCase(this.repository);

  Future<List<Company>> call() async {
    return await repository.fetchAllCompanies();
  }
}
