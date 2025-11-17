import 'package:equatable/equatable.dart';
import 'package:pbl6/features/shared/job/domain/entities/job.dart';
import 'package:pbl6/features/shared/job/domain/repositories/job_repository.dart';

class CreateJobUseCase {
  final JobRepository repository;

  CreateJobUseCase(this.repository);

  // 💡 CẬP NHẬT: Nhận Job và filePath dưới dạng Params Object
  Future<Job> call(CreateJobParams params) async {
    return repository.createJob(
      params.job,
      jdFilePath: params.jdFilePath, // 💡 Truyền đường dẫn file cục bộ
    );
  }
}

// 💡 LỚP PARAMETERS MỚI
class CreateJobParams extends Equatable {
  final Job job;
  final String? jdFilePath; // Đường dẫn file JD cục bộ (có thể null)

  const CreateJobParams({
    required this.job,
    this.jdFilePath,
  });

  @override
  List<Object?> get props => [job, jdFilePath];
}