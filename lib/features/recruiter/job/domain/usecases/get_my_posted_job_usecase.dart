import 'package:equatable/equatable.dart';
import 'package:pbl6/features/shared/job/domain/entities/job.dart';
import 'package:pbl6/features/shared/job/domain/repositories/job_repository.dart';

class GetMyPostedJobsUseCase
     {
  final JobRepository repository;

  GetMyPostedJobsUseCase(this.repository);

  Future<List<Job>> call(GetMyPostedJobsParams params) async {
    // Gọi hàm fetchAllJobs với các tham số của Recruiter
    return repository.fetchAllJobs(
      companyId: params.companyId,
      status: params.status,
      category: null,
      keyword: null,
    );
  }
}

class GetMyPostedJobsParams extends Equatable {
  final String companyId;
  final JobStatus? status;

  const GetMyPostedJobsParams({required this.companyId, this.status});

  @override
  List<Object?> get props => [companyId, status];
}