
import 'package:pbl6/features/shared/user/domain/repositories/user_repository.dart';

class ChangeMyPasswordUsecase {
  final UserRepository repository;

  ChangeMyPasswordUsecase( this.repository);

  Future<void> call({required String oldPassword, required String newPassword}) async {
    return await repository.changePassword(oldPassword: oldPassword, newPassword: newPassword);
  }
}