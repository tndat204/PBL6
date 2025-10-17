enum JobStatus { ACTIVE, INACTIVE, CLOSED }

enum JobType { FULL_TIME, PART_TIME, CONTRACT, INTERNSHIP }

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
  final List<String> categoryIds;
  final List<String> skillIds;
  final String location;
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
    required this.jobType,
    required this.categoryIds,
    required this.skillIds,
    required this.location,
    required this.expiryDate,
    required this.postedBy,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] ?? '',
      companyId: json['companyId'] ?? '',
      companyName: json['companyName'], // nếu API có trả sẵn
      logoUrl: json['logoUrl'] ?? json['companyLogo'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: JobStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'ACTIVE'),
        orElse: () => JobStatus.ACTIVE,
      ),
      salaryMin: (json['salaryMin'] is double)
          ? (json['salaryMin'] as double).toInt()
          : (json['salaryMin'] ?? 0),
      salaryMax: (json['salaryMax'] is double)
          ? (json['salaryMax'] as double).toInt()
          : (json['salaryMax'] ?? 0),
      jobType: JobType.values.firstWhere(
        (e) => e.name == (json['jobType'] ?? 'FULL_TIME'),
        orElse: () => JobType.FULL_TIME,
      ),
      categoryIds:
          (json['categoryIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      skillIds:
          (json['skillIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      location: json['location'] ?? '',
      expiryDate: DateTime.tryParse(json['expiryDate'] ?? '') ?? DateTime.now(),
      postedBy: json['postedBy'] ?? '',
    );
  }

  Job copyWith({String? companyName, String? logoUrl}) {
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
      jobType: jobType,
      categoryIds: categoryIds,
      skillIds: skillIds,
      location: location,
      expiryDate: expiryDate,
      postedBy: postedBy,
    );
  }
}
