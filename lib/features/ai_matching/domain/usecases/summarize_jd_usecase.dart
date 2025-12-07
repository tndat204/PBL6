import 'package:equatable/equatable.dart';
import 'package:pbl6/features/ai_matching/domain/entities/ai_matching_entities.dart';

import '../repositories/ai_match_repository.dart';

class SummarizeJdUseCase {
 final AiMatchRepository repository;


  SummarizeJdUseCase(this.repository);

  Future<JdSummaryResponse> call(SummarizeJdParams params) async {
    return await repository.summarizeJd(jdFilePath: params.jdFilePath);
  }
}

// Class chứa tham số đầu vào (Params)
class SummarizeJdParams extends Equatable {
  final String jdFilePath;

  const SummarizeJdParams({required this.jdFilePath});

  @override
  List<Object?> get props => [jdFilePath];
}