import '../entities/report_reason.dart';
import '../repositories/review_repository.dart';

class GetReportReasonsUseCase {
  final ReviewRepository repository;

  GetReportReasonsUseCase(this.repository);

  
  Future<List<ReportReason>> call() async {
    return await repository.getReportReasons();
  }
}