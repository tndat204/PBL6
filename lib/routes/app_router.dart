import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl6/features/admin/admin_shell.dart';
import 'package:pbl6/features/recruiter/company/presentation/pages/my_company_page.dart';
import 'package:pbl6/features/recruiter/dashboard/presentation/pages/recruiter_dashboard.dart';
import 'package:pbl6/features/recruiter/job/presentation/pages/recruiter_job_detail_page.dart';
import 'package:pbl6/features/recruiter/job/presentation/pages/recruiter_job_page.dart';
// THÊM IMPORT MỚI
import 'package:pbl6/features/recruiter/job/presentation/pages/upsert_job_page.dart';
import 'package:pbl6/features/recruiter/recruiter_shell.dart';
import 'package:pbl6/features/recruiter/review/presentation/pages/recruiter_review_page.dart';
import 'package:pbl6/features/shared/auth/presentation/pages/forgot_password_email_page.dart';
import 'package:pbl6/features/shared/auth/presentation/pages/recruiter_signup_page.dart';
import 'package:pbl6/features/shared/auth/presentation/pages/reset_password_page.dart';
import 'package:pbl6/features/shared/auth/presentation/pages/signup_page.dart';
import 'package:pbl6/features/shared/auth/presentation/pages/unauthorized_page.dart';
import 'package:pbl6/features/shared/auth/presentation/pages/verify_otp_page.dart';
import 'package:pbl6/features/shared/auth/presentation/pages/welcome_page.dart';
import 'package:pbl6/features/user/application/presentation/pages/my_application_page.dart';
import 'package:pbl6/features/user/dashboard/presentation/pages/user_dashboard.dart';
import 'package:pbl6/features/user/jobs/presentation/pages/job_detail_page.dart';
import 'package:pbl6/features/user/profile/presentation/pages/my_profile_page.dart';
import 'package:pbl6/features/user/user_shell.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/admin/dashboard/presentation/pages/admin_dashboard.dart';
import '../features/shared/auth/presentation/pages/login_page.dart';
import '../features/shared/auth/presentation/pages/role_selection_screen.dart';
import '../features/shared/user/presentation/pages/my_info_page.dart';
import '../features/user/jobs/presentation/pages/job_page.dart'; // Thêm import này
import 'route_guard.dart';
import 'route_names.dart';

/// Hàm hiệu ứng trượt từ phải sang trái
CustomTransitionPage slideFromRightTransition(
  Widget child,
  GoRouterState state,
) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 400),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeInOut));
      return SlideTransition(
        position: animation.drive(tween),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
  );
}

/// Hiệu ứng fade + scale nhẹ (cho welcome, role)
CustomTransitionPage fadeScaleTransition(Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 500),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween(begin: 0.95, end: 1.0).animate(animation),
          child: child,
        ),
      );
    },
  );
}

/// Hiệu ứng fade đơn giản (cho dashboard)
CustomTransitionPage fadeTransition(Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 300),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

