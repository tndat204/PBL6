import '../repositories/auth_repository.dart';

class GetAuthTokenUseCase {
  final AuthRepository repository;
  GetAuthTokenUseCase(this.repository);

  Future<String?> call() => repository.getAuthToken();
}