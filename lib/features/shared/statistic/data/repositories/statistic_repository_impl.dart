import 'package:dio/dio.dart';

import '../../domain/entities/statistic.dart';
import '../../domain/repositories/statistic_repository.dart';
import '../datasources/statistic_remote_datasource.dart';

class StatisticRepositoryImpl implements StatisticRepository {
  final StatisticRemoteDataSource _remoteDataSource;

  StatisticRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<SkillStat>> getTopSkills({int limit = 10}) async {
    try {
      return await _remoteDataSource.getTopSkills(limit: limit);
    } on DioException {
     
      rethrow;
    } catch (e) {
      throw Exception('Repository Error: $e');
    }
  }

  @override
  Future<List<SalaryStat>> getSalaryStats() async {
    try {
      return await _remoteDataSource.getSalaryStats();
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Repository Error: $e');
    }
  }

  @override
  Future<List<LocationStat>> getLocationStats() async {
    try {
      return await _remoteDataSource.getLocationStats();
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Repository Error: $e');
    }
  }
}