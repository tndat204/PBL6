
import 'package:pbl6/features/shared/skill/data/datasources/skill_remote_datasource.dart';
import 'package:pbl6/features/shared/skill/domain/entities/skill.dart';
import 'package:pbl6/features/shared/skill/domain/repositories/skill_repository.dart';

class SkillRepositoryImpl implements SkillRepository {
  final SkillRemoteDataSource remoteDataSource;

  SkillRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Skill>> getAllSkills({String? categoryId}) =>
      remoteDataSource.fetchAllSkills(categoryId: categoryId);

  @override
  Future<Skill> getSkillById(String id) =>
      remoteDataSource.fetchSkill(id);

  @override
  Future<Skill> createSkill(Map<String, dynamic> data) =>
      remoteDataSource.createSkill(data);

  @override
  Future<Skill> updateSkill(String id, Map<String, dynamic> data) =>
      remoteDataSource.updateSkill(id, data);

  @override
  Future<void> deleteSkill(String id) =>
      remoteDataSource.deleteSkill(id);
}
