import 'package:flutter/material.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
import 'package:pbl6/features/auth/presentation/pages/recruiter_signup_page.dart';
import 'package:pbl6/features/auth/presentation/pages/signup_page.dart';
import '../widgets/custom_elevated_button.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Chào bạn',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Italianno',
                    fontSize: 46,
                    color: AppPallete.textColor,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Để tối ưu trải nghiệm của bạn với ITSMARTHIRE,\nvui lòng lựa chọn nhóm phù hợp nhất với bạn.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppPallete.textColor,
                  ),
                ),
                const SizedBox(height: 40),
                Image.asset(
                  'assets/images/recruiter.png',
                  height: 150,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 300,
                  child: CustomElevatedButton(
                    text: 'Tôi là nhà tuyển dụng',
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              const RecruiterSignupPage(),
                          transitionsBuilder: (context, animation,
                              secondaryAnimation, child) {
                            return FadeTransition(
                                opacity: animation, child: child);
                          },
                          transitionDuration: const Duration(milliseconds: 500),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Image.asset(
                  'assets/images/student.png',
                  height: 150,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 300,
                  child: CustomElevatedButton(
                    text: 'Tôi là ứng viên',
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              const SignupPage(),
                          transitionsBuilder: (context, animation,
                              secondaryAnimation, child) {
                            return FadeTransition(
                                opacity: animation, child: child);
                          },
                          transitionDuration: const Duration(milliseconds: 500),
                        ),
                      );
                    },
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
