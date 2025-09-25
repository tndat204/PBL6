// features/auth/presentation/pages/forgot_password_email_page.dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
import 'package:pbl6/features/auth/domain/repositories/auth_repository.dart';
import 'package:pbl6/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:pbl6/features/auth/presentation/pages/verify_otp_page.dart';
import 'package:pbl6/features/auth/presentation/widgets/custom_text_field.dart';

class ForgotPasswordEmailPage extends StatefulWidget {
  final String? email;
  const ForgotPasswordEmailPage({super.key, this.email});

  @override
  State<ForgotPasswordEmailPage> createState() =>
      _ForgotPasswordEmailPageState();
}

class _ForgotPasswordEmailPageState extends State<ForgotPasswordEmailPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  final ForgotPasswordUseCase _useCase = ForgotPasswordUseCase(
    GetIt.instance<AuthRepository>(),
  );
  @override
  void initState() {
    super.initState();
    // Gán lại email đã truyền nếu có
    if (widget.email != null) {
      _emailController.text = widget.email!;
    }
  }

  Future<void> _sendOTP() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final response = await _useCase.sendOTP(_emailController.text);
        if (response.code == 200) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerifyOTPPage(email: _emailController.text),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${response.message ?? 'Không thể gửi OTP'}'),
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
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Quên mật khẩu',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppPallete.primaryGradient,
            ),
          ),
        ),
        foregroundColor: Colors.white,
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: AppPallete.primaryGradient,
                    ),
                    borderRadius: BorderRadius.circular(60),
                    boxShadow: [
                      BoxShadow(
                        color: AppPallete.darkGradient.withOpacity(0.4),
                        blurRadius: 25,
                        offset: const Offset(0, 12),
                      ),
                      BoxShadow(
                        color: AppPallete.lightGradient.withOpacity(0.2),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lock_reset_rounded, // Updated to rounded version
                    size: 60, // Increased size
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 35),
                const Text(
                  'Khôi phục mật khẩu',
                  style: TextStyle(
                    fontSize: 32, // Increased font size
                    fontWeight: FontWeight.w800, // Made bolder
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.5, // Added letter spacing
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Nhập địa chỉ email của bạn để nhận mã OTP\nvà khôi phục mật khẩu một cách an toàn', // Enhanced description
                  style: TextStyle(
                    fontSize: 17, // Slightly increased
                    color: Colors.grey[600],
                    height: 1.6, // Better line height
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 45),
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: AppPallete.darkGradient.withOpacity(0.05),
                        blurRadius: 50,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CustomTextField(
                        label: 'Email',
                        icon: Icons.email_outlined,
                        obscureText: false,
                        controller: _emailController,
                        validator: (value) {
                          if (value!.isEmpty) return 'Vui lòng nhập email';
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value))
                            return 'Email không hợp lệ';
                          return null;
                        },
                      ),
                      const SizedBox(height: 35),
                      _isLoading
                          ? Container(
                              height: 60, // Increased height
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: AppPallete.primaryGradient,
                                ),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppPallete.darkGradient.withOpacity(
                                      0.3,
                                    ),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: SizedBox(
                                  width:
                                      26, // Slightly larger loading indicator
                                  height: 26,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              width: double.infinity,
                              height: 60, // Increased height
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: AppPallete.primaryGradient,
                                ),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppPallete.darkGradient.withOpacity(
                                      0.4,
                                    ),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                  BoxShadow(
                                    color: AppPallete.lightGradient.withOpacity(
                                      0.2,
                                    ),
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(30),
                                  onTap: _sendOTP,
                                  child: const Center(
                                    child: Text(
                                      'Gửi mã OTP',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 19, // Increased font size
                                        fontWeight:
                                            FontWeight.w700, // Made bolder
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
                const SizedBox(height: 35),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppPallete.darkGradient.withOpacity(0.05),
                        AppPallete.lightGradient.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppPallete.darkGradient.withOpacity(0.15),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppPallete.darkGradient.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons
                              .info_outline_rounded, // Updated to rounded version
                          color: AppPallete.darkGradient,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Mã OTP sẽ được gửi đến email của bạn trong vòng vài phút. Vui lòng kiểm tra cả hộp thư spam.', // Enhanced message
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 15,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
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
      ),
    );
  }
}
