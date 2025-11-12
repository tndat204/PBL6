import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart'; // Để dùng context.go
import 'package:motion_toast/motion_toast.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
import 'package:pbl6/features/shared/auth/domain/usecases/login_usecase.dart';
import 'package:pbl6/features/shared/user/domain/usecases/get_my_info_usecase.dart';
import 'package:pbl6/features/shared/user/presentation/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../routes/route_names.dart';
import '../../../user/domain/entities/user.dart';
import '../widgets/custom_elevated_button.dart';
import '../widgets/custom_text_field.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;

  String? _serverError;

  late final LoginUseCase _loginUseCase;
  late final GetMyInfoUseCase _getMyInfoUseCase;
  @override
  void initState() {
    super.initState();
    _loginUseCase = GetIt.I<LoginUseCase>();
    _getMyInfoUseCase = GetIt.I<GetMyInfoUseCase>();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      if (mounted)
        setState(() {
          _isLoading = true;
          _serverError = null;
        });

      try {
        final response = await _loginUseCase(
          email: _emailController.text,
          password: _passwordController.text,
        );

        if (response.code == 200 && response.result?.token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('remember_me', _rememberMe);
          try {
            final userEntity = await _getMyInfoUseCase();
            if (mounted) {
              context.read<UserProvider>().setUser(
                User.fromAuthEntity(userEntity),
              );
            }
          } catch (e) {
            print("Error fetching user info after login: $e");
          }

          
          MotionToast.success(
            title: const Text("Thành công"),
            description: const Text("Đăng nhập thành công"),
            animationType: AnimationType.slideInFromLeft,
            toastDuration: const Duration(seconds: 2),
            toastAlignment: Alignment.topLeft,
          ).show(context);


          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              context.go('/dashboard');
            }
          });
        } else if (response.code == 1023) {
          if (mounted) setState(() => _serverError = 'Sai mật khẩu');
        } else {
          if (mounted)
            setState(
              () => _serverError = 'Đăng nhập thất bại, vui lòng thử lại',
            );
        }
      } catch (e) {
        if (mounted)
          setState(
            () => _serverError = 'Lỗi không xác định. Vui lòng thử lại.',
          );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // ⭐ Đã xóa hàm _showErrorSnackBar(String message)

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            semanticsLabel: "emailField",
            label: 'Nhập email',
            icon: Icons.email_outlined,
            obscureText: false,
            controller: _emailController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập email';
              }
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value)) {
                return 'Email không đúng định dạng';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          CustomTextField(
            semanticsLabel: "passwordField",
            label: 'Nhập mật khẩu',
            icon: Icons.lock_outline,
            obscureText: true,
            controller: _passwordController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập mật khẩu';
              }
              if (value.length < 8) {
                return 'Mật khẩu phải có ít nhất 8 ký tự';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                      activeColor: AppPallete.primaryColor,
                      checkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Lưu đăng nhập',
                    style: TextStyle(
                      color: AppPallete.textColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppPallete.primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: TextButton(
                  onPressed: () {
                    context.go(
                      RouteNames.FORGOT_PASSWORD_EMAIL,
                    ); // Dùng GoRouter
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                  ),
                  child: Text(
                    'Quên mật khẩu?',
                    style: TextStyle(
                      color: AppPallete.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ⭐ Widget hiển thị lỗi server (thay cho SizedBox(height: 32))
          if (_serverError != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
              child: Semantics(
                label: _serverError!, // ✅ Appium sẽ đọc được nội dung này
                child: ExcludeSemantics(
                  // ✅ Ngăn text hiển thị lặp trong accessibility
                  child: Text(
                    _serverError!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 32),
          ],

          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Semantics(
                  label: "LoginButton",
                  button: true,
                  child: ExcludeSemantics(
                    child: CustomElevatedButton(
                      text: 'Đăng nhập',
                      onPressed: _handleLogin,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
