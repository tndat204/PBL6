import 'package:equatable/equatable.dart';
import 'package:pbl6/features/shared/review/domain/entities/review_paginated_response.dart';
import 'package:pbl6/features/shared/review/domain/repositories/review_repository.dart';

class GetCompanyReviewsUseCase {
  final ReviewRepository repository;

  GetCompanyReviewsUseCase(this.repository);

  Future<ReviewPaginatedResponse> call(GetCompanyReviewsParams params) {
    return repository.getCompanyReviews(
      companyId: params.companyId,
      page: params.page,
      size: params.size,
    );
  }
}

class GetCompanyReviewsParams extends Equatable {
  final String companyId;
  final int page;
  final int size;

  const GetCompanyReviewsParams({
    required this.companyId,
    this.page = 0,
    this.size = 10,
  });

  @override
  List<Object?> get props => [companyId, page, size];
}
