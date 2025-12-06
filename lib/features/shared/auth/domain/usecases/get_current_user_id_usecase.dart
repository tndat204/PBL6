import '../repositories/auth_repository.dart'; // Import AuthRepository của bạn

class GetCurrentUserIdUseCase {
  final AuthRepository repository;
  GetCurrentUserIdUseCase(this.repository);

  Future<String?> call() => repository.getUserId();
}