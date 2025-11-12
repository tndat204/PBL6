import 'package:pbl6/features/shared/application/domain/entities/application.dart';
import 'package:pbl6/features/shared/application/domain/repositories/application_repository.dart';

class UpdateApplicationStatusUsecase {
  final ApplicationRepository repository;

  UpdateApplicationStatusUsecase( this.repository);

  Future<Application> call({
    required String applicationId,
    required ApplicationStatus newStatus,
  }) {
    return repository.updateApplicationStatus(
      applicationId: applicationId,
      newStatus: newStatus,
    );
  }
}