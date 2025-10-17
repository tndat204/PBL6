import '../entities/skill.dart';

abstract class SkillRepository {
  Future<List<Skill>> getAllSkills({String? categoryId});
  Future<Skill?> getSkillById(String id);
  Future<Skill> createSkill(Map<String, dynamic> data);
  Future<Skill> updateSkill(String id, Map<String, dynamic> data);
  Future<void> deleteSkill(String id);
}
