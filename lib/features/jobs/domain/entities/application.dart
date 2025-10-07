enum ApplicationStatus { pending, accepted, rejected }

class Application {
  final String id;
  final String jobId; // FK to JobPost
  final String userId; // FK to User
  final ApplicationStatus status;

  const Application({
    required this.id,
    required this.jobId,
    required this.userId,
    required this.status,
  });
}