class SkillStat {
  final String skillName;
  final int jobCount;

  SkillStat({required this.skillName, required this.jobCount});

  factory SkillStat.fromJson(Map<String, dynamic> json) {
    return SkillStat(
      skillName: json['skillName'] ?? '',
      jobCount: json['jobCount'] ?? 0,
    );
  }
}
class SalaryStat {
  final String experienceLevel;
  final double avgSalaryMin;
  final double avgSalaryMax;
  final int jobCount;

  SalaryStat({
    required this.experienceLevel,
    required this.avgSalaryMin,
    required this.avgSalaryMax,
    required this.jobCount,
  });

  factory SalaryStat.fromJson(Map<String, dynamic> json) {
    return SalaryStat(
      experienceLevel: json['experienceLevel'] ?? '',
      // Dùng toDouble() để an toàn nếu backend trả về int
      avgSalaryMin: (json['avgSalaryMin'] ?? 0).toDouble(),
      avgSalaryMax: (json['avgSalaryMax'] ?? 0).toDouble(),
      jobCount: json['jobCount'] ?? 0,
    );
  }
}

class LocationStat {
  final String location;
  final int jobCount;

  LocationStat({required this.location, required this.jobCount});

  factory LocationStat.fromJson(Map<String, dynamic> json) {
    return LocationStat(
      location: json['location'] ?? '',
      jobCount: json['jobCount'] ?? 0,
    );
  }
}