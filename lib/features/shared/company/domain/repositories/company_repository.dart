import 'package:pbl6/features/shared/auth/data/models/api_response_model.dart';

import '../entities/company.dart';

abstract class CompanyRepository {
  Future<List<Company>> fetchAllCompanies();
  Future<Company> fetchCompanyDetails(String id);
  Future<Company> fetchMyCompany();
  Future<Company> updateCompanyDetails(String id, Company company);
  Future<APIResponse<String>> updateCompanyLogo(
    String companyId,
    String filePath,
  );
}
