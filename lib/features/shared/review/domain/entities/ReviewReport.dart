class ReviewReport {
  final String id;
  final String reviewId;
  final String reporterId;
  final String reason;
  final String description;
  final String status;
  final DateTime createdAt;

  ReviewReport({
    required this.id,
    required this.reviewId,
    required this.reporterId,
    required this.reason,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  factory ReviewReport.fromJson(Map<String, dynamic> json) {
    return ReviewReport(
      id: json['id'] as String? ?? '',

      reviewId: json['reviewId'] as String? ?? '',

      reporterId: json['reporterId'] as String? ?? '',

      reason: json['reason'] as String? ?? 'OTHER',

      description: json['description'] as String? ?? '',

      status: json['status'] as String? ?? 'PENDING',

      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
