import 'package:pbl6/features/shared/review/domain/entities/ReviewReport.dart';
import 'package:pbl6/features/shared/review/domain/repositories/review_repository.dart';

class CreateReportParams {
  final String reviewId;
  final String reason;
  final String description;

  CreateReportParams({
    required this.reviewId,
    required this.reason,
    required this.description,
  });
}

class CreateReportUseCase {
  final ReviewRepository repository;

  CreateReportUseCase(this.repository);

  Future<ReviewReport> call(CreateReportParams params) {
    return repository.createReport(
      reviewId: params.reviewId,
      reason: params.reason,
      description: params.description,
    );
  }
}
