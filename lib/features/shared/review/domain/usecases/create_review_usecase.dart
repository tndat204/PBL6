import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:pbl6/features/shared/review/domain/entities/review.dart';
import 'package:pbl6/features/shared/review/domain/repositories/review_repository.dart';


class CreateReviewUseCase {
  final ReviewRepository repository;

  CreateReviewUseCase(this.repository);


  Future< Review> call(CreateReviewParams params) {
    return repository.createReview(
      companyId: params.companyId,
      title: params.title,
      comment: params.comment,
      rating: params.rating,
      images: params.images,
    );
  }
}

class CreateReviewParams extends Equatable {
  final String companyId;
  final String title;
  final String comment;
  final double rating;
  final List<File>? images;

  const CreateReviewParams({
    required this.companyId,
    required this.title,
    required this.comment,
    required this.rating,
    this.images,
  });

  @override
  List<Object?> get props => [companyId, title, comment, rating, images];
}