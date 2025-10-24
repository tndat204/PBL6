// file: features/shared/profile/domain/entities/profile_entity.dart


import '../../data/models/profile_models.dart';

class SkillEntity {
  final String id;
  final String name;

  const SkillEntity({
    required this.id,
    required this.name,
  });
}

class UserSkillEntity {
  final SkillEntity skill;
  final int experienceYears;
  final String level;
  final bool isPrimary;

  const UserSkillEntity({
    required this.skill,
    required this.experienceYears,
    required this.level,
    required this.isPrimary,
  });
}

class ProfileEntity {
  final String profileId;
  final String userId;
  final String? headline;
  final String? summary;
  final String? cvFile;
  final String? linkedinUrl;
  final String? portfolioUrl;
  final int desiredSalary;
  final bool isActive;
  final List<UserSkillEntity> skills;

  const ProfileEntity({
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

  // Mapper: Từ Data Model (ProfileResponse) sang Domain Entity (ProfileEntity)
  factory ProfileEntity.fromResponse(ProfileResponse response) {
    return ProfileEntity(
      profileId: response.profileId,
      userId: response.userId,
      headline: response.headline,
      summary: response.summary,
      cvFile: response.cvFile,
      linkedinUrl: response.linkedinUrl,
      portfolioUrl: response.portfolioUrl,
      desiredSalary: response.desiredSalary,
      isActive: response.isActive,
      skills: response.skills
          .map((s) => UserSkillEntity(
                skill: SkillEntity(id: s.skill.id, name: s.skill.name),
                experienceYears: s.experienceYears,
                level: s.level,
                isPrimary: s.isPrimary,
              ))
          .toList(),
    );
  }
  ProfileRequestModel toRequestModel() {
    return ProfileRequestModel(
      headline: headline,
      summary: summary,
      cvFile: cvFile,
      linkedinUrl: linkedinUrl,
      portfolioUrl: portfolioUrl,
      desiredSalary: desiredSalary,
      skills: skills
          .map((s) => UserSkillRequest(
                skillId: s.skill.id, // Giả sử skill.id là skillId cần thiết
                experienceYears: s.experienceYears,
                level: s.level,
                isPrimary: s.isPrimary,
              ))
          .toList(),
    );
  }

}