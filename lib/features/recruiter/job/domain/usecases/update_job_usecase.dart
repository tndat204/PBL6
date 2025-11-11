import 'package:equatable/equatable.dart';
import 'package:pbl6/features/shared/job/domain/entities/job.dart';
import 'package:pbl6/features/shared/job/domain/repositories/job_repository.dart';

class UpdateJobUseCase {
  final JobRepository repository;

  UpdateJobUseCase(this.repository);

  
  Future<Job> call(UpdateJobParams params) async {
    return repository.updateJob(params.jobId, params.job);
  }
}

class UpdateJobParams extends Equatable {
  final String jobId;
  final Job job; // Đối tượng Job với thông tin đã cập nhật

  const UpdateJobParams({required this.jobId, required this.job});

  @override
  List<Object?> get props => [jobId, job];
}