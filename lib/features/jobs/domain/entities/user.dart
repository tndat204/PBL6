// lib/features/jobs/domain/entities/user.dart (cập nhật để không expose password, map từ UserEntity hoặc RegisterResponse)
import 'package:pbl6/features/auth/data/models/register_response_model.dart';
import 'package:pbl6/features/auth/domain/entities/user_entity.dart'; // Import UserEntity từ auth
import 'package:uuid/uuid.dart'; // Nếu dùng UUID

enum UserRole { candidate, recruiter, manager } // Từ Role table

class User {
  final String id; // UUID
  final String name; // Từ fullName trong ERD/response
  final String email; // Tái sử dụng từ UserEntity
  final DateTime birthday; // Từ ERD (birthDate)
  final UserRole role; // FK to Role
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.birthday,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory để map từ UserEntity (auth) sau login/register (bỏ password)
  factory User.fromAuthEntity(UserEntity authEntity, {String name = '', DateTime? birthday}) {
    return User(
      id: const Uuid().v4(),
      name: name.isEmpty ? authEntity.fullName ?? 'Unknown' : name, // Sử dụng fullName nếu có
      email: authEntity.email,
      birthday: birthday ?? DateTime.now(),
      role: UserRole.candidate, // Mặc định cho Candidates; thay bằng response.roles nếu có
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Factory để map từ RegisterResponse (sau register, nếu cần)
  factory User.fromRegisterResponse(UserResponse response) {
    UserRole role;
    if (response.roles.isNotEmpty) {
      switch (response.roles.first.name.toLowerCase()) {
        case 'recruiter':
          role = UserRole.recruiter;
          break;
        case 'manager':
          role = UserRole.manager;
          break;
        default:
          role = UserRole.candidate;
      }
    } else {
      role = UserRole.candidate; // Mặc định
    }

    return User(
      id: response.id,
      name: response.fullName,
      email: response.email,
      birthday: DateTime.now(), // Lấy từ profile sau nếu cần
      role: role,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}