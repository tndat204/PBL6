
import '../entities/skill.dart';
import '../repositories/skill_repository.dart';

class CreateSkillUseCase {
  final SkillRepository repository;
  CreateSkillUseCase(this.repository);

  Future<Skill> call(Map<String, dynamic> data) async =>
      await repository.createSkill(data);
}