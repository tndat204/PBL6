import 'package:pbl6/features/shared/auth/data/models/api_response_model.dart';
import 'package:pbl6/features/shared/auth/data/models/login_response_model.dart';
import 'package:pbl6/features/shared/auth/data/models/register_request_model.dart';
abstract class AuthRepository {
  Future<List<Map<String, dynamic>>> fetchProvinces();
  Future<List<Map<String, dynamic>>> fetchWards(String provinceName);
  Future<LoginResponse> login(String email, String password);
  Future<APIResponse<String>> sendOTP(String email);
  Future<APIResponse<String>> verifyOTP(String email, String otp);
  Future<APIResponse<String>> resetPassword(String newPassword, String token);
  Future<LoginResponse> googleLogin(String idToken);
  Future register(RegisterRequest request);
}