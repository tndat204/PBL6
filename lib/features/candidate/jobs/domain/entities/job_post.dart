
enum JobStatus { open, closed, paused } // Giả sử enum từ ERD

class JobPost {
  final String id; // UUID
  final String companyId; // FK to Company
  final String title;
  final String description;
  final JobStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const JobPost({
    required this.id,
    required this.companyId,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
}