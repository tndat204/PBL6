import '../entities/company.dart';
import '../repositories/company_repository.dart';

class GetCompanyDetailsUseCase {
  final CompanyRepository repository;

  GetCompanyDetailsUseCase(this.repository);

  Future<Company> call(String id) async {
    return await repository.fetchCompanyDetails(id);
  }
}
