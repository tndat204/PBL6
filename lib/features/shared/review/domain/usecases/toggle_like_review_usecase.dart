import 'package:pbl6/features/shared/review/domain/entities/review.dart';
import 'package:pbl6/features/shared/review/domain/repositories/review_repository.dart';

class ToggleLikeReviewUseCase {
  final ReviewRepository repository;

  ToggleLikeReviewUseCase(this.repository);

  Future<Review> call(String params) {
    return repository.toggleLikeReview(params);
  }
}
