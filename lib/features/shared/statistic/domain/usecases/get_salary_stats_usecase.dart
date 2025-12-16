import '../entities/statistic.dart';
import '../repositories/statistic_repository.dart';

class GetSalaryStatsUseCase {
  final StatisticRepository _repository;

  GetSalaryStatsUseCase(this._repository);

  Future<List<SalaryStat>> call() async {
    return await _repository.getSalaryStats();
  }
}
