import 'dart:io';

import 'package:pbl6/features/shared/auth/data/models/api_response_model.dart';
import 'package:pbl6/features/shared/review/data/datasources/review_remote_datasource.dart';
import 'package:pbl6/features/shared/review/domain/entities/review.dart';
import 'package:pbl6/features/shared/review/domain/entities/review_paginated_response.dart';
import 'package:pbl6/features/shared/review/domain/repositories/review_repository.dart';


class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remote;

  ReviewRepositoryImpl(this.remote);

  @override
  Future<ReviewPaginatedResponse> getCompanyReviews({
    required String companyId,
    int page = 0,
    int size = 10,
  }) {
    return remote.getCompanyReviews(companyId: companyId, page: page, size: size);
  }

  @override
  Future<Review> getReviewDetail(String reviewId) {
    return remote.getReviewDetail(reviewId);
  }

  @override
  Future<Review> createReview({
    required String companyId,
    required String title,
    required String comment,
    required double rating,
    List<File>? images,
  }) {
    return remote.createReview(
      companyId: companyId,
      title: title,
      comment: comment,
      rating: rating,
      images: images,
    );
  }

  @override
  Future<Review> updateReview({
    required String reviewId,
    required String title,
    required String comment,
    required double rating,
    List<File>? newImages,
  }) {
    return remote.updateReview(
      reviewId: reviewId,
      title: title,
      comment: comment,
      rating: rating,
      newImages: newImages,
    );
  }

  @override
  Future<Review> toggleLikeReview(String reviewId) {
    return remote.toggleLikeReview(reviewId);
  }

  @override
  Future<APIResponse<String>> deleteReview(String reviewId) {
    return remote.deleteReview(reviewId);
  }
}
