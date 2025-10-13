import 'package:pbl6/features/shared/auth/data/models/user_api_response.dart';


abstract class UserRepository {
Future<UserApiResponse> getMyInfo();
}