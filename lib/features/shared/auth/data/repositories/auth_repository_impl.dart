import 'package:jwt_decode/jwt_decode.dart';
import 'package:pbl6/features/shared/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pbl6/features/shared/auth/data/models/api_response_model.dart';
import 'package:pbl6/features/shared/auth/data/models/login_response_model.dart';
import 'package:pbl6/features/shared/auth/data/models/register_request_model.dart';
import 'package:pbl6/features/shared/auth/data/models/reset_password_request_model.dart';
import 'package:pbl6/features/shared/auth/data/models/send_otp_request_model.dart';
import 'package:pbl6/features/shared/auth/data/models/user_api_response.dart';
import 'package:pbl6/features/shared/auth/data/models/verify_otp_request_model.dart';
import 'package:pbl6/features/shared/auth/domain/entities/user_entity.dart';
import 'package:pbl6/features/shared/auth/domain/repositories/auth_repository.dart';
// THÊM IMPORT MỚI
import 'package:pbl6/features/shared/company/data/datasources/company_remote_datasource.dart';
import 'package:pbl6/features/shared/company/domain/entities/company.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  // THÊM DEPENDENCY MỚI
  final CompanyRemoteDataSource _companyRemoteDataSource;

  // SỬA CONSTRUCTOR: Cần inject CompanyRemoteDataSource
  AuthRepositoryImpl(
    this._remoteDataSource,
    this._companyRemoteDataSource, // <-- Bạn phải cập nhật GetIt
  );

  @override
  Future<List<Map<String, dynamic>>> fetchProvinces() {
    return _remoteDataSource.fetchProvinces();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchWards(String provinceName) {
    return _remoteDataSource.fetchWards(provinceName);
  }

  @override
  Future<LoginResponse> login(String email, String password) async {
    // 1. Gọi API
    final response = await _remoteDataSource.login(email, password);

    // 2. Nếu API thành công, LƯU VÀO LOCAL
    if (response.code == 200 && response.result?.token != null) {
      final token = response.result!.token;
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('auth_token', token);

      final decodedToken = Jwt.parseJwt(token);
      final userId = decodedToken['userId'] ?? const Uuid().v4().toString();
      final scope = decodedToken['scope'] ?? 'ROLE_USER';

      UserRole role;
      switch (scope) {
        case 'ROLE_RECRUITER':
          role = UserRole.recruiter;
          break;
        case 'ROLE_ADMIN':
          role = UserRole.admin;
          break;
        default:
          role = UserRole.user;
      }

      await prefs.setString('user_role', role.toString());
      await prefs.setString('user_id', userId);

      // --- LOGIC MỚI: LẤY COMPANY ID NẾU LÀ RECRUITER ---
      if (role == UserRole.recruiter) {
        try {
          // Token đã được lưu, Dio interceptor (nếu có) sẽ tự động
          // sử dụng token này cho lệnh gọi tiếp theo.
          final Company company = await _companyRemoteDataSource.fetchMyCompany();
          if (company.id.isNotEmpty) {
            await prefs.setString('company_id', company.id);
          
          }
        } catch (e) {
          // Lỗi này có thể xảy ra nếu Recruiter mới đăng ký
          // và CHƯA TẠO công ty.
          // Chúng ta không muốn dừng việc đăng nhập.
        
          // Xóa ID công ty cũ (nếu có) để đảm bảo tính nhất quán
          await prefs.remove('company_id');
        }
      }
      // --- KẾT THÚC LOGIC MỚI ---
    }

    // 3. Trả về response cho UseCase
    return response;
  }

  // Phương thức mới
  @override
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  @override
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  @override
  Future<UserRole> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final roleString = prefs.getString('user_role') ?? 'UserRole.user';
    // Chuyển String về enum
    return UserRole.values.firstWhere((e) => e.toString() == roleString,
        orElse: () => UserRole.user);
  }

  // --- SỬA clearLocalAuthData ---
  @override
  Future<void> clearLocalAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_role');
    await prefs.remove('user_id');
    await prefs.remove('company_id'); // <-- XÓA CẢ COMPANY ID
  }

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
    return _remoteDataSource
        .resetPassword(ResetPasswordRequest(newPassword: newPassword), token);
  }

  @override
  Future<LoginResponse> googleLogin(String idToken) async {
    // 1. Gọi API
    final response = await _remoteDataSource.googleLogin(idToken);

    // 2. Nếu API thành công, LƯU VÀO LOCAL
    if (response.code == 200 && response.result?.token != null) {
      final token = response.result!.token;
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('auth_token', token);

      final decodedToken = Jwt.parseJwt(token);
      final userId = decodedToken['userId'] ?? const Uuid().v4().toString();
      final scope = decodedToken['scope'] ?? 'ROLE_USER';

      UserRole role;
      switch (scope) {
        case 'ROLE_RECRUITER':
          role = UserRole.recruiter;
          break;
        case 'ROLE_ADMIN':
          role = UserRole.admin;
          break;
        default:
          role = UserRole.user;
      }

      await prefs.setString('user_role', role.toString());
      await prefs.setString('user_id', userId);

      // --- LOGIC MỚI: LẤY COMPANY ID NẾU LÀ RECRUITER ---
      if (role == UserRole.recruiter) {
        try {
          final Company company = await _companyRemoteDataSource.fetchMyCompany();
          if (company.id.isNotEmpty) {
            await prefs.setString('company_id', company.id);
            print('Recruiter (Google) logged in, saved companyId: ${company.id}');
          }
        } catch (e) {
          print(
              'Recruiter (Google) logged in, but failed to fetch/save companyId: $e');
          await prefs.remove('company_id');
        }
      }
      // --- KẾT THÚC LOGIC MỚI ---
    }

    // 3. Trả về response cho UseCase
    return response;
  }

  @override
  Future<UserApiResponse> register(RegisterRequest request) {
    return _remoteDataSource.register(request);
  }

  @override
  Future<APIResponse<String>> logoutApi(String token) {
    return _remoteDataSource.logout(token);
  }

  // --- TRIỂN KHAI PHƯƠNG THỨC MỚI ---
  @override
  Future<String?> getCompanyId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('company_id');
  }
}