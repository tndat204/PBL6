import 'package:pbl6/features/shared/auth/data/models/api_response_model.dart';

import '../../domain/entities/company.dart';
import '../../domain/repositories/company_repository.dart';
import '../datasources/company_remote_datasource.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  final CompanyRemoteDataSource remoteDataSource;

  CompanyRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Company>> fetchAllCompanies() async {
    return await remoteDataSource.fetchAllCompanies();
  }

  @override
  Future<Company> fetchCompanyDetails(String id) async {
    return await remoteDataSource.fetchCompanyDetails(id);
  }
  @override
  Future<Company> fetchMyCompany() {
    return remoteDataSource.fetchMyCompany();
  }

  @override
  Future<Company> updateCompanyDetails(String id, Company company) {
    return remoteDataSource.updateCompanyDetails(id, company);
  }

  @override
  Future<APIResponse<String>> updateCompanyLogo(String companyId, String filePath) {
    return remoteDataSource.updateCompanyLogo(companyId, filePath);
  }
}
