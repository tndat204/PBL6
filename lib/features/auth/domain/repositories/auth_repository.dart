import 'package:pbl6/features/auth/data/models/api_response_model.dart';

abstract class AuthRepository {
  Future<List<Map<String, dynamic>>> fetchProvinces();
  Future<List<Map<String, dynamic>>> fetchWards(int provinceCode);
  Future<Map<String, dynamic>> login(String email, String password);
  Future<APIResponse<String>> sendOTP(String email);
  Future<APIResponse<String>> verifyOTP(String email, String otp);
  Future<APIResponse<String>> resetPassword(String newPassword, String token);
}