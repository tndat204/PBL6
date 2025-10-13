// lib/features/shared/auth/domain/entities/user_role.dart
enum UserRole {
  user,
  recruiter,
  admin;

  // Map từ scope string (từ token)
  static UserRole fromScopeString(String scope) {
    switch (scope.toLowerCase()) {
      case 'role_recruiter':
        return UserRole.recruiter;
      case 'role_admin':
        return UserRole.admin;
      default:
        return UserRole.user; // Mặc định là user
    }
  }

  // toString() để lưu prefs (e.g., 'UserRole.recruiter')
  @override
  String toString() => 'UserRole.$name';
}