import 'package:pbl6/features/shared/application/domain/repositories/application_repository.dart';

import '../../domain/entities/application.dart';
import '../datasources/application_remote_datasource.dart';

class ApplicationRepositoryImpl implements ApplicationRepository{
  final ApplicationRemoteDataSource remoteDataSource;
  ApplicationRepositoryImpl(this.remoteDataSource);
  @override
  Future<Application> applyJob({required String jobId, String? notes}) async {
    return await remoteDataSource.applyJob(jobId: jobId, notes: notes);
  }
}