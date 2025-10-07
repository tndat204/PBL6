class RegisterResponse {
  final int code;
  final String message;
  final UserResponse? result;

  const RegisterResponse({
    required this.code,
    required this.message,
    this.result,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      result: json['result'] != null ? UserResponse.fromJson(json['result']) : null,
    );
  }
}

class UserResponse {
  final String id;
  final String username;
  final String email; // Bỏ password để không expose
  final String phone;
  final String address;
  final String fullName;
  final String avatarUrl;
  final List<Role> roles;
  final bool isEnabled;

  const UserResponse({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    required this.address,
    required this.fullName,
    required this.avatarUrl,
    required this.roles,
    required this.isEnabled,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      fullName: json['fullName'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      roles: (json['roles'] as List<dynamic>?)?.map((role) => Role.fromJson(role)).toList() ?? [],
      isEnabled: json['isEnabled'] ?? false,
    );
  }
}

class Role {
  final String name;
  final List<Permission> permissions;

  const Role({
    required this.name,
    required this.permissions,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      name: json['name'] ?? '',
      permissions: (json['permissions'] as List<dynamic>?)?.map((perm) => Permission.fromJson(perm)).toList() ?? [],
    );
  }
}

class Permission {
  final String name;

  const Permission({required this.name});

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(name: json['name'] ?? '');
  }
}