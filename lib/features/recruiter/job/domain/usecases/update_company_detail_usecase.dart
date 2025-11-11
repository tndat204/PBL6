import 'package:equatable/equatable.dart';
import 'package:pbl6/features/shared/company/domain/entities/company.dart';
import 'package:pbl6/features/shared/company/domain/repositories/company_repository.dart';

class UpdateCompanyDetailsUseCase
     {
  final CompanyRepository repository;

  UpdateCompanyDetailsUseCase(this.repository);

 
  Future<Company> call(UpdateCompanyDetailsParams params) async {
    return repository.updateCompanyDetails(params.id, params.company);
  }
}

class UpdateCompanyDetailsParams extends Equatable {
  final String id;
  final Company company;

  const UpdateCompanyDetailsParams({required this.id, required this.company});

  @override
  List<Object?> get props => [id, company];
}