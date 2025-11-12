enum ApplicationStatus {
  SUBMITTED, // Mới nộp
  REVIEWED,  // Đã xem xét
  INTERVIEW, // Đã hẹn phỏng vấn
  HIRED,     // Đã tuyển
  REJECTED,  // Đã từ chối
  UNKNOWN    // Trạng thái không xác định (phòng trường hợp lỗi)
}
extension ApplicationStatusExtension on ApplicationStatus {
  String toShortString() {
    // Trả về chuỗi viết hoa khớp với yêu cầu API (SUBMITTED, REVIEWED,...)
    return toString().split('.').last;
  }
}
class Application {
  final String id;
  final String jobId; // FK to Job
  final String applicantId; // FK to User
  final ApplicationStatus status;
  final String notes;
  final String cvFileUrl;
  final DateTime appliedDate;

  const Application({
    required this.id,
    required this.jobId,
    required this.applicantId,
    required this.status,
    required this.notes,
    required this.cvFileUrl,
    required this.appliedDate,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['applicationId'] ?? '',
      jobId: json['jobId'] ?? '',
      applicantId: json['applicantId'] ?? '',
      status: _parseStatus(json['status']),
      notes: json['notes'] ?? '',
      cvFileUrl: json['cvFileUrl'] ?? '',
      appliedDate: DateTime.tryParse(json['appliedDate'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static ApplicationStatus _parseStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'SUBMITTED':
        return ApplicationStatus.SUBMITTED;
      case 'REVIEWED':
        return ApplicationStatus.REVIEWED;
      case 'INTERVIEW':
        return ApplicationStatus.INTERVIEW;
      case 'HIRED':
        return ApplicationStatus.HIRED;
      case 'REJECTED':
        return ApplicationStatus.REJECTED;
      default:
        return ApplicationStatus.UNKNOWN;
    }
  }
}
