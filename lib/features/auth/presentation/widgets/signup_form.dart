import 'package:flutter/material.dart';
import 'package:pbl6/core/theme/app_pallete.dart';

import 'custom_elevated_button.dart';
import 'custom_text_field.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  bool _agreeTerms = false;

  // Controllers cho các field
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          label: 'Họ và Tên',
          icon: Icons.person_outline,
          obscureText: false,
          controller: _nameController,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          label: 'Nhập email',
          icon: Icons.email_outlined,
          obscureText: false,
          controller: _emailController,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          label: 'Nhập mật khẩu',
          icon: Icons.lock_outline,
          obscureText: true,
          controller: _passwordController,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          label: 'Nhập lại mật khẩu',
          icon: Icons.lock_outline,
          obscureText: true,
          controller: _confirmPasswordController,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          label: 'Địa chỉ',
          icon: Icons.home_outlined,
          obscureText: false,
          controller: _addressController,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          label: 'Số điện thoại',
          icon: Icons.phone_outlined,
          obscureText: false,
          controller: _phoneController,
        ),
        const SizedBox(height: 20),
        // 👉 Ngày sinh có DatePicker
        GestureDetector(
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (pickedDate != null) {
              String formattedDate =
                  "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
              setState(() {
                _dobController.text = formattedDate;
              });
            }
          },
          child: AbsorbPointer(
            child: CustomTextField(
              label: 'Ngày sinh',
              icon: Icons.cake_outlined,
              obscureText: false,
              controller: _dobController,
            ),
          ),
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
        CustomElevatedButton(
          text: 'Đăng ký',
          onPressed: _handleSignUp,
        ),
      ],
    );
  }

  static void _handleSignUp() {
    // TODO: Handle sign up logic here
  }
}
