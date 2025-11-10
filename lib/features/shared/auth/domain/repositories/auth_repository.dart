import 'package:pbl6/features/shared/auth/data/models/api_response_model.dart';
import 'package:pbl6/features/shared/auth/data/models/login_response_model.dart';
import 'package:pbl6/features/shared/auth/data/models/register_request_model.dart';
import 'package:pbl6/features/shared/auth/data/models/user_api_response.dart';
import 'package:pbl6/features/shared/auth/domain/entities/user_entity.dart';
abstract class AuthRepository {
  Future<List<Map<String, dynamic>>> fetchProvinces();
  Future<List<Map<String, dynamic>>> fetchWards(String provinceName);
  Future<LoginResponse> login(String email, String password);
  Future<APIResponse<String>> sendOTP(String email);
  Future<APIResponse<String>> verifyOTP(String email, String otp);
  Future<APIResponse<String>> resetPassword(String newPassword, String token);
  Future<LoginResponse> googleLogin(String idToken);
  Future<UserApiResponse> register(RegisterRequest request);
  Future<APIResponse<String>> logoutApi(String token);
  /// Lấy token đã lưu
  Future<String?> getAuthToken();

  /// Lấy user ID đã lưu
  Future<String?> getUserId();
  
  /// Lấy vai trò đã lưu
  Future<UserRole> getUserRole();

  /// Xóa tất cả dữ liệu auth đã lưu
  Future<void> clearLocalAuthData();
}