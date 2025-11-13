
 import '../entities/application.dart';

abstract class ApplicationRepository {
  Future<Application> applyJob({required String jobId, String? notes});
  Future<List<Application>> getApplicationsForJob(String jobId);
  Future<Application> getApplicationDetail(String applicationId);
  Future<Application> updateApplicationStatus({
    required String applicationId,
    required ApplicationStatus newStatus,
  });
  Future<List<Application>> getMyApplications();
}