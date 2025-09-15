
import 'package:pbl6/core/services/api_service.dart';

class AuthRemoteDataSource {
  final ApiService _apiService;

  AuthRemoteDataSource(this._apiService);

  Future<List<Map<String, dynamic>>> fetchProvinces() async {
    return await _apiService.getProvinces();
  }

  Future<List<Map<String, dynamic>>> fetchWards(int provinceCode) async {
    return await _apiService.getWards(provinceCode);
  }

  Future<void> signupEmployer({
    required String fullName,
    required String companyName,
    required String phone,
    required String province,
    required String ward,
    required String email,
    required String password,
  }) async {
    await _apiService.signupEmployer(
      fullName: fullName,
      companyName: companyName,
      phone: phone,
      province: province,
      ward: ward,
      email: email,
      password: password,
    );
  }
}
