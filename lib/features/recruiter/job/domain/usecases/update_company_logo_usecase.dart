import 'package:equatable/equatable.dart';
import 'package:pbl6/features/shared/auth/data/models/api_response_model.dart';
import 'package:pbl6/features/shared/company/domain/repositories/company_repository.dart';

class UpdateCompanyLogoUseCase
    {
  final CompanyRepository repository;

  UpdateCompanyLogoUseCase(this.repository);

 
  Future<APIResponse<String>> call(UpdateCompanyLogoParams params) async {
    return repository.updateCompanyLogo(params.companyId, params.filePath);
  }
}

class UpdateCompanyLogoParams extends Equatable {
  final String companyId;
  final String filePath;

  const UpdateCompanyLogoParams(
      {required this.companyId, required this.filePath});

  @override
  List<Object?> get props => [companyId, filePath];
}