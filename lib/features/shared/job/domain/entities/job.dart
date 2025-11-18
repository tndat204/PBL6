enum JobStatus { ACTIVE, INACTIVE, CLOSED }

enum JobType { FULL_TIME, PART_TIME, CONTRACT, REMOTE }

// THÊM: Enum mới cho trình độ kinh nghiệm
enum ExperienceLevel {
  INTERN, FRESHER, JUNIOR, SENIOR, PRINCIPAL, MANAGER,ANY
}

class Job {
  final String id;
  final String companyId;
  final String? companyName;
  final String? logoUrl;
  final String title;
  final String description;
  final JobStatus status;
  final int salaryMin;
  final int salaryMax;
  final JobType jobType;

  // THÊM: Các trường mới từ API
  final ExperienceLevel experienceLevel;
  final int requiredYearsOfExpMin;
  final int requiredYearsOfExpMax;
  final String jdFile; // 💡 TRƯỜNG FILE JD (URL sau khi tải lên)

  final List<String> categoryIds;
  final List<String> skillIds;
  final String location;
  final String? locationProvince;
  final DateTime expiryDate;
  final String postedBy;

  const Job({
    required this.id,
    required this.companyId,
    this.companyName,
    this.logoUrl,
    required this.title,
    required this.description,
    required this.status,
    required this.salaryMin,
    required this.salaryMax,
    required this.jdFile,
    required this.jobType,
    required this.experienceLevel,
    required this.requiredYearsOfExpMin,
    required this.requiredYearsOfExpMax,
    required this.categoryIds,
    required this.skillIds,
    required this.location,
    this.locationProvince,
    required this.expiryDate,
    required this.postedBy,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    int safeParseInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    DateTime safeParseDateTime(dynamic value) {
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    ExperienceLevel parseExperienceLevel(String? level) {
      switch (level?.toUpperCase()) {
        case 'INTERN':
          return ExperienceLevel.INTERN;
        case 'JUNIOR':
          return ExperienceLevel.JUNIOR;
        case 'FRESHER':
          return ExperienceLevel.FRESHER;
        case 'SENIOR':
          return ExperienceLevel.SENIOR;
        case 'PRINCIPAL':
          return ExperienceLevel.PRINCIPAL;
        case 'MANAGER':
          return ExperienceLevel.MANAGER;
        default:
          return ExperienceLevel.ANY;
      }
    }

    return Job(
      id: json['id'] ?? '',
      companyId: json['companyId'] ?? '',
      companyName: json['companyName'],
      logoUrl: json['logoUrl'] ?? json['companyLogo'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: JobStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'ACTIVE'),
        orElse: () => JobStatus.ACTIVE,
      ),
      salaryMin: safeParseInt(json['salaryMin']),
      salaryMax: safeParseInt(json['salaryMax']),
      jdFile: json['jdFile'] ?? json['jdUrl'] ?? '',
      jobType: JobType.values.firstWhere(
        (e) => e.name == (json['jobType']?.toUpperCase() ?? 'FULL_TIME'),
        orElse: () => JobType.FULL_TIME,
      ),
      experienceLevel: parseExperienceLevel(json['experienceLevel']),
      requiredYearsOfExpMin: safeParseInt(json['requiredYearsOfExpMin']),
      requiredYearsOfExpMax: safeParseInt(json['requiredYearsOfExpMax']),

      categoryIds: (json['categoryIds'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
          [],
      skillIds: (json['skillIds'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
          [],
      location: json['location'] ?? '',
      locationProvince: null,
      expiryDate: safeParseDateTime(json['expiryDate']),
      postedBy: json['postedBy'] ?? '',
    );
  }

  Job copyWith({
    String? companyName,
    String? logoUrl,
    String? locationProvince,
    ExperienceLevel? experienceLevel,
    int? requiredYearsOfExpMin,
    int? requiredYearsOfExpMax,
    String? jdFile, // 💡 THÊM jdFile vào copyWith
  }) {
    return Job(
      id: id,
      companyId: companyId,
      companyName: companyName ?? this.companyName,
      logoUrl: logoUrl ?? this.logoUrl,
      title: title,
      description: description,
      status: status,
      salaryMin: salaryMin,
      salaryMax: salaryMax,
      jdFile: jdFile ?? this.jdFile, // 💡 CẬP NHẬT jdFile
      jobType: jobType,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      requiredYearsOfExpMin:
          requiredYearsOfExpMin ?? this.requiredYearsOfExpMin,
      requiredYearsOfExpMax:
          requiredYearsOfExpMax ?? this.requiredYearsOfExpMax,
      categoryIds: categoryIds,
      skillIds: skillIds,
      location: location,
      locationProvince: locationProvince ?? this.locationProvince,
      expiryDate: expiryDate,
      postedBy: postedBy,
    );
  }
  
  Map<String, dynamic> toJsonForUpsert() {
    return {
      "companyId": companyId,
      "title": title,
      "description": description, 
      "status": status.name, 
      "salaryMin": salaryMin,
      "salaryMax": salaryMax,
    
      "jobType": jobType.name, 
      "experienceLevel": experienceLevel.name,
      "requiredYearsOfExpMin": requiredYearsOfExpMin,
      "requiredYearsOfExpMax": requiredYearsOfExpMax,
      "categoryIds": categoryIds, // Gửi List of String
      "skillIds": skillIds, // Gửi List of String
      "location": location,
      "expiryDate": expiryDate.toIso8601String(),
    };
  }
}