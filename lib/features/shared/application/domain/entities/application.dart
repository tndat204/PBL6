import 'package:equatable/equatable.dart';

// 💡 Trạng thái hồ sơ (Giữ nguyên)
enum ApplicationStatus {
  SUBMITTED, // Mới nộp
  REVIEWED,  // Đã xem xét
  INTERVIEW, // Đã hẹn phỏng vấn
  HIRED,     // Đã tuyển
  REJECTED,  // Đã từ chối
  UNKNOWN    // Trạng thái không xác định (phòng trường hợp lỗi)
}

// 💡 Extension (Giữ nguyên)
extension ApplicationStatusExtension on ApplicationStatus {
  String toShortString() {
    return toString().split('.').last;
  }
}

// 💡 ----- LỚP MỚI ĐỂ CHỨA THÔNG TIN ỨNG VIÊN GỘP VÀO -----
class ApplicantInfo extends Equatable {
  final String fullName;
  final String avatarUrl;
  final String email;
  final String phone;
  final String address;

  const ApplicantInfo({
    required this.fullName,
    required this.avatarUrl,
    required this.email,
    required this.phone,
    required this.address,
  });

  // 💡 Factory để parse từ JSON
  factory ApplicantInfo.fromJson(Map<String, dynamic> json) {
    return ApplicantInfo(
      fullName: json['fullName'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
    );
  }

  // 💡 Factory dự phòng nếu applicantInfo bị null
  factory ApplicantInfo.empty() {
    return const ApplicantInfo(
      fullName: 'N/A',
      avatarUrl: '',
      email: 'N/A',
      phone: 'N/A',
      address: 'N/A',
    );
  }

  @override
  List<Object?> get props => [fullName, avatarUrl, email, phone, address];
}
// -----------------------------------------------------------


// 💡 ----- LỚP APPLICATION CHÍNH (ĐÃ CẬP NHẬT) -----
class Application extends Equatable {
  final String id;
  final String jobId; 
  final String applicantId; 
  final ApplicationStatus status;
  final String notes;
  final String cvFileUrl;
  final DateTime appliedDate;
  
  // 💡 THÊM TRƯỜNG MỚI (chứa thông tin gộp)
  final ApplicantInfo applicantInfo;

  const Application({
    required this.id,
    required this.jobId,
    required this.applicantId,
    required this.status,
    required this.notes,
    required this.cvFileUrl,
    required this.appliedDate,
    required this.applicantInfo, // 💡 Thêm vào constructor
  });

  @override
  List<Object?> get props => [
        id,
        jobId,
        applicantId,
        status,
        notes,
        cvFileUrl,
        appliedDate,
        applicantInfo // 💡 Thêm vào props
      ];

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['applicationId'] ?? '',
      jobId: json['jobId'] ?? '',
      applicantId: json['applicantId'] ?? '',
      status: _parseStatus(json['status']),
      notes: json['notes'] ?? '',
      cvFileUrl: json['cvFileUrl'] ?? '',
      appliedDate: DateTime.tryParse(json['appliedDate'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
          
      // 💡 CẬP NHẬT LOGIC PARSE:
      // Kiểm tra nếu 'applicantInfo' tồn tại và là một Map, thì parse nó
      // Nếu không, tạo một đối tượng ApplicantInfo rỗng để tránh lỗi
      applicantInfo: (json['applicantInfo'] != null && json['applicantInfo'] is Map)
          ? ApplicantInfo.fromJson(json['applicantInfo'])
          : ApplicantInfo.empty(),
    );
  }

  // 💡 Hàm parse status (Giữ nguyên)
  static ApplicationStatus _parseStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'SUBMITTED':
        return ApplicationStatus.SUBMITTED;
      case 'REVIEWED':
        return ApplicationStatus.REVIEWED;
      case 'INTERVIEW':
        return ApplicationStatus.INTERVIEW;
      case 'HIRED':
        return ApplicationStatus.HIRED;
      case 'REJECTED':
        return ApplicationStatus.REJECTED;
      default:
        return ApplicationStatus.UNKNOWN;
    }
  }
}