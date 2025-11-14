import 'dart:io';

import 'package:pbl6/features/shared/auth/data/models/api_response_model.dart';
import 'package:pbl6/features/shared/review/domain/entities/review.dart';
import 'package:pbl6/features/shared/review/domain/entities/review_paginated_response.dart';

abstract class ReviewRepository {
  Future<ReviewPaginatedResponse> getCompanyReviews({
    required String companyId,
    int page = 0,
    int size = 10,
  });

  Future<Review> getReviewDetail(String reviewId);

  Future<Review> createReview({
    required String companyId,
    required String title,
    required String comment,
    required double rating,
    List<File>? images,
  });

  Future<Review> updateReview({
    required String reviewId,
    required String title,
    required String comment,
    required double rating,
    List<File>? newImages,
  });

  Future<Review> toggleLikeReview(String reviewId);

  Future<APIResponse<String>> deleteReview(String reviewId);
}
