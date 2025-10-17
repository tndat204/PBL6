import 'package:dio/dio.dart';
import 'package:pbl6/core/constants/api_constants.dart';
import 'package:pbl6/features/shared/skill/domain/entities/skill.dart';

abstract class SkillRemoteDataSource {
  Future<List<Skill>> fetchAllSkills({String? categoryId});
  Future<Skill?> fetchSkill(String id); // 🌟 Đã sửa thành trả về Skill?
  Future<Skill> createSkill(Map<String, dynamic> body);
  Future<Skill> updateSkill(String id, Map<String, dynamic> body);
  Future<void> deleteSkill(String id);
}

class SkillRemoteDataSourceImpl implements SkillRemoteDataSource {
  final Dio _dio;

  SkillRemoteDataSourceImpl(this._dio) {
    // Đảm bảo Base URL được thiết lập
    _dio.options.baseUrl = ApiConstants.baseUrl; 
  }

  @override
  Future<List<Skill>> fetchAllSkills({String? categoryId}) async {
    final response = await _dio.get(
      "${ApiConstants.profile}/skill/all",
      queryParameters: categoryId != null ? {'categoryId': categoryId} : null,
    );

    final data = response.data;
    if (data == null || data['result'] == null) return [];

    final List<dynamic> list = data['result'];
    return list
        .map((json) => Skill.fromJson(Map<String, dynamic>.from(json as Map))) 
        .toList();
  }

  @override
  Future<Skill?> fetchSkill(String id) async { // 🌟 Logic trả về null
    try {
      // ⚠️ Đảm bảo API Constants tạo ra URL đúng: http://localhost:8080/api/profile/skill/$id
      final response = await _dio.get("${ApiConstants.profile}/skill/$id"); 
      final dynamic rawData = response.data?['result'];
      
      // ✅ FIX: Chuyển đổi an toàn và kiểm tra dữ liệu
      if (rawData is Map) {
        final Map<String, dynamic> skillData = Map<String, dynamic>.from(rawData);
        return Skill.fromJson(skillData);
      }
    } on DioException catch (e) {
      // Bắt lỗi HTTP (ví dụ: 404) do Dio ném ra.
      // In ra để debug và xử lý tương tự như API trả về null.
      print("Dio Error fetching Skill $id: $e"); 
    } catch (e) {
      // Bắt các lỗi khác
      print("Error fetching Skill $id: $e");
    }
    
    // Trả về null khi API không tìm thấy (result: null) hoặc gặp lỗi Dio
    return null; 
  }

  @override
  Future<Skill> createSkill(Map<String, dynamic> body) async {
    final response =
        await _dio.post("${ApiConstants.profile}/skill", data: body);
        
    final dynamic rawData = response.data?['result'] ?? {};
    final Map<String, dynamic> data = Map<String, dynamic>.from(rawData as Map);
    
    return Skill.fromJson(data);
  }

  @override
  Future<Skill> updateSkill(String id, Map<String, dynamic> body) async {
    final response =
        await _dio.put("${ApiConstants.profile}/skill/$id", data: body);
        
    final dynamic rawData = response.data?['result'] ?? {};
    final Map<String, dynamic> data = Map<String, dynamic>.from(rawData as Map);
    
    return Skill.fromJson(data);
  }

  @override
  Future<void> deleteSkill(String id) async {
    await _dio.delete("${ApiConstants.profile}/skill/$id");
  }
}