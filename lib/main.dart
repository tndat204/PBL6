import 'package:flutter/material.dart';
import 'package:pbl6/core/theme/theme.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/signup_page.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IT Smart Hire',
      theme: AppTheme.lightThemeMode,
      home: const SignupPage(),
    );
  }
}