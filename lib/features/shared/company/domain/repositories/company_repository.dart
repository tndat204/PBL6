import '../entities/company.dart';

abstract class CompanyRepository {
  Future<List<Company>> fetchAllCompanies();
  Future<Company> fetchCompanyDetails(String id);
}
