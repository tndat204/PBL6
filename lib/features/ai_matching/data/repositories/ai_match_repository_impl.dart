import 'package:pbl6/features/ai_matching/data/datasources/ai_match_remote_datasource.dart';
import 'package:pbl6/features/ai_matching/domain/entities/ai_matching_entities.dart';
import 'package:pbl6/features/ai_matching/domain/repositories/ai_match_repository.dart';

class AiMatchRepositoryImpl implements AiMatchRepository {
  final AiMatchRemoteDataSource remoteDataSource;

  AiMatchRepositoryImpl(this.remoteDataSource);

  @override
  Future<AiMatchResponse> matchMultipleCvs({
    required String jdUrl,
    required List<String> cvUrls,
    MatchWeights? weights,
  }) {
    return remoteDataSource.matchMultipleCvs(
      jdUrl: jdUrl,
      cvUrls: cvUrls,
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
  @override
  Future<JdSummaryResponse> summarizeJd({
    required String jdFilePath,
  }) {
    return remoteDataSource.summarizeJd(
      jdFilePath: jdFilePath,
    );
  }
}
