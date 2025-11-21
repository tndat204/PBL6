import 'package:pbl6/features/ai_matching/data/datasources/ai_match_remote_datasource.dart';
import 'package:pbl6/features/ai_matching/domain/entities/ai_matching_entities.dart';
import 'package:pbl6/features/ai_matching/domain/repositories/ai_match_repository.dart';

class AiMatchRepositoryImpl implements AiMatchRepository {
  final AiMatchRemoteDataSource remoteDataSource;

  AiMatchRepositoryImpl(this.remoteDataSource);

  @override
  Future<AiMatchResponse> matchMultipleCvs({
    required String jdFilePath,
    required List<String> cvFilePaths,
    MatchWeights? weights,
  }) {
    return remoteDataSource.matchMultipleCvs(
      jdFilePath: jdFilePath,
      cvFilePaths: cvFilePaths,
      weights: weights,
    );
  }

  @override
  Future<CvMatchResult> matchSingleCv({
    required String jdFilePath,
    required String cvFilePath,
    MatchWeights? weights,
  }) {
    return remoteDataSource.matchSingleCv(
      jdFilePath: jdFilePath,
      cvFilePath: cvFilePath,
      weights: weights,
    );
  }
}
