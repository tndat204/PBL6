class ApiConstants {
  // 👉 chỉ cần sửa dòng này khi đổi server (VD: khi build release, deploy AWS,...)

  static const String baseUrl = 'http://10.0.2.2:8080/';
  // static const String baseUrl ='http://192.168.1.195:8080/';
  // Auth
  static const String login = '/api/auth/login';
  static const String googleLogin = '/api/auth/google-app';
  static const String sendOTP = '/api/auth/otp/forgot-password';
  static const String verifyOTP = '/api/auth/otp/verify-otp';
  static const String resetPassword = '/api/auth/reset-password';
  static const String register = '/api/user/internal/register';
  //user
  static const String getMyInfo = '/api/user/my-info';
  static const String updateMyInfo = '/api/user/update-my-info';
  static const String uploadAvatar = '/api/user/upload-avatar';
  //job
  static const String jobs = '/api/job';
  //company
  static const String companies = '/api/job/company';
  //profike
  static const String profile= 'api/profile';
}
