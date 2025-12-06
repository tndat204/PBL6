import 'package:equatable/equatable.dart';

// --- CÁC ENTITY PHỤ (CV Data) ---

class TechnicalSkills extends Equatable {
  final List<String> programmingLanguages;
  final List<String> frameworks;
  final List<String> tools;
  final List<String> databases;
  final List<String> others;

  const TechnicalSkills({
    required this.programmingLanguages,
    required this.frameworks,
    required this.tools,
    required this.databases,
    required this.others,
  });

  factory TechnicalSkills.fromJson(Map<String, dynamic> json) {
    return TechnicalSkills(
      programmingLanguages: List<String>.from(json['ProgrammingLanguages'] ?? []),
      frameworks: List<String>.from(json['Frameworks'] ?? []),
      tools: List<String>.from(json['Tools'] ?? []),
      databases: List<String>.from(json['Databases'] ?? []),
      others: List<String>.from(json['Others'] ?? []),
    );
  }

  @override
  List<Object?> get props => [programmingLanguages, frameworks, tools, databases, others];
}

class ExperienceData extends Equatable {
  final int? years;
  final List<String> roles;
  final List<String> projects;
  final List<String> achievements;

  const ExperienceData({
    this.years,
    required this.roles,
    required this.projects,
    required this.achievements,
  });

  factory ExperienceData.fromJson(Map<String, dynamic> json) {
    return ExperienceData(
      years: (json['Years'] as num?)?.toInt(),
      roles: List<String>.from(json['Roles'] ?? []),
      projects: List<String>.from(json['Projects'] ?? []),
      achievements: List<String>.from(json['Achievements'] ?? []),
    );
  }

  @override
  List<Object?> get props => [years, roles, projects, achievements];
}

class EducationData extends Equatable {
  final String? degree;
  final String? major;
  final String? university;
  final double? gpa;

  const EducationData({
    this.degree,
    this.major,
    this.university,
    this.gpa,
  });

  factory EducationData.fromJson(Map<String, dynamic> json) {
    return EducationData(
      degree: json['Degree'],
      major: json['Major'],
      university: json['University'],
      gpa: (json['GPA'] as num?)?.toDouble(),
    );
  }

  @override
  List<Object?> get props => [degree, major, university, gpa];
}

class CvData extends Equatable {
  final TechnicalSkills technicalSkills;
  final List<String> softSkills; // Giả định là List<String>
  final ExperienceData experience;
  final EducationData education;
  final List<String> certifications;
  final List<String> languages;
  final List<String> otherInfo;

  const CvData({
    required this.technicalSkills,
    required this.softSkills,
    required this.experience,
    required this.education,
    required this.certifications,
    required this.languages,
    required this.otherInfo,
  });

  factory CvData.fromJson(Map<String, dynamic> json) {
    return CvData(
      technicalSkills: TechnicalSkills.fromJson(json['TechnicalSkills'] ?? {}),
      softSkills: List<String>.from(json['SoftSkills'] ?? []),
      experience: ExperienceData.fromJson(json['Experience'] ?? {}),
      education: EducationData.fromJson(json['Education'] ?? {}),
      certifications: List<String>.from(json['Certifications'] ?? []),
      languages: List<String>.from(json['Languages'] ?? []),
      otherInfo: List<String>.from(json['OtherInfo'] ?? []),
    );
  }

  @override
  List<Object?> get props => [technicalSkills, softSkills, experience, education, certifications, languages, otherInfo];
}

// --- ENTITY MATCHING CHÍNH ---

class MatchScore extends Equatable {
  final double technicalSkills;
  final double softSkills;
  final double experience;
  final double education;
  final double other;
  final double totalScore;

  const MatchScore({
    required this.technicalSkills,
    required this.softSkills,
    required this.experience,
    required this.education,
    required this.other,
    required this.totalScore,
  });

  factory MatchScore.fromJson(Map<String, dynamic> json) {
    return MatchScore(
      technicalSkills: (json['TechnicalSkills'] as num?)?.toDouble() ?? 0.0,
      softSkills: (json['SoftSkills'] as num?)?.toDouble() ?? 0.0,
      experience: (json['Experience'] as num?)?.toDouble() ?? 0.0,
      education: (json['Education'] as num?)?.toDouble() ?? 0.0,
      other: (json['Other'] as num?)?.toDouble() ?? 0.0,
      totalScore: (json['TotalScore'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [technicalSkills, softSkills, experience, education, other, totalScore];
}

class CvMatchResult extends Equatable {
  final String cvUrl; // ⚠️ Đã sửa từ cvFilename -> cvUrl
  final MatchScore matchScore;
  final CvData cvData;

  const CvMatchResult({
    required this.cvUrl,
    required this.matchScore,
    required this.cvData,
  });

  factory CvMatchResult.fromJson(Map<String, dynamic> json) {
    return CvMatchResult(
      // ⚠️ Map đúng key từ JSON response: "cv_url"
      cvUrl: json['cv_url'] ?? '', 
      matchScore: MatchScore.fromJson(json['match_score'] ?? {}),
      cvData: CvData.fromJson(json['cv_data'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [cvUrl, matchScore, cvData];
}
class AiMatchResponse extends Equatable {
  final String jdSource; 
  final String? excelDownloadUrl; 
  final List<CvMatchResult> results;

  const AiMatchResponse({
    required this.jdSource,
    this.excelDownloadUrl,
    required this.results,
  });

  factory AiMatchResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> resultsList = json['results'] ?? [];
    return AiMatchResponse(
      
      jdSource: json['jd_source'] ?? '',
      
      excelDownloadUrl: json['excel_download_url'],
      results: resultsList.map((item) => CvMatchResult.fromJson(item)).toList(),
    );
  }

  @override
  List<Object?> get props => [jdSource, excelDownloadUrl, results];
}

// --- CÁC ENTITY PARAMS KHÁC ---

class MatchWeights extends Equatable {
  final double technicalSkills;
  final double softSkills;
  final double experience;
  final double education;
  final double other;

  const MatchWeights({
    required this.technicalSkills,
    required this.softSkills,
    required this.experience,
    required this.education,
    required this.other,
  });

  Map<String, double> toJson() => {
        "TechnicalSkills": technicalSkills,
        "SoftSkills": softSkills,
        "Experience": experience,
        "Education": education,
        "Other": other,
      };

  @override
  List<Object?> get props =>
      [technicalSkills, softSkills, experience, education, other];
}
