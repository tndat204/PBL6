// features/auth/presentation/pages/reset_password_page.dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
import 'package:pbl6/features/shared/auth/domain/repositories/auth_repository.dart';
import 'package:pbl6/features/shared/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:pbl6/features/shared/auth/presentation/widgets/custom_elevated_button.dart';
import 'package:pbl6/features/shared/auth/presentation/widgets/custom_text_field.dart';
import 'package:pbl6/routes/route_names.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;
  final String token;
  const ResetPasswordPage({
    super.key,
    required this.email,
    required this.token,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
  
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  final ForgotPasswordUseCase _useCase = ForgotPasswordUseCase(
    GetIt.instance<AuthRepository>(),
  );

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
      
        final response = await _useCase.resetPassword(
          _passwordController.text,
          widget.token,
        );
        if (response.code == 200) {
          // Hiển thị toast thành công
          MotionToast(
            icon: Icons.check_circle,
            primaryColor: AppPallete.lightGradient,
            secondaryColor: AppPallete.darkGradient,
            title: const Text(
              "Thành công",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            description: const Text(
              "Đặt lại mật khẩu thành công",
              style: TextStyle(color: AppPallete.backgroundColor),
            ),
            animationType: AnimationType.slideInFromLeft,
            toastDuration: const Duration(seconds: 2),
            toastAlignment: Alignment.topLeft,
            borderRadius: 12,
            width: 320,
            height: 90,
          ).show(context);

          // Delay 2s rồi quay về Login
          Future.delayed(const Duration(seconds: 2), () {
            context.go(RouteNames.LOGIN);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Lỗi: ${response.message ?? 'Không thể đặt lại mật khẩu'}',
              ),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Đặt lại mật khẩu',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppPallete.lighterbackground,
        elevation: 0,
        // flexibleSpace: Container(
        //   decoration: const BoxDecoration(
        //     gradient: LinearGradient(
        //       begin: Alignment.topLeft,
        //       end: Alignment.bottomRight,
        //       colors: AppPallete.primaryGradient,
        //     ),
        //   ),
        // ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppPallete.backgroundGradient,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppPallete.primaryGradient,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppPallete.darkGradient.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: AppPallete.lightGradient.withOpacity(0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lock_reset,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Tạo mật khẩu mới',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Vui lòng nhập mật khẩu mới để hoàn tất quá trình đặt lại',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF718096),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(28.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 25,
                      offset: const Offset(0, 15),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomTextField(
                        label: 'Mật khẩu mới',
                        icon: Icons.lock_outline,
                        obscureText: true,
                        controller: _passwordController,
                        validator: (value) {
                          if (value!.isEmpty) return 'Vui lòng nhập mật khẩu';
                          final regex = RegExp(
                            r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$',
                          );
                          if (!regex.hasMatch(value)) {
                            return 'Mật khẩu ít nhất 8 ký tự, có chữ hoa, số và ký tự đặc biệt';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        label: 'Xác nhận mật khẩu',
                        icon: Icons.lock_outline,
                        obscureText: true,
                        controller: _confirmPasswordController,
                        validator: (value) {
                          if (value!.isEmpty)
                            return 'Vui lòng nhập lại mật khẩu';
                          if (value != _passwordController.text)
                            return 'Mật khẩu không khớp';
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      _isLoading
                          ? Container(
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: AppPallete.primaryGradient,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                    strokeWidth: 2.5,
                                  ),
                                ),
                              ),
                            )
                          : CustomElevatedButton(
                              text: 'Đặt lại mật khẩu',
                              onPressed: _resetPassword,
                            ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppPallete.darkGradient.withOpacity(0.1),
                      AppPallete.lightGradient.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppPallete.darkGradient.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppPallete.darkGradient.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.security,
                        color: AppPallete.darkGradient,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Mật khẩu của bạn sẽ được mã hóa và bảo mật',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4A5568),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
