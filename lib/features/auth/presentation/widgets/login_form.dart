import 'package:flutter/material.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
import 'custom_text_field.dart';
import 'custom_elevated_button.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
        const CustomElevatedButton(
          text: 'Đăng nhập',
          onPressed: _handleSignIn,
        ),
      ],
    );
  }

  static void _handleSignIn() {
    // Handle sign in logic here
  }
}
