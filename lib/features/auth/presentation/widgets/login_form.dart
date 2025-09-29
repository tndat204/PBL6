import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
import 'package:pbl6/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pbl6/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:pbl6/features/auth/domain/usecases/login_usecase.dart';
import 'package:pbl6/features/auth/presentation/pages/forgot_password_email_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  final LoginUseCase _loginUseCase = LoginUseCase(
    AuthRepositoryImpl(GetIt.instance<AuthRemoteDataSource>()),
  );

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final response = await _loginUseCase(
          email: _emailController.text,
          password: _passwordController.text,
        );

        if (response.code == 200 && response.result?.token != null) {
          if (_rememberMe) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', response.result!.token);
        }
          MotionToast(
            icon: Icons.check_circle,
            primaryColor: AppPallete.lightGradient,
            secondaryColor:Color.fromARGB(255, 74, 98, 138), 
            title: const Text(
              "Thành công",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            description: const Text(
              "Đăng nhập thành công",
              style: TextStyle(color: AppPallete.backgroundColor),
            ),
            animationType: AnimationType.slideInFromLeft,
            toastDuration: const Duration(seconds: 2),
            toastAlignment: Alignment.topLeft, 
            borderRadius: 12,
            width: 320,
            height: 90,
          ).show(context);

          // _showSuccessDialog();
        } else if (response.code == 1023) {
           _showErrorSnackBar('Sai mật khẩu');
        } else {
          _showErrorSnackBar('Đăng nhập thất bại, vui lòng thử lại');
        }
      } catch (e) {
        _showErrorSnackBar(': $e');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Đăng nhập thành công!',
          style: TextStyle(color: Colors.green),
        ),
        content: const Text(
          'Chào mừng bạn quay lại! Bạn sẽ được chuyển hướng ngay.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: điều hướng sang trang chính
            },
            child: const Text('OK', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

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
            label: 'Nhập email',
            icon: Icons.email_outlined,
            obscureText: false,
            controller: _emailController,
            validator: (value) => value!.isEmpty ? 'Vui lòng nhập email' : null,
          ),
          const SizedBox(height: 20),
          CustomTextField(
            label: 'Nhập mật khẩu',
            icon: Icons.lock_outline,
            obscureText: true,
            controller: _passwordController,
            validator: (value) =>
                value!.isEmpty ? 'Vui lòng nhập mật khẩu' : null,
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordEmailPage(),
                      ),
                    );
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
          const SizedBox(height: 32),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomElevatedButton(
                  text: 'Đăng nhập',
                  onPressed: _handleLogin,
                ),
        ],
      ),
    );
  }
}
