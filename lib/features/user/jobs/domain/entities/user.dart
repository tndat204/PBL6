import 'package:pbl6/features/shared/auth/domain/entities/user_entity.dart'; // UserEntity từ auth
import 'package:uuid/uuid.dart';

/// Các vai trò có thể có
enum UserRole { user, recruiter, admin }

/// Entity User dùng trong module Jobs
class User {
  final String id;
  final String username;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final String avatarUrl;
  final UserRole role;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.avatarUrl,
    required this.role,
    required this.isEnabled,
    required this.createdAt,
    required this.updatedAt,
  });
  User copyWith({
    String? id,
    String? username,
    String? fullName,
    String? email,
    String? phone,
    String? address,
    String? avatarUrl,
    UserRole? role,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  /// Map từ `UserEntity` của Auth (API /my-info)
  factory User.fromAuthEntity(UserEntity entity) {
    // Lấy role đầu tiên nếu có
    UserRole mappedRole = UserRole.user;
    if (entity.roles.isNotEmpty) {
      final roleName = entity.roles.first.name.toLowerCase();
      if (roleName.contains('recruiter')) {
        mappedRole = UserRole.recruiter;
      } else if (roleName.contains('admin') || roleName.contains('manager')) {
        mappedRole = UserRole.admin;
      }
    }

    return User(
      id: entity.id.isNotEmpty ? entity.id : const Uuid().v4(),
      username: entity.username,
      fullName: entity.fullName ?? '',
      email: entity.email,
      phone: entity.phone ?? '',
      address: entity.address ?? '',
      avatarUrl: entity.avatarUrl ?? '',
      role: mappedRole,
      isEnabled: entity.isEnabled ?? true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Nếu muốn map trực tiếp từ JSON response
  factory User.fromJson(Map<String, dynamic> json) {
    final result = json['result'] ?? json;

    UserRole mappedRole = UserRole.user;
    if (result['roles'] != null && result['roles'] is List && result['roles'].isNotEmpty) {
      final roleName = result['roles'][0]['name'].toString().toLowerCase();
      if (roleName.contains('recruiter')) {
        mappedRole = UserRole.recruiter;
      } else if (roleName.contains('admin') || roleName.contains('manager')) {
        mappedRole = UserRole.admin;
      }
    }

    return User(
      id: result['id'] ?? const Uuid().v4(),
      username: result['username'] ?? '',
      fullName: result['fullName'] ?? '',
      email: result['email'] ?? '',
      phone: result['phone'] ?? '',
      address: result['address'] ?? '',
      avatarUrl: result['avatarUrl'] ?? '',
      role: mappedRole,
      isEnabled: result['isEnabled'] ?? true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'avatarUrl': avatarUrl,
      'role': role.name,
      'isEnabled': isEnabled,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
