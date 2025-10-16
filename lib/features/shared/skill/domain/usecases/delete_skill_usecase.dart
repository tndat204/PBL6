
import '../repositories/skill_repository.dart';

class DeleteSkillUseCase {
  final SkillRepository repository;
  DeleteSkillUseCase(this.repository);

  Future<void> call(String id) async => await repository.deleteSkill(id);
}