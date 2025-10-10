import 'package:pbl6/features/shared/auth/data/models/register_response_model.dart';

enum UserRole { candidate, recruiter, manager }

class UserEntity {
  final String id;
  final String username;
  final String email;
  final String fullName;
  final String phone;
  final String address;
  final String avatarUrl;
  final List<RoleEntity> roles;
  final bool isEnabled;
  final DateTime? birthDate;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.address,
    required this.avatarUrl,
    required this.roles,
    required this.isEnabled,
    this.birthDate,
  });

  factory UserEntity.fromRegisterResponse(UserResponse response) {
    return UserEntity(
      id: response.id,
      username: response.username,
      email: response.email,
      fullName: response.fullName,
      phone: response.phone,
      address: response.address,
      avatarUrl: response.avatarUrl,
      roles: response.roles.map((role) => RoleEntity.fromRole(role)).toList(),
      isEnabled: response.isEnabled,
      birthDate: null, // Có thể lấy từ profile sau
    );
  }
}

class RoleEntity {
  final String name;
  final List<PermissionEntity> permissions;

  const RoleEntity({
    required this.name,
    required this.permissions,
  });

  factory RoleEntity.fromRole(Role role) {
    return RoleEntity(
      name: role.name,
      permissions: role.permissions.map((perm) => PermissionEntity(name: perm.name)).toList(),
    );
  }
}

class PermissionEntity {
  final String name;

  const PermissionEntity({required this.name});
}