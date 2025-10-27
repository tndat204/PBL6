
 import '../entities/application.dart';

abstract class ApplicationRepository {
  Future<Application> applyJob({required String jobId, String? notes});
}