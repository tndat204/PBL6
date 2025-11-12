// features/auth/presentation/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
import 'package:pbl6/features/shared/auth/data/services/google_sign_in_service.dart';
import 'package:pbl6/features/shared/auth/domain/usecases/login_usecase.dart';
import 'package:pbl6/features/shared/user/domain/usecases/get_my_info_usecase.dart';
import 'package:pbl6/features/shared/user/presentation/providers/user_provider.dart';
import 'package:pbl6/routes/route_names.dart';
import 'package:provider/provider.dart';

import '../../../user/domain/entities/user.dart';
import '../widgets/login_form.dart';
import '../widgets/social_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  final LoginUseCase _loginUseCase = GetIt.instance<LoginUseCase>();
  final GoogleSignInService _googleSignInService =
      GetIt.instance<GoogleSignInService>();
  final GetMyInfoUseCase _getMyInfoUseCase = GetIt.instance<GetMyInfoUseCase>();
  bool _isGoogleLoading = false;
  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    if (mounted) setState(() => _isGoogleLoading = true);

    try {
      final idToken = await _googleSignInService.getIdToken();

      if (idToken != null) {
       
        final response = await _loginUseCase.googleLogin(idToken);

        if (response.code == 200 && response.result != null) {
         
          try {
            final userEntity = await _getMyInfoUseCase();
            if (mounted) {
              context.read<UserProvider>().setUser(
                User.fromAuthEntity(userEntity),
              );
            }
          } catch (e) {
            print("Lỗi fetch user info sau khi Google login: $e");
          }

          // 3. Hiển thị thông báo (Giống hệt _handleLogin)
          if (mounted) {
            MotionToast.success(
              title: const Text("Thành công"),
              description: const Text("Đăng nhập bằng Google thành công"),
              animationType: AnimationType.slideInFromLeft,
              toastDuration: const Duration(seconds: 2),
              toastAlignment: Alignment.topLeft,
            ).show(context);
          }

          // 4. Điều hướng (Giống hệt _handleLogin)
          // Tạm thời không delay để toast và điều hướng song song
          if (mounted) {
            context.go('/dashboard');
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đăng nhập Google thất bại: ${response.code}'),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không thể lấy ID Token từ Google')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppPallete.backgroundGradient,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chào bạn quay trở lại!',
                        style: TextStyle(
                          fontFamily: 'Italianno',
                          fontWeight: FontWeight.w400,
                          fontSize: 50,
                          color: AppPallete.textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Đăng nhập để tiếp tục hành trình của bạn',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppPallete.mutedTextColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: AppPallete.whiteColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppPallete.primaryColor.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const LoginForm(),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppPallete.borderColor.withOpacity(0.1),
                                AppPallete.borderColor,
                                AppPallete.borderColor.withOpacity(0.1),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'hoặc',
                          style: TextStyle(
                            color: AppPallete.mutedTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppPallete.borderColor.withOpacity(0.1),
                                AppPallete.borderColor,
                                AppPallete.borderColor.withOpacity(0.1),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  SocialButton(
                    text: 'Tiếp tục với Google',
                    imagePath: 'assets/images/google_logo.jpg',
                    onPressed: _handleGoogleSignIn,
                    backgroundColor: AppPallete.whiteColor,
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Bạn chưa có tài khoản? ',
                        style: TextStyle(
                          color: AppPallete.mutedTextColor,
                          fontSize: 16,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.push(RouteNames.ROLE_SELECTION);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: AppPallete.primaryColor,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Text(
                            'Tạo tài khoản',
                            style: TextStyle(
                              color: AppPallete.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
