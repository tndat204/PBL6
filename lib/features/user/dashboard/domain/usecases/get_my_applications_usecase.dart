import 'package:pbl6/features/shared/application/domain/entities/application.dart';
import 'package:pbl6/features/shared/application/domain/repositories/application_repository.dart';

class GetMyApplicationsUsecase {
  GetMyApplicationsUsecase(this.repository);

  final ApplicationRepository repository;

  Future<List<Application>> call() async {
    return await repository.getMyApplications();
  }
}