final GoRouter router = GoRouter(
  initialLocation: RouteNames.WELCOME,
  routes: [
    // 🟢 Welcome
    GoRoute(
      path: RouteNames.WELCOME,
      name: RouteNames.WELCOME,
      pageBuilder: (context, state) =>
          fadeScaleTransition(const WelcomePage(), state),
    ),

    // 🟢 Login
    GoRoute(
      path: RouteNames.LOGIN,
      name: RouteNames.LOGIN,
      pageBuilder: (context, state) =>
          slideFromRightTransition(LoginPage(), state),
    ),

    // 🟢 Signup (Ứng viên)
    GoRoute(
      path: RouteNames.SIGNUP,
      name: RouteNames.SIGNUP,
      pageBuilder: (context, state) =>
          slideFromRightTransition(const SignupPage(), state),
    ),

    // 🟢 Signup (Nhà tuyển dụng)
    GoRoute(
      path: RouteNames.RECRUITER_SIGNUP,
      name: RouteNames.RECRUITER_SIGNUP,
      pageBuilder: (context, state) =>
          slideFromRightTransition(const RecruiterSignupPage(), state),
    ),

    // 🟢 Role selection
    GoRoute(
      path: RouteNames.ROLE_SELECTION,
      name: RouteNames.ROLE_SELECTION,
      pageBuilder: (context, state) =>
          fadeScaleTransition(const RoleSelectionScreen(), state),
    ),

    // 🟢 Forgot password
    GoRoute(
      path: RouteNames.FORGOT_PASSWORD_EMAIL,
      name: RouteNames.FORGOT_PASSWORD_EMAIL,
      pageBuilder: (context, state) =>
          slideFromRightTransition(const ForgotPasswordEmailPage(), state),
    ),

    // 🟢 Verify OTP
    GoRoute(
      path: RouteNames.VERIFY_OTP,
      name: RouteNames.VERIFY_OTP,
      pageBuilder: (context, state) {
        final email = state.extra as String;
        return slideFromRightTransition(VerifyOTPPage(email: email), state);
      },
    ),

    // 🟢 Reset password
    GoRoute(
      path: RouteNames.RESET_PASSWORD,
      name: RouteNames.RESET_PASSWORD,
      pageBuilder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return slideFromRightTransition(
          ResetPasswordPage(email: data['email'], token: data['token']),
          state,
        );
      },
    ),

    // 🟢 Unauthorized
    GoRoute(
      path: RouteNames.UNAUTHORIZED,
      name: RouteNames.UNAUTHORIZED,
      pageBuilder: (context, state) =>
          fadeTransition(UnauthorizedPage(), state),
    ),

    GoRoute(
      path: '/dashboard',
      name: 'dashboard_redirect',
      redirect: (context, state) async {
        final prefs = await SharedPreferences.getInstance();
        final role = prefs.getString('user_role');

        switch (role) {
          case 'UserRole.user':
            return RouteNames.USER_DASHBOARD;
          case 'UserRole.recruiter':
            return RouteNames.RECRUITER_DASHBOARD;
          case 'UserRole.admin':
            return RouteNames.ADMIN_DASHBOARD;
          default:
            return RouteNames.LOGIN;
        }
      },
    ),
    // SỬA: Dùng pageBuilder
    GoRoute(
      path: '/user/jobs/:id',
      name: 'job_detail',
      pageBuilder: (context, state) {
        final jobId = state.pathParameters['id']!;

        // 💡 LOGIC LẤY EXTRA
        bool hideButton = false;
        if (state.extra != null && state.extra is Map) {
          hideButton = (state.extra as Map)['hideApplyButton'] ?? false;
        }

        return slideFromRightTransition(
          JobDetailPage(
            jobId: jobId,
            hideApplyButton: hideButton, // 💡 Truyền vào đây
          ),
          state,
        );
      },
    ),
    // SỬA: Dùng pageBuilder
    GoRoute(
      path: '/my-info',
      name: 'my_info',
      pageBuilder: (context, state) =>
          slideFromRightTransition(const MyInfoPage(), state),
    ),
    GoRoute(
      path: '/recruiter/jobs/detail/:id',
      name: 'recruiter_job_detail',
      pageBuilder: (context, state) {
        final jobId = state.pathParameters['id']!;
        return slideFromRightTransition(
          RecruiterJobDetailPage(jobId: jobId), // Trang detail riêng recruiter
          state,
        );
      },
    ),
    ShellRoute(
      builder: (context, state, child) => UserShell(child: child),
      routes: [
        GoRoute(
          path: '/user/dashboard',
          builder: (_, __) => const UserDashboard(),
        ),
        GoRoute(path: '/user/jobs', builder: (_, __) => const JobPage()),
        GoRoute(
          path: '/user/applications',
          builder: (_, __) => const MyApplicationPage(),
        ),
        GoRoute(
          path: '/user/profile',
          builder: (_, __) => const MyProfilePage(),
        ),
      ],
    ),

    ShellRoute(
      builder: (context, state, child) => RecruiterShell(child: child),
      routes: [
        GoRoute(
          path: '/recruiter/dashboard',
          builder: (_, __) => const RecruiterDashboardPage(),
        ),
        GoRoute(
          path: '/recruiter/jobs',
          builder: (_, __) => const RecruiterJobPage(),
        ),
        GoRoute(
          path: '/recruiter/reviews',
          builder: (_, __) => const RecruiterReviewPage() ,
        ),
        GoRoute(
          path: '/recruiter/profile',
          builder: (_, __) => const MyCompanyPage(),
        ),
      ],
    ),

    // ⭐️ THÊM ROUTE MỚI CHO UPSERT JOB (NẰM NGOÀI SHELL) ⭐️
    GoRoute(
      path: '/recruiter/jobs/upsert',
      name: 'recruiter_job_upsert',
      pageBuilder: (context, state) {
        // state.extra sẽ là jobId (String?)
        // null = Add Mode
        // non-null = Edit Mode
        final String? jobId = state.extra as String?;
        return slideFromRightTransition(UpsertJobPage(jobId: jobId), state);
      },
    ),

    ShellRoute(
      builder: (context, state, child) => AdminShell(child: child),
      routes: [
        GoRoute(
          path: '/admin/dashboard',
          builder: (_, __) => const AdminDashboard(),
        ),
        GoRoute(
          path: '/admin/home',
          builder: (_, __) => const PlaceholderScreen(title: 'Admin Home'),
        ),
        GoRoute(
          path: '/admin/users',
          builder: (_, __) => const PlaceholderScreen(title: 'Users'),
        ),
        GoRoute(
          path: '/admin/settings',
          builder: (_, __) => const PlaceholderScreen(title: 'Settings'),
        ),
      ],
    ),
  ],
  redirect: routeGuard,
  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text('Error: ${state.error}'))),
);

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(title, style: const TextStyle(fontSize: 22)));
  }
}
