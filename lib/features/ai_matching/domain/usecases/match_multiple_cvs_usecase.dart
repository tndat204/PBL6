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
      jdFilePath: params.jdFilePath,
      cvFilePaths: params.cvFilePaths,
      weights: weights,
    );
  }
}

class MatchMultipleCvsParams extends Equatable {
  final String jdFilePath;
  final List<String> cvFilePaths;
  final MatchWeights? weights;

  const MatchMultipleCvsParams({
    required this.jdFilePath,
    required this.cvFilePaths,
    this.weights,
  });

  @override
  List<Object?> get props => [jdFilePath, cvFilePaths, weights];
}
