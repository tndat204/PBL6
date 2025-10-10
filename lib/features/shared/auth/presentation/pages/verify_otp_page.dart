// features/auth/presentation/pages/verify_otp_page.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
import 'package:pbl6/features/shared/auth/domain/repositories/auth_repository.dart';
import 'package:pbl6/features/shared/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:pbl6/features/shared/auth/presentation/pages/reset_password_page.dart';
import 'package:pbl6/features/shared/auth/presentation/widgets/custom_elevated_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerifyOTPPage extends StatefulWidget {
  final String email;
  final bool isOtpSent; // Cờ để xác định OTP đã được gửi

  const VerifyOTPPage({super.key, required this.email, this.isOtpSent = false});

  @override
  State<VerifyOTPPage> createState() => _VerifyOTPPageState();
}

class _VerifyOTPPageState extends State<VerifyOTPPage> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;
  int _timerSeconds = 60; // Đếm ngược 60 giây
  Timer? _timer;
  bool _canResend = false; // Cờ để kiểm tra có thể gửi lại không

  final ForgotPasswordUseCase _useCase = ForgotPasswordUseCase(
    GetIt.instance<AuthRepository>(),
  );

  String get _otpText => _otpControllers.map((controller) => controller.text).join();

  @override
  void initState() {
    super.initState();
    if (widget.isOtpSent) {
      startTimer(); // Bắt đầu đếm ngược nếu OTP đã được gửi
    }
  }

  void startTimer() {
    _timer?.cancel(); // Hủy timer cũ nếu có
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() => _timerSeconds--);
      } else {
        setState(() {
          _canResend = true;
          _timer?.cancel();
        });
      }
    });
  }

  Future<void> _resendOTP() async {
    if (_canResend) {
      setState(() {
        _isLoading = true;
        _canResend = false;
        _timerSeconds = 60;
      });
      try {
        final response = await _useCase.sendOTP(widget.email);
        if (response.code == 200) {
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
              "Gửi lại OTP thành công",
              style: TextStyle(color: AppPallete.backgroundColor),
            ),
            animationType: AnimationType.slideInFromLeft,
            toastDuration: const Duration(seconds: 2),
            toastAlignment: Alignment.topLeft,
            borderRadius: 12,
            width: 320,
            height: 90,
          ).show(context);
          startTimer(); // Bắt đầu đếm ngược lại
        } else {
          MotionToast.error(
            title: const Text("Lỗi"),
            description: Text(response.message ?? "Không thể gửi OTP"),
            toastAlignment: Alignment.topLeft,
            animationType: AnimationType.slideInFromLeft,
            toastDuration: const Duration(seconds: 2),
          ).show(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _verifyOTP() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final response = await _useCase.verifyOTP(widget.email, _otpText);
        if (response.code == 200) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('reset_token', response.result ?? '');
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
              "Xác thực OTP thành công",
              style: TextStyle(color: AppPallete.backgroundColor),
            ),
            animationType: AnimationType.slideInFromLeft,
            toastDuration: const Duration(seconds: 2),
            toastAlignment: Alignment.topLeft,
            borderRadius: 12,
            width: 320,
            height: 90,
          ).show(context);
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ResetPasswordPage(email: widget.email),
              ),
            );
          });
        } else {
          MotionToast.error(
            title: const Text("Lỗi"),
            description: Text(response.message ?? "OTP không đúng"),
            toastAlignment: Alignment.topLeft,
            animationType: AnimationType.slideInFromLeft,
            toastDuration: const Duration(seconds: 2),
          ).show(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildOTPInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return Container(
          width: 50,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _focusNodes[index].hasFocus
                  ? AppPallete.darkGradient
                  : Colors.grey.shade300,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppPallete.darkGradient.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: _otpControllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppPallete.darkGradient,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(1),
            ],
            decoration: const InputDecoration(
              border: InputBorder.none,
              counterText: '',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '';
              }
              return null;
            },
            onChanged: (value) {
              if (value.isNotEmpty && index < 5) {
                _focusNodes[index + 1].requestFocus();
              } else if (value.isEmpty && index > 0) {
                _focusNodes[index - 1].requestFocus();
              }
            },
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Xác thực OTP',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: AppPallete.primaryGradient,
                    ),
                    borderRadius: BorderRadius.circular(50),
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
                    Icons.security,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Xác thực OTP',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppPallete.darkGradient,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Nhập mã OTP 6 số đã được gửi đến\n${widget.email}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 50),
                _buildOTPInput(),
                const SizedBox(height: 50),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppPallete.darkGradient.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: _isLoading
                      ? Container(
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: AppPallete.primaryGradient,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        )
                      : CustomElevatedButton(
                          text: 'Xác thực OTP',
                          onPressed: _verifyOTP,
                        ),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Không nhận được mã? ',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      if (_canResend)
                        GestureDetector(
                          onTap: _resendOTP,
                          child: const Text(
                            'Gửi lại',
                            style: TextStyle(
                              color: AppPallete.darkGradient,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        )
                      else
                        Text(
                          'Gửi lại sau $_timerSeconds giây',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
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