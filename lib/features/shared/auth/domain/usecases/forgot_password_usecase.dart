// features/auth/domain/usecases/forgot_password_usecase.dart
import 'package:pbl6/features/shared/auth/data/models/api_response_model.dart';
import 'package:pbl6/features/shared/auth/domain/repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  final AuthRepository _repository;

  ForgotPasswordUseCase(this._repository);

  Future<APIResponse<String>> sendOTP(String email) async {
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      throw Exception('Email không hợp lệ');
    }
    return await _repository.sendOTP(email);
  }

  Future<APIResponse<String>> verifyOTP(String email, String otp) async {
    if (otp.isEmpty) throw Exception('OTP không hợp lệ');
    return await _repository.verifyOTP(email, otp);
  }

  Future<APIResponse<String>> resetPassword(String newPassword, String token) async {
    if (newPassword.length < 8) throw Exception('Mật khẩu phải có ít nhất 8 ký tự');
    return await _repository.resetPassword(newPassword, token);
  }
}