import 'package:flutter/material.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
import 'package:pbl6/features/shared/auth/presentation/pages/login_page.dart';
import 'package:pbl6/features/shared/auth/presentation/widgets/recruiter_signup_form.dart';

class RecruiterSignupPage extends StatefulWidget {
  const RecruiterSignupPage({super.key});

  @override
  State<RecruiterSignupPage> createState() => _RecruiterSignupPageState();
}

class _RecruiterSignupPageState extends State<RecruiterSignupPage> with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

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
                        'Chào nhà tuyển dụng mới!',
                        style: TextStyle(
                          fontFamily: 'Italianno',
                          fontWeight: FontWeight.w400,
                          fontSize: 50,
                          color: AppPallete.textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Đăng ký để bắt đầu tuyển dụng',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppPallete.mutedTextColor,
                              fontSize: 16,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  const RecruiterSignupForm(),
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
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Bạn đã có tài khoản? ',
                        style: TextStyle(
                          color: AppPallete.mutedTextColor,
                          fontSize: 16,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginPage()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: AppPallete.primaryColor,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Text(
                            'Đăng nhập',
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