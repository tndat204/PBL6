// lib/routes/route_names.dart
class RouteNames {
  // Shared
  static const String WELCOME = '/welcome';
  static const String LOGIN = '/login';
  static const String SIGNUP = '/signup';
  static const String RECRUITER_SIGNUP = '/recruiter-signup';
  static const String ROLE_SELECTION = '/role-selection';
  static const FORGOT_PASSWORD_EMAIL = '/forgot-password';
  static const VERIFY_OTP = '/verify-otp';
  static const RESET_PASSWORD = '/reset-password';
  static const String UNAUTHORIZED = '/unauthorized';

  // User routes (ứng viên)
  static const String USER_DASHBOARD = '/user/dashboard';
  static const String USER_JOBS = '/user/jobs';
  static const String USER_PROFILE = '/user/profile';
  static const String USER_APPLICATIONS = '/user/applications';

  // Recruiter routes
  static const String RECRUITER_DASHBOARD = '/recruiter/dashboard';
  static const String RECRUITER_JOBS = '/recruiter/jobs';
  static const String RECRUITER_PROFILES = '/recruiter/profiles';
  static const String RECRUITER_REPORTS = '/recruiter/reports';
  static const String RECRUITER_COMPANIES = '/recruiter/companies';

  // Admin routes
  static const String ADMIN_DASHBOARD = '/admin/dashboard';
  static const String ADMIN_USERS = '/admin/users';
  static const String ADMIN_SKILLS = '/admin/skills';
  static const String ADMIN_REPORTS = '/admin/reports';
  static const String ADMIN_JOBS = '/admin/jobs';
  static const String ADMIN_COMPANIES = '/admin/companies';
  static const String ADMIN_PROFILES = '/admin/profiles';
  static const String ADMIN_REVIEWS = '/admin/reviews';
}