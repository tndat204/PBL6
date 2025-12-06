class ApiConstants {
  // 👉 chỉ cần sửa dòng này khi đổi server (VD: khi build release, deploy AWS,...)

  static const String baseUrl = 'http://10.0.2.2:8080/';
  // static const String baseUrl ='http://192.168.1.195:8080/';
  // Auth
  static const String login = '/api/auth/token';
  static const String logout = '/api/auth/logout';
  static const String googleLogin = '/api/auth/google-app';
  static const String sendOTP = '/api/auth/otp/password/send';
  static const String verifyOTP = '/api/auth/otp/verify';
  static const String resetPassword = '/api/auth/password/reset';
  static const String register = '/api/internal/users';
  //user
  static const String getMyInfo = '/api/users/me';
  static const String updateMyInfo = '/api/users/me';
  static const String uploadAvatar = '/api/users/me/avatar';
  static const String changePassword = '/api/users/me/password';
  //job
  static const String jobs = '/api/jobs';
  //company
  static const String companies = '/api/companies';
  //profile
  static const String profiles= 'api/profiles';
  //skill
  static const String skills= '/api/skills';
  //category
  static const String categories= '/api/categories';
  //application
  static const String applications= '/api/applications';
  //review
  static const String reviews= '/api/reviews';
  //application
  static const String notifications= '/api/notifications';
}
