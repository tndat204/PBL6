import 'package:equatable/equatable.dart';

/// 1. Thông tin người đánh giá
class ReviewerInfo extends Equatable {
  final String reviewerId;
  final String reviewerName;
  final String reviewerAvatar;

  const ReviewerInfo({
    required this.reviewerId,
    required this.reviewerName,
    required this.reviewerAvatar,
  });

  factory ReviewerInfo.fromJson(Map<String, dynamic> json) {
    return ReviewerInfo(
      reviewerId: json['reviewerId'] ?? '',
      reviewerName: json['reviewerName'] ?? '',
      reviewerAvatar: json['reviewerAvatar'] ?? '',
    );
  }

  factory ReviewerInfo.empty() {
    return const ReviewerInfo(
      reviewerId: '',
      reviewerName: 'N/A',
      reviewerAvatar: '',
    );
  }

  @override
  List<Object?> get props => [reviewerId, reviewerName, reviewerAvatar];
}

/// 2. Đối tượng Review
class Review extends Equatable {
  final String reviewId;
  final String companyId;
  final String title;
  final String comment;
  final double rating;
  final int likeCount;
  final String status;
  final List<String> imageUrls;
  final ReviewerInfo reviewerInfo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool liked;

  const Review({
    required this.reviewId,
    required this.companyId,
    required this.title,
    required this.comment,
    required this.rating,
    required this.likeCount,
    required this.status,
    required this.imageUrls,
    required this.reviewerInfo,
    required this.createdAt,
    required this.updatedAt,
    required this.liked,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewId: json['reviewId'] ?? '',
      companyId: json['companyId'] ?? '',
      title: json['title'] ?? '',
      comment: json['comment'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      status: json['status'] ?? '',
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      reviewerInfo: (json['reviewerInfo'] != null)
          ? ReviewerInfo.fromJson(json['reviewerInfo'])
          : ReviewerInfo.empty(),
      createdAt:
          DateTime.tryParse(json['createdAt'] ?? '')?.toLocal() ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] ?? '')?.toLocal() ??
          DateTime.now(),

      liked: json['liked'] ?? false,
    );
  }

  @override
  List<Object?> get props => [
    reviewId,
    companyId,
    title,
    comment,
    rating,
    likeCount,
    status,
    imageUrls,
    reviewerInfo,
    createdAt,
    updatedAt,
    liked,
  ];
}

/// ------------------ Extensions copyWith ------------------

extension ReviewerInfoCopy on ReviewerInfo {
  ReviewerInfo copyWith({
    String? reviewerId,
    String? reviewerName,
    String? reviewerAvatar,
  }) {
    return ReviewerInfo(
      reviewerId: reviewerId ?? this.reviewerId,
      reviewerName: reviewerName ?? this.reviewerName,
      reviewerAvatar: reviewerAvatar ?? this.reviewerAvatar,
    );
  }
}

extension ReviewCopy on Review {
  Review copyWith({ReviewerInfo? reviewerInfo}) {
    return Review(
      reviewId: reviewId,
      companyId: companyId,
      title: title,
      comment: comment,
      rating: rating,
      likeCount: likeCount,
      status: status,
      imageUrls: imageUrls,
      reviewerInfo: reviewerInfo ?? this.reviewerInfo,
      createdAt: createdAt,
      updatedAt: updatedAt,
      liked: liked,
    );
  }
}
