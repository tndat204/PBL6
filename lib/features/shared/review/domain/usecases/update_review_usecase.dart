import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:pbl6/features/shared/review/domain/entities/review.dart';
import 'package:pbl6/features/shared/review/domain/repositories/review_repository.dart';

class UpdateReviewUseCase  {
  final ReviewRepository repository;

  UpdateReviewUseCase(this.repository);

  Future< Review> call(UpdateReviewParams params) {
    return repository.updateReview(
      reviewId: params.reviewId,
      title: params.title,
      comment: params.comment,
      rating: params.rating,
      newImages: params.newImages,
    );
  }
}

class UpdateReviewParams extends Equatable {
  final String reviewId;
  final String title;
  final String comment;
  final double rating;
  final List<File>? newImages;

  const UpdateReviewParams({
    required this.reviewId,
    required this.title,
    required this.comment,
    required this.rating,
    this.newImages,
  });

  @override
  List<Object?> get props => [reviewId, title, comment, rating, newImages];
}