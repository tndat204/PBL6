import 'dart:io';

import '../repositories/user_repository.dart';

class UploadAvatarUseCase {
  final UserRepository repository;

  UploadAvatarUseCase(this.repository);

  Future<String> call(String filePath) async {
    final file = File(filePath); // ✅ Tạo File từ đường dẫn
    final String? response = await repository.uploadAvatar(file);
    if (response != null && response.isNotEmpty) {
      return response;
    } else {
      throw Exception('Upload avatar failed');
    }
  }
}
