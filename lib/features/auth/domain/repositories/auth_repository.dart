

abstract class AuthRepository {
  Future<List<Map<String, dynamic>>> fetchProvinces();
  Future<List<Map<String, dynamic>>> fetchWards(int provinceCode);
  Future<Map<String, dynamic>> login(String email, String password);
}