import '../entities/statistic.dart';
import '../repositories/statistic_repository.dart';

class GetLocationStatsUseCase {
  final StatisticRepository _repository;

  GetLocationStatsUseCase(this._repository);

  Future<List<LocationStat>> call() async {
    return await _repository.getLocationStats();
  }
}
