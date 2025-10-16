
import '../entities/skill.dart';
import '../repositories/skill_repository.dart';

class UpdateSkillUseCase {
  final SkillRepository repository;
  UpdateSkillUseCase(this.repository);

  Future<Skill> call(String id, Map<String, dynamic> data) async =>
      await repository.updateSkill(id, data);
}
