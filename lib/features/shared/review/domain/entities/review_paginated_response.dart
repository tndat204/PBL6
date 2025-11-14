import 'package:equatable/equatable.dart';
import 'package:pbl6/features/shared/review/domain/entities/review.dart';

class ReviewPaginatedResponse extends Equatable {
  final List<Review> content;
  final int totalPages;
  final int totalElements;
  final int size;
  final int number; // Số trang hiện tại
  final bool first;
  final bool last;
  final bool empty;

  const ReviewPaginatedResponse({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.size,
    required this.number,
    required this.first,
    required this.last,
    required this.empty,
  });

  factory ReviewPaginatedResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> contentList = json['content'] ?? [];
    return ReviewPaginatedResponse(
      content: contentList.map((item) => Review.fromJson(item)).toList(),
      totalPages: json['totalPages'] ?? 0,
      totalElements: json['totalElements'] ?? 0,
      size: json['size'] ?? 0,
      number: json['number'] ?? 0,
      first: json['first'] ?? false,
      last: json['last'] ?? false,
      empty: json['empty'] ?? true,
    );
  }

  // Dùng khi API trả về lỗi hoặc không có dữ liệu
  factory ReviewPaginatedResponse.empty() {
    return const ReviewPaginatedResponse(
      content: [],
      totalPages: 0,
      totalElements: 0,
      size: 0,
      number: 0,
      first: true,
      last: true,
      empty: true,
    );
  }

  @override
  List<Object?> get props => [
    content,
    totalPages,
    totalElements,
    size,
    number,
    first,
    last,
    empty,
  ];
}
