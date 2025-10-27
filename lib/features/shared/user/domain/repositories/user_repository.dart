import 'dart:io';

import 'package:pbl6/features/shared/auth/data/models/user_api_response.dart';


abstract class UserRepository {
Future<UserApiResponse> getMyInfo();
Future<UserApiResponse> updateMyInfo(Map<String, dynamic> updatedData);
Future<String> uploadAvatar(File imageFile);
Future<void> changePassword({required String oldPassword, required String newPassword});
}