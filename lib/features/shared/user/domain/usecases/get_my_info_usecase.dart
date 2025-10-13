import 'package:pbl6/features/shared/auth/domain/entities/user_entity.dart';

import '../repositories/user_repository.dart';

class GetMyInfoUseCase {
  final UserRepository repository;

  GetMyInfoUseCase(this.repository);

  Future<UserEntity> call() async {
    final response = await repository.getMyInfo(); // Giả sử trả UserApiResponse
    if (response.code == 200 && response.result != null) {
      return UserEntity.fromUserApiResponse(response); // Map từ UserResponse (result)
    } else {
      throw Exception(response.message ?? 'Get my info failed');
    }
  }
}