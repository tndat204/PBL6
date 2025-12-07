import 'package:pbl6/features/ai_matching/domain/entities/ai_matching_entities.dart';

abstract class AiMatchRepository {
  /// So khớp nhiều CV với một JD (Sử dụng /match/multiple)
  Future< AiMatchResponse> matchMultipleCvs({
    required String jdUrl,
    required List<String> cvUrls,
    MatchWeights? weights,
  });

  /// So khớp một CV với một JD (Sử dụng /match)
  Future< CvMatchResult> matchSingleCv({
    required String jdFilePath,
    required String cvFilePath,
    MatchWeights? weights,
  });
   Future<JdSummaryResponse> summarizeJd({
    required String jdFilePath,
  });
}
