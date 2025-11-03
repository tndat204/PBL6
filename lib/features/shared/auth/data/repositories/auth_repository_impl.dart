import 'package:pbl6/features/shared/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pbl6/features/shared/auth/data/models/api_response_model.dart';
import 'package:pbl6/features/shared/auth/data/models/login_response_model.dart';
import 'package:pbl6/features/shared/auth/data/models/register_request_model.dart';
import 'package:pbl6/features/shared/auth/data/models/reset_password_request_model.dart';
import 'package:pbl6/features/shared/auth/data/models/send_otp_request_model.dart';
import 'package:pbl6/features/shared/auth/data/models/verify_otp_request_model.dart';
import 'package:pbl6/features/shared/auth/domain/repositories/auth_repository.dart';
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Map<String, dynamic>>> fetchProvinces() {
    return _remoteDataSource.fetchProvinces();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchWards(String provinceName) {
    return _remoteDataSource.fetchWards(provinceName);
  }

  @override
  Future<LoginResponse> login(String email, String password) {
    return _remoteDataSource.login(email, password);
  }
  // Phương thức mới
  @override
  Future<APIResponse<String>> sendOTP(String email) {
    return _remoteDataSource.sendOTP(SendOTPRequest(email: email));
  }

  @override
  Future<APIResponse<String>> verifyOTP(String email, String otp) {
    return _remoteDataSource.verifyOTP(VerifyOTPRequest(email: email, otp: otp));
  }

  @override
  Future<APIResponse<String>> resetPassword(String newPassword, String token) {
    return _remoteDataSource.resetPassword(ResetPasswordRequest(newPassword: newPassword), token);
  }
  @override
  Future<LoginResponse> googleLogin(String idToken) {
    return _remoteDataSource.googleLogin(idToken);
  }
  @override
  Future register(RegisterRequest request) {
    return _remoteDataSource.register(request);
  }
}