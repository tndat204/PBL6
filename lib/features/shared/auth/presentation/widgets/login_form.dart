import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart'; // Để dùng context.go
import 'package:jwt_decode/jwt_decode.dart'; // Decode token
import 'package:motion_toast/motion_toast.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
import 'package:pbl6/features/shared/auth/domain/usecases/login_usecase.dart';
import 'package:pbl6/features/shared/user/domain/usecases/get_my_info_usecase.dart';
import 'package:pbl6/features/shared/user/presentation/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../../../routes/route_names.dart'; // Import route names
import '../../../../user/jobs/domain/entities/user.dart'; // Import User từ user domain (mở rộng từ auth)
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
    setState(() => _isLoading = true);
    try {
      final response = await _loginUseCase(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (response.code == 200 && response.result?.token != null) {
        final token = response.result!.token;
        final prefs = await SharedPreferences.getInstance();

        // ✅ Luôn lưu token (dù không rememberMe)
        await prefs.setString('auth_token', token);

        // Decode token để lấy role, userId, email
        final decodedToken = Jwt.parseJwt(token);
        final email = decodedToken['sub'] ?? _emailController.text;
        final userId = decodedToken['userId'] ?? const Uuid().v4().toString();
        final scope = decodedToken['scope'] ?? 'ROLE_USER';

        // Map scope sang UserRole
        UserRole role;
        switch (scope) {
          case 'ROLE_RECRUITER':
            role = UserRole.recruiter;
            break;
          case 'ROLE_ADMIN':
            role = UserRole.admin;
            break;
          default:
            role = UserRole.user;
        }

        // Lưu role & userId vào prefs để guard dùng
        await prefs.setString('user_role', role.toString());
        await prefs.setString('user_id', userId);

        // Nếu rememberMe thì đánh dấu cờ remember
        await prefs.setBool('remember_me', _rememberMe);
        try {
            // Fetch user info immediately after successful login
            final userEntity = await _getMyInfoUseCase();
            // Update the global UserProvider
            if (mounted) {
                 // Use read here as we are inside a button handler
                 context.read<UserProvider>().setUser(User.fromAuthEntity(userEntity));
            }
          } catch (e) {
             // Handle error fetching user info if needed, but don't block login
             print("Error fetching user info after login: $e");
             // Maybe show a less intrusive warning later
          }
        

        // ✅ Hiển thị toast thành công
        MotionToast(
          icon: Icons.check_circle,
          primaryColor: AppPallete.lightGradient,
          secondaryColor: const Color.fromARGB(255, 74, 98, 138),
          title: const Text(
            "Thành công",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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

        // Điều hướng đến dashboard sau 2 giây
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            context.go('/dashboard');
          }
        });
      } else if (response.code == 1023) {
        _showErrorSnackBar('Sai mật khẩu');
      } else {
        _showErrorSnackBar('Đăng nhập thất bại, vui lòng thử lại');
      }
    } catch (e) {
      _showErrorSnackBar('Lỗi: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
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
                    context.go(RouteNames.FORGOT_PASSWORD_EMAIL); // Dùng GoRouter
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