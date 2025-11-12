import 'package:pbl6/features/shared/application/domain/entities/application.dart';
import 'package:pbl6/features/shared/application/domain/repositories/application_repository.dart';

class GetApplicationDetailUsecase {
  final ApplicationRepository repository;

  GetApplicationDetailUsecase(this.repository);

  Future<Application> call(String applicationId) {
    return repository.getApplicationDetail(applicationId);
  }
}