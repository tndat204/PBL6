import '../repositories/user_repository.dart';

class UpdateMyInfoUseCase {
  final UserRepository repository;

  UpdateMyInfoUseCase(this.repository);

  Future<void> call(Map<String, dynamic> data) async {
    final response = await repository.updateMyInfo(data);
    if (response.code != 200) {
      throw Exception(response.message ?? 'Update failed');
    }
  }
}
