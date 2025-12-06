import 'package:equatable/equatable.dart';
import 'package:pbl6/features/ai_matching/domain/entities/ai_matching_entities.dart';
import 'package:pbl6/features/ai_matching/domain/repositories/ai_match_repository.dart';

class MatchMultipleCvsUseCase {
  final AiMatchRepository repository;

  MatchMultipleCvsUseCase(this.repository);

  Future<AiMatchResponse> call(MatchMultipleCvsParams params) {
    final weights =
        params.weights ??
        const MatchWeights(
          technicalSkills: 0.3,
          softSkills: 0.3,
          experience: 0.25,
          education: 0.1,
          other: 0.05,
        );

    return repository.matchMultipleCvs(
      jdUrl: params.jdUrl,
      cvUrls: params.cvUrls,
      weights: weights,
    );
  }
}

class MatchMultipleCvsParams extends Equatable {
  final String jdUrl;
  final List<String> cvUrls;
  final MatchWeights? weights;

  const MatchMultipleCvsParams({
    required this.jdUrl,
    required this.cvUrls,
    this.weights,
  });

  @override
  List<Object?> get props => [jdUrl, cvUrls, weights];
}
