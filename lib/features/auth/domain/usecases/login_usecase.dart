import 'package:pbl6/features/auth/data/models/login_response_model.dart';
import 'package:pbl6/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<LoginResponse> call({required String email, required String password}) async {
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      throw Exception('Email không hợp lệ');
    }
    if (password.length < 6) {
      throw Exception('Mật khẩu phải có ít nhất 6 ký tự');
    }
    final response = await _repository.login(email, password);
    if (response is Map<String, dynamic>) {
      return LoginResponse.fromJson(response);
    } else {
      throw Exception('Response không hợp lệ');
    }
  }
}