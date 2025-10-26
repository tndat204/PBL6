// file: features/user/jobs/domain/entities/job.dart

// Add necessary imports if missing (e.g., for foundation if needed)
// import 'package:flutter/foundation.dart';

enum JobStatus { ACTIVE, INACTIVE, CLOSED }

// ✅ Use names matching your _jobTypes list or API response if different
enum JobType { FULL_TIME, PART_TIME, CONTRACT, INTERNSHIP, FREELANCE }

class Job {
  final String id;
  final String companyId;
  final String? companyName;
  final String? logoUrl;
  final String title;
  final String description;
  final JobStatus status;
  // Keep as int as per your definition
  final int salaryMin;
  final int salaryMax;
  final JobType jobType;
  final List<String> categoryIds;
  final List<String> skillIds;
  final String location; // Original full location string
  // ✅ ADD locationProvince field
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
    required this.jobType,
    required this.categoryIds,
    required this.skillIds,
    required this.location,
    // ✅ ADD to constructor
    this.locationProvince,
    required this.expiryDate,
    required this.postedBy,
  });

  // Factory constructor mostly stays the same, just add locationProvince (often null initially)
  factory Job.fromJson(Map<String, dynamic> json) {
    // Helper to parse int safely
     int safeParseInt(dynamic value) {
        if (value is int) return value;
        if (value is double) return value.toInt();
        if (value is String) return int.tryParse(value) ?? 0;
        return 0;
     }
     // Helper to parse DateTime safely
     DateTime safeParseDateTime(dynamic value) {
        if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
        // Add handling for other potential date formats/types from API if necessary
        return DateTime.now();
     }


    return Job(
      id: json['id'] ?? '',
      companyId: json['companyId'] ?? '',
      companyName: json['companyName'], // Keep as is
      logoUrl: json['logoUrl'] ?? json['companyLogo'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: JobStatus.values.firstWhere(
        // Use .name for comparison with strings (available in Dart 2.15+)
        (e) => e.name == (json['status'] ?? 'ACTIVE'),
        orElse: () => JobStatus.ACTIVE,
      ),
      // Use safeParseInt helper
      salaryMin: safeParseInt(json['salaryMin']),
      salaryMax: safeParseInt(json['salaryMax']),
      jobType: JobType.values.firstWhere(
        (e) => e.name == (json['jobType']?.toUpperCase() ?? 'FULL_TIME'), // Match enum name (often uppercase)
        orElse: () => JobType.FULL_TIME,
      ),
      categoryIds: (json['categoryIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      skillIds: (json['skillIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      location: json['location'] ?? '',
      // ✅ Initialize locationProvince as null here, it will be populated later
      locationProvince: null,
      // Use safeParseDateTime helper
      expiryDate: safeParseDateTime(json['expiryDate']),
      postedBy: json['postedBy'] ?? '',
    );
  }

  // ✅ Update copyWith to include locationProvince
  Job copyWith({
    String? companyName,
    String? logoUrl,
    String? locationProvince, // Add parameter
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
      jobType: jobType,
      categoryIds: categoryIds,
      skillIds: skillIds,
      location: location,
      // ✅ Use provided value or existing value
      locationProvince: locationProvince ?? this.locationProvince,
      expiryDate: expiryDate,
      postedBy: postedBy,
    );
  }
}