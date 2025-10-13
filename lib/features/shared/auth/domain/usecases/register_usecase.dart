import '../../data/models/register_request_model.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<UserEntity> call(RegisterRequest request) async {
    final response = await repository.register(request); // Trả UserApiResponse
    if (response.code == 200 && response.result != null) { 
      return UserEntity.fromUserApiResponse(response); // Truyền full response (không .result!)
    } else {
      throw Exception(response.message ?? 'Register failed with code ${response.code}');
    }
  }
}