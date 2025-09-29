import 'package:pbl6/features/auth/data/models/login_response_model.dart';
import 'package:pbl6/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<LoginResponse> call({
    required String email,
    required String password,
  }) async {
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      throw Exception('Email không hợp lệ');
    }
    if (password.length < 8) {
      throw Exception('Mật khẩu phải có ít nhất 8 ký tự');
    }

    // Gọi repository, trả về LoginResponse trực tiếp
    final response = await _repository.login(email, password);
    return response;
  }
  Future<LoginResponse> googleLogin(String idToken) async {
    if (idToken.isEmpty) {
      throw Exception('ID Token không hợp lệ');
    }
    return await _repository.googleLogin(idToken);
  }
}
