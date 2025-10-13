import 'package:pbl6/features/shared/auth/data/models/user_api_response.dart'; // Import shared model

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

  // Factory chung cho register/my-info (map từ UserApiResponse.result)
  factory UserEntity.fromUserApiResponse(UserApiResponse response) {
    if (response.result == null) throw Exception('No user data in response');
    final userRes = response.result!;
    return UserEntity(
      id: userRes.id,
      username: userRes.username,
      email: userRes.email,
      fullName: userRes.fullName,
      phone: userRes.phone,
      address: userRes.address,
      avatarUrl: userRes.avatarUrl,
      roles: userRes.roles.map((role) => RoleEntity.fromRole(role)).toList(),
      isEnabled: userRes.isEnabled,
      birthDate: null, // Lấy từ profile nếu cần
    );
  }
  
}

// Giữ nguyên RoleEntity, PermissionEntity (map từ Role/Permission)
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