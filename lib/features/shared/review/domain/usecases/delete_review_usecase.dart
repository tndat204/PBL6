import 'package:pbl6/features/shared/auth/data/models/api_response_model.dart';
import 'package:pbl6/features/shared/review/domain/repositories/review_repository.dart';

class DeleteReviewUseCase  {
  final ReviewRepository repository;

  DeleteReviewUseCase(this.repository);


  Future< APIResponse<String>> call(String params) async {
    return await repository.deleteReview(params);
  }
}