import 'package:pbl6/core/usecase/usecase.dart';
import 'package:pbl6/features/shared/company/domain/entities/company.dart';
import 'package:pbl6/features/shared/company/domain/repositories/company_repository.dart';

class GetMyCompanyUseCase {
  final CompanyRepository repository;

  GetMyCompanyUseCase(this.repository);


  Future<Company> call(NoParams params) async {
    return repository.fetchMyCompany();
  }
}