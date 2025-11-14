import 'package:pbl6/features/shared/application/domain/repositories/application_repository.dart';

import '../../domain/entities/application.dart';
import '../datasources/application_remote_datasource.dart';

class ApplicationRepositoryImpl implements ApplicationRepository{
  final ApplicationRemoteDataSource remoteDataSource;
  ApplicationRepositoryImpl(this.remoteDataSource);
  @override
  Future<Application> applyJob({required String jobId, String? notes, String? filePath}) async {
    return await remoteDataSource.applyJob(jobId: jobId, notes: notes, filePath: filePath);
  }
  @override
  Future<List<Application>> getApplicationsForJob(String jobId) async {
    return await remoteDataSource.getApplicationsForJob(jobId);
  }
  @override
  Future<Application> getApplicationDetail(String applicationId) async {
    return await remoteDataSource.getApplicationDetail(applicationId);
  }
  @override
  Future<Application> updateApplicationStatus({
    required String applicationId,
    required ApplicationStatus newStatus,
  }) async {
    return await remoteDataSource.updateApplicationStatus(
      applicationId: applicationId,
      newStatus: newStatus,
    );
  }
  @override
  Future<List<Application>> getMyApplications() async {
    return await remoteDataSource.getMyApplications();
  }
}