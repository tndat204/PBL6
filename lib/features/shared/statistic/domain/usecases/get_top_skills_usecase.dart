import '../entities/statistic.dart';
import '../repositories/statistic_repository.dart';

class GetTopSkillsUseCase {
  final StatisticRepository _repository;

  GetTopSkillsUseCase(this._repository);

  Future<List<SkillStat>> call({int limit = 10}) async {
    return await _repository.getTopSkills(limit: limit);
  }
}
