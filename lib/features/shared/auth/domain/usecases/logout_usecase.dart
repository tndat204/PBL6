import 'package:pbl6/features/shared/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);
 
  Future<void> call() async {
    String? token;
    try {
     
      token = await _repository.getAuthToken();

      if (token != null && token.isNotEmpty) {
       
        await _repository.logoutApi(token);
      }
    } catch (e) {
    
      print('Lỗi khi gọi API logout, nhưng vẫn tiếp tục xóa local: $e');
    } finally {
    
      await _repository.clearLocalAuthData();
    }
  }
}