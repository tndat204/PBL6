// lib/routes/route_guard.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/shared/auth/domain/entities/user_role.dart';
import 'route_names.dart';

Future<String?> routeGuard(BuildContext context, GoRouterState state) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  final roleString = prefs.getString('user_role');
  final path = state.matchedLocation;

  // 🔓 Danh sách các route public
  const publicRoutes = [
    RouteNames.WELCOME,         
    RouteNames.ROLE_SELECTION,
    RouteNames.LOGIN,
    RouteNames.SIGNUP,
    RouteNames.RECRUITER_SIGNUP,
    RouteNames.FORGOT_PASSWORD_EMAIL,
    RouteNames.VERIFY_OTP,
    RouteNames.RESET_PASSWORD,
    '/',
  ];

  // Nếu route nằm trong danh sách public thì bỏ qua guard
  if (publicRoutes.contains(path)) {
    return null;
  }

  // Nếu chưa login => về trang đăng nhập
  if (token == null || token.isEmpty) {
    return RouteNames.LOGIN;
  }

  // Parse role
  UserRole? role;
  if (roleString != null) {
    switch (roleString) {
      case 'UserRole.user':
        role = UserRole.user;
        break;
      case 'UserRole.recruiter':
        role = UserRole.recruiter;
        break;
      case 'UserRole.admin':
        role = UserRole.admin;
        break;
    }
  }

  if (role == null) return RouteNames.UNAUTHORIZED;

  // Kiểm tra quyền theo path
  if (path.startsWith('/user') && role != UserRole.user) return RouteNames.UNAUTHORIZED;
  if (path.startsWith('/recruiter') && role != UserRole.recruiter) return RouteNames.UNAUTHORIZED;
  if (path.startsWith('/admin') && role != UserRole.admin) return RouteNames.UNAUTHORIZED;

  // Nếu đã login mà vào /login => chuyển hướng dashboard
  if (path == RouteNames.LOGIN) {
    switch (role) {
      case UserRole.user:
        return RouteNames.USER_DASHBOARD;
      case UserRole.recruiter:
        return RouteNames.RECRUITER_DASHBOARD;
      case UserRole.admin:
        return RouteNames.ADMIN_DASHBOARD;
    }
  }

  return null;
}
