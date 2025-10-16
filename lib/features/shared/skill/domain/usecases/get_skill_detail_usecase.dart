
import '../entities/skill.dart';
import '../repositories/skill_repository.dart';

class GetSkillDetailUseCase {
  final SkillRepository repository;
  GetSkillDetailUseCase(this.repository);

  Future<Skill> call(String id) async => await repository.getSkillById(id);
}