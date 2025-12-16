import '../entities/statistic.dart';

abstract class StatisticRepository {
  Future<List<SkillStat>> getTopSkills({int limit = 10});

  Future<List<SalaryStat>> getSalaryStats();

  Future<List<LocationStat>> getLocationStats();
}
