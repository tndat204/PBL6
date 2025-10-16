import 'package:dio/dio.dart';
import 'package:pbl6/core/constants/api_constants.dart';
import 'package:pbl6/features/shared/skill/domain/entities/skill.dart';

abstract class SkillRemoteDataSource {
  Future<List<Skill>> fetchAllSkills({String? categoryId});
  Future<Skill> fetchSkill(String id);
  Future<Skill> createSkill(Map<String, dynamic> body);
  Future<Skill> updateSkill(String id, Map<String, dynamic> body);
  Future<void> deleteSkill(String id);
}

class SkillRemoteDataSourceImpl implements SkillRemoteDataSource {
  final Dio _dio;

  SkillRemoteDataSourceImpl(this._dio) {
    _dio.options.baseUrl = ApiConstants.baseUrl;
  }

  @override
  Future<List<Skill>> fetchAllSkills({String? categoryId}) async {
    final response = await _dio.get(
      "${ApiConstants.profile}/skill/all",
      queryParameters: categoryId != null ? {'categoryId': categoryId} : null,
    );
    final List<dynamic> data = response.data['result'];
    return data.map((json) => Skill.fromJson(json)).toList();
  }

  @override
  Future<Skill> fetchSkill(String id) async {
    final response = await _dio.get("${ApiConstants.profile}/skill/$id");
    return Skill.fromJson(response.data['result']);
  }

  @override
  Future<Skill> createSkill(Map<String, dynamic> body) async {
    final response = await _dio.post("${ApiConstants.profile}/skill", data: body);
    return Skill.fromJson(response.data['result']);
  }

  @override
  Future<Skill> updateSkill(String id, Map<String, dynamic> body) async {
    final response = await _dio.put("${ApiConstants.profile}/skill/$id", data: body);
    return Skill.fromJson(response.data['result']);
  }

  @override
  Future<void> deleteSkill(String id) async {
    await _dio.delete("${ApiConstants.profile}/skill/$id");
  }
}
