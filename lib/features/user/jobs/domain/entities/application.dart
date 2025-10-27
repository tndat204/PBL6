enum ApplicationStatus { pending, accepted, rejected }

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
    switch (status?.toLowerCase()) {
      case 'accepted':
        return ApplicationStatus.accepted;
      case 'rejected':
        return ApplicationStatus.rejected;
      default:
        return ApplicationStatus.pending;
    }
  }
}
