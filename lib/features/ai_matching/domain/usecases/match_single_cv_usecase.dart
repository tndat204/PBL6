import 'package:equatable/equatable.dart';
import 'package:pbl6/features/ai_matching/domain/entities/ai_matching_entities.dart';
import 'package:pbl6/features/ai_matching/domain/repositories/ai_match_repository.dart';

class MatchSingleCvUseCase {
  final AiMatchRepository repository;

  MatchSingleCvUseCase(this.repository);

  Future<CvMatchResult> call(MatchSingleCvParams params) {
    final weights =
        params.weights ??
        const MatchWeights(
          technicalSkills: 0.3,
          softSkills: 0.3,
          experience: 0.25,
          education: 0.1,
          other: 0.05,
        );

    return repository.matchSingleCv(
      jdFilePath: params.jdFilePath,
      cvFilePath: params.cvFilePath,
      weights: weights,
    );
  }
}

class MatchSingleCvParams extends Equatable {
  final String jdFilePath;
  final String cvFilePath;
  final MatchWeights? weights;

  const MatchSingleCvParams({
    required this.jdFilePath,
    required this.cvFilePath,
    this.weights,
  });

  @override
  List<Object?> get props => [jdFilePath, cvFilePath, weights];
}
