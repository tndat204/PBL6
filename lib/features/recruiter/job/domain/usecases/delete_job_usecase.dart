import 'package:pbl6/features/shared/auth/data/models/api_response_model.dart';
import 'package:pbl6/features/shared/job/domain/repositories/job_repository.dart';

class DeleteJobUseCase  {
  final JobRepository repository;

  DeleteJobUseCase(this.repository);

  /// [params] ở đây là `jobId`
  Future<APIResponse<String>> call(String params) async {
    return repository.deleteJob(params);
  }
}