import 'package:flutter/material.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
import 'custom_text_field.dart';
import 'custom_elevated_button.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  bool _agreeTerms = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CustomTextField(
          label: 'Họ và Tên',
          icon: Icons.person_outline,
          obscureText: false,
        ),
        const SizedBox(height: 20),
        const CustomTextField(
          label: 'Nhập email',
          icon: Icons.email_outlined,
          obscureText: false,
        ),
        const SizedBox(height: 20),
        const CustomTextField(
          label: 'Nhập mật khẩu',
          icon: Icons.lock_outline,
          obscureText: true,
        ),
        const SizedBox(height: 20),
        const CustomTextField(
          label: 'Nhập lại mật khẩu',
          icon: Icons.lock_outline,
          obscureText: true,
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
                    value: _agreeTerms,
                    onChanged: (value) {
                      setState(() {
                        _agreeTerms = value ?? false;
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
                  'Tôi đồng ý với điều khoản',
                  style: TextStyle(
                    color: AppPallete.textColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 32),
        const CustomElevatedButton(
          text: 'Đăng ký',
          onPressed: _handleSignUp,
        ),
      ],
    );
  }

  static void _handleSignUp() {
    // Handle sign up logic here
  }
}