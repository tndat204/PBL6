import 'package:equatable/equatable.dart';
import 'package:pbl6/features/shared/job/domain/entities/job.dart';
import 'package:pbl6/features/shared/job/domain/repositories/job_repository.dart';

class UpdateJobUseCase {
  final JobRepository repository;

  UpdateJobUseCase(this.repository);

  Future<Job> call(UpdateJobParams params) async {
    return repository.updateJob(
      params.jobId,
      params.job,
      jdFilePath: params.jdFilePath,
    );
  }
}

class UpdateJobParams extends Equatable {
  final String jobId;
  final Job job;
  final String? jdFilePath;

  const UpdateJobParams({
    required this.jobId,
    required this.job,
    this.jdFilePath,
  });

  @override
  List<Object?> get props => [jobId, job, jdFilePath];
}
