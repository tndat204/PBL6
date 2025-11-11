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
}
