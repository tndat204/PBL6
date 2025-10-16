
import '../entities/skill.dart';
import '../repositories/skill_repository.dart';

class GetAllSkillsUseCase {
  final SkillRepository repository;
  GetAllSkillsUseCase(this.repository);

  Future<List<Skill>> call({String? categoryId}) async =>
      await repository.getAllSkills(categoryId: categoryId);
}