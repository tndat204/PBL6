// file: features/shared/profile/data/models/profile_models.dart

class ProfileApiResponse {
  final int code;
  final String message;
  // Dùng dynamic cho result vì uploadCV/getCV trả về String, còn getMyProfile trả về ProfileResponse
  final dynamic result; 

  const ProfileApiResponse({
    required this.code,
    required this.message,
    this.result,
  });

  factory ProfileApiResponse.fromJson(Map<String, dynamic> json) {
    // Tự động xử lý result là Map (cho profile) hoặc String (cho CV URL)
    final resultJson = json['result'];
    dynamic resultValue;

    if (resultJson is Map<String, dynamic>) {
      resultValue = ProfileResponse.fromJson(resultJson);
    } else if (resultJson is String) {
      resultValue = resultJson; // Giữ nguyên là String cho CV URL
    } else {
      resultValue = null;
    }

    return ProfileApiResponse(
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      result: resultValue,
    );
  }
}

class ProfileResponse {
  final String profileId;
  final String userId;
  final String? headline;
  final String? summary;
  final String? cvFile;
  final String? linkedinUrl;
  final String? portfolioUrl;
  final int desiredSalary;
  final bool isActive;
  final List<UserSkillResponse> skills;

  const ProfileResponse({
    required this.profileId,
    required this.userId,
    this.headline,
    this.summary,
    this.cvFile,
    this.linkedinUrl,
    this.portfolioUrl,
    required this.desiredSalary,
    required this.isActive,
    required this.skills,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    int salary = 0; // Giá trị mặc định
    final salaryValue = json['desiredSalary'];
    if (salaryValue is int) {
      salary = salaryValue;
    } else if (salaryValue is double) {
      salary = salaryValue.toInt(); // Chuyển double thành int
    } else if (salaryValue is String) {
      salary = int.tryParse(salaryValue) ?? 0; // Thử parse từ String
    }
    return ProfileResponse(
      profileId: json['profileId'] ?? '',
      userId: json['userId'] ?? '',
      headline: json['headline'],
      summary: json['summary'],
      cvFile: json['cvFile'],
      linkedinUrl: json['linkedinUrl'],
      portfolioUrl: json['portfolioUrl'],
     desiredSalary: salary,
      isActive: json['isActive'] ?? false,
      skills: (json['skills'] as List<dynamic>?)
              ?.map((s) => UserSkillResponse.fromJson(s))
              .toList() ??
          [],
    );
  }
}

class UserSkillResponse {
  final SkillResponse skill; // Dùng SkillResponse thay vì Skill bạn định nghĩa
  final int experienceYears;
  final String level;
  final bool isPrimary;

  const UserSkillResponse({
    required this.skill,
    required this.experienceYears,
    required this.level,
    required this.isPrimary,
  });

  factory UserSkillResponse.fromJson(Map<String, dynamic> json) {
    return UserSkillResponse(
      skill: SkillResponse.fromJson(json['skill'] ?? {}),
      experienceYears: json['experienceYears'] ?? 0,
      level: json['level'] ?? '',
      isPrimary: json['isPrimary'] ?? false,
    );
  }
}

// Lớp SkillResponse (để tránh xung đột với lớp Skill của bạn)
class SkillResponse { 
  final String id;
  final String name;

  const SkillResponse({
    required this.id,
    required this.name,
  });

  factory SkillResponse.fromJson(Map<String, dynamic> json) {
    return SkillResponse(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }
  
}
class UserSkillRequest {
  final String skillId;
  final int experienceYears;
  final String level;
  final bool isPrimary;

  const UserSkillRequest({
    required this.skillId,
    required this.experienceYears,
    required this.level,
    required this.isPrimary,
  });

  Map<String, dynamic> toJson() => {
    'skillId': skillId,
    'experienceYears': experienceYears,
    'level': level,
    'isPrimary': isPrimary,
  };
}

class ProfileRequestModel {
  final String? headline;
  final String? summary;
  final String? cvFile;
  final String? linkedinUrl;
  final String? portfolioUrl;
  final int desiredSalary;
  final List<UserSkillRequest> skills;

  const ProfileRequestModel({
    this.headline,
    this.summary,
    this.cvFile,
    this.linkedinUrl,
    this.portfolioUrl,
    required this.desiredSalary,
    required this.skills,
  });

  Map<String, dynamic> toJson() => {
    'headline': headline,
    'summary': summary,
    'cvFile': cvFile,
    'linkedinUrl': linkedinUrl,
    'portfolioUrl': portfolioUrl,
    'desiredSalary': desiredSalary,
    'skills': skills.map((s) => s.toJson()).toList(),
  };
